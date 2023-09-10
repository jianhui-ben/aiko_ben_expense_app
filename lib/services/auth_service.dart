
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart' as my_app_user;
import 'database.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // sign in anon
  Future signInAnon() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      return _userFromFireBaseUserCredential(userCredential);
    } catch(e) {
      return null;
    }
  }

  //create my_app_user.user based on the firebase user
  // set up email as null temporarily
  my_app_user.User? _userFromFireBaseUserCredential(UserCredential userCredential) {
    print("firebase user additional info${userCredential.additionalUserInfo}");
    User? user = userCredential.user;
    return user != null ? my_app_user.User(uid: user.uid, email: null) : null;
  }

  // make a my_app_user.User for auth purpose
  Stream<my_app_user.User?> get user {
    return _auth.authStateChanges().map((user) {
      return user != null ? my_app_user.User(uid: user.uid, email: null) : null;
    });
  }

  // sign in with email & password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return _userFromFireBaseUserCredential(userCredential);
    } catch(e) {
      return e.toString();
    }
  }


  // register with email & password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      String uid = user!.uid;



      return _userFromFireBaseUserCredential(userCredential);
    } catch(e) {
      return e.toString();
    }
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch(e) {
      return null;
    }
  }
}