import 'dart:math';

import 'package:aiko_ben_expense_app/models/all_categories.dart';
import 'package:aiko_ben_expense_app/models/household.dart';
import 'package:aiko_ben_expense_app/shared/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Raised when a household operation fails for a user-visible reason.
class HouseholdException implements Exception {
  final String message;
  HouseholdException(this.message);
  @override
  String toString() => message;
}

class HouseholdService {
  final FirebaseFirestore _firestore;

  HouseholdService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const int maxMembers = 2;
  static const double defaultMonthlyBudget = 2000.0;
  static const List<String> _defaultSelectedCategoryIds = [
    '1', '2', '3', '4', '5', '6', '7', '8',
  ];

  CollectionReference<Map<String, dynamic>> get _households =>
      _firestore.collection('households');
  CollectionReference<Map<String, dynamic>> get _inviteCodes =>
      _firestore.collection('inviteCodes');
  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  Map<String, Map<String, dynamic>> _defaultCategories() {
    final categories = <String, Map<String, dynamic>>{};
    for (final category in allCategories) {
      categories[category.categoryId] = {
        'categoryName': category.categoryName,
        'categoryIcon': supportedIconsToStringMap[category.categoryIcon.icon],
      };
    }
    return categories;
  }

  /// Generates a unique 6-char uppercase alphanumeric invite code.
  Future<String> _generateUniqueInviteCode() async {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no ambiguous 0/O/1/I
    final random = Random.secure();
    for (var attempt = 0; attempt < 10; attempt++) {
      final code = List.generate(
        6,
        (_) => chars[random.nextInt(chars.length)],
      ).join();
      final existing = await _inviteCodes.doc(code).get();
      if (!existing.exists) return code;
    }
    throw HouseholdException('Could not generate an invite code. Try again.');
  }

  /// Creates a household, seeds defaults, and assigns the creator as owner.
  /// Returns the new household id.
  Future<String> createHousehold({
    required String uid,
    required String displayName,
    required String name,
  }) async {
    final inviteCode = await _generateUniqueInviteCode();
    final householdRef = _households.doc();

    await householdRef.set({
      'name': name,
      'inviteCode': inviteCode,
      'monthlyBudget': defaultMonthlyBudget,
      'selectedCategoryIds': _defaultSelectedCategoryIds,
      'categories': _defaultCategories(),
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _inviteCodes.doc(inviteCode).set({'householdId': householdRef.id});

    await householdRef.collection('members').doc(uid).set({
      'displayName': displayName,
      'role': 'owner',
      'joinedAt': FieldValue.serverTimestamp(),
    });

    await _userDoc(uid).set(
      {'householdId': householdRef.id},
      SetOptions(merge: true),
    );

    return householdRef.id;
  }

  /// Joins an existing household by invite code. Enforces the member cap.
  /// Returns the joined household id.
  Future<String> joinHousehold({
    required String uid,
    required String displayName,
    required String code,
  }) async {
    final normalized = code.trim().toUpperCase();
    if (normalized.length != 6) {
      throw HouseholdException('Invite codes are 6 characters.');
    }

    final inviteDoc = await _inviteCodes.doc(normalized).get();
    if (!inviteDoc.exists) {
      throw HouseholdException('No household found for that code.');
    }
    final householdId = inviteDoc.data()!['householdId'] as String;
    final householdRef = _households.doc(householdId);

    if (!(await householdRef.get()).exists) {
      throw HouseholdException('That household no longer exists.');
    }

    final membersRef = householdRef.collection('members');
    final alreadyMember = await membersRef.doc(uid).get();
    if (!alreadyMember.exists) {
      final members = await membersRef.get();
      if (members.size >= maxMembers) {
        throw HouseholdException(
          'This household is full (max $maxMembers members).',
        );
      }
      await membersRef.doc(uid).set({
        'displayName': displayName,
        'role': 'member',
        'joinedAt': FieldValue.serverTimestamp(),
      });
    }

    await _userDoc(uid).set(
      {'householdId': householdId},
      SetOptions(merge: true),
    );

    return householdId;
  }

  Stream<Household?> householdStream(String householdId) {
    return _households.doc(householdId).snapshots().map(
          (doc) => doc.exists ? Household.fromDoc(doc) : null,
        );
  }

  Stream<List<HouseholdMember>> membersStream(String householdId) {
    return _households
        .doc(householdId)
        .collection('members')
        .snapshots()
        .map((snap) => snap.docs.map(HouseholdMember.fromDoc).toList());
  }

  Future<void> updateHouseholdName(String householdId, String name) {
    return _households.doc(householdId).update({'name': name});
  }

  /// Promotes [newOwnerUid] to owner and demotes [currentOwnerUid] to member.
  Future<void> transferOwnership({
    required String householdId,
    required String currentOwnerUid,
    required String newOwnerUid,
  }) async {
    if (currentOwnerUid == newOwnerUid) {
      throw HouseholdException('Choose a different member to transfer to.');
    }

    final membersRef = _households.doc(householdId).collection('members');
    final ownerDoc = await membersRef.doc(currentOwnerUid).get();
    if (!ownerDoc.exists || ownerDoc.data()?['role'] != 'owner') {
      throw HouseholdException('Only the owner can transfer ownership.');
    }

    final newOwnerDoc = await membersRef.doc(newOwnerUid).get();
    if (!newOwnerDoc.exists) {
      throw HouseholdException('That member is no longer in the household.');
    }

    final batch = _firestore.batch();
    batch.update(membersRef.doc(newOwnerUid), {'role': 'owner'});
    batch.update(membersRef.doc(currentOwnerUid), {'role': 'member'});
    await batch.commit();
  }

  /// Removes [uid] from the household and clears their active household pointer.
  /// Owners with other members must transfer ownership first.
  Future<void> leaveHousehold({
    required String uid,
    required String householdId,
  }) async {
    final membersRef = _households.doc(householdId).collection('members');
    final memberDoc = await membersRef.doc(uid).get();
    if (!memberDoc.exists) {
      throw HouseholdException('You are not a member of this household.');
    }

    final role = memberDoc.data()?['role'] as String? ?? 'member';
    if (role == 'owner') {
      final members = await membersRef.get();
      if (members.size > 1) {
        throw HouseholdException('Transfer ownership before leaving.');
      }
    }

    final batch = _firestore.batch();
    batch.delete(membersRef.doc(uid));
    batch.update(_userDoc(uid), {
      'householdId': FieldValue.delete(),
    });
    await batch.commit();
  }
}
