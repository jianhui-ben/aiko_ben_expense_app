import 'package:cloud_firestore/cloud_firestore.dart';

class Household {
  final String id;
  final String name;
  final String inviteCode;
  final String createdBy;

  Household({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.createdBy,
  });

  factory Household.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Household(
      id: doc.id,
      name: (data['name'] ?? '') as String,
      inviteCode: (data['inviteCode'] ?? '') as String,
      createdBy: (data['createdBy'] ?? '') as String,
    );
  }

  @override
  String toString() =>
      'Household(id: $id, name: $name, inviteCode: $inviteCode)';
}

class HouseholdMember {
  final String uid;
  final String displayName;
  final String role; // "owner" | "member"

  HouseholdMember({
    required this.uid,
    required this.displayName,
    required this.role,
  });

  factory HouseholdMember.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return HouseholdMember(
      uid: doc.id,
      displayName: (data['displayName'] ?? '') as String,
      role: (data['role'] ?? 'member') as String,
    );
  }

  bool get isOwner => role == 'owner';
}
