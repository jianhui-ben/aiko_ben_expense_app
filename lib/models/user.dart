class User {
  final String uid;
  final String? email;
  final String? householdId;

  User({required this.uid, required this.email, this.householdId});

  @override
  String toString() {
    return "uid: $uid, email: $email, householdId: $householdId";
  }
}
