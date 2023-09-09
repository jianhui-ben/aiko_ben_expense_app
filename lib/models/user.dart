

class User {

  final String uid;
  final String? email;

  User({required this.uid, required this.email});

  @override
  String toString() {
    return "uid: $uid, email: $email";
  }
}