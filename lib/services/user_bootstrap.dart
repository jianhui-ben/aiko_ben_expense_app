import 'package:cloud_firestore/cloud_firestore.dart';

/// Ensures a `users/{uid}` document exists for the signed-in account.
///
/// This is the single source of truth for household membership (Phase 2).
/// Safe to call on every sign-in / register: it only writes missing fields.
class UserBootstrap {
  final FirebaseFirestore _firestore;

  UserBootstrap({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> ensureUserDocument(
    String uid, {
    String? displayName,
    String? email,
  }) async {
    final userDoc = _firestore.collection('users').doc(uid);
    final snapshot = await userDoc.get();

    if (!snapshot.exists) {
      await userDoc.set({
        'householdId': null,
        'displayName': displayName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    // Backfill profile fields without clobbering an existing householdId.
    final updates = <String, dynamic>{};
    if (displayName != null) updates['displayName'] = displayName;
    if (email != null) updates['email'] = email;
    if (updates.isNotEmpty) {
      await userDoc.set(updates, SetOptions(merge: true));
    }
  }
}
