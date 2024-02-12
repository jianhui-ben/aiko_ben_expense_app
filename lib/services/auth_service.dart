
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart' as my_app_user;
import 'package:google_sign_in/google_sign_in.dart';


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

  //helper function to get the firebaseAuthUser
  User? get currentUser {
    return _auth.currentUser;
  }

  Stream<User?> userChanges() {
    return _auth.userChanges();
  }

  // // helper function to get the current app user
  // my_app_user.User? get currentUser {
  //   final User? firebaseUser = _auth.currentUser;
  //   return firebaseUser != null ? my_app_user.User(uid: firebaseUser.uid, email: null) : null;
  // }

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

  // sign in with google
  Future signInWithGoogle() async {
    try {
      UserCredential userCredential = await getUserCredentialFromSignInWithGoogle();
      return _userFromFireBaseUserCredential(userCredential);
    } catch(e) {
      return e.toString();
    }
  }

  Future<UserCredential> getUserCredentialFromSignInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }


  // register with email & password
  Future registerWithEmailAndPassword(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      String uid = user!.uid;

      // Update the user's display name after successfully creating the user
      await updateUserProfile(name, email);
      return _userFromFireBaseUserCredential(userCredential);
    } catch(e) {
      return e.toString();
    }
  }

  // update user profile
  Future<void> updateUserProfile(String userName, String userEmail) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(userName);
      await user.updateEmail(userEmail);
      await user.reload();
    }
  }

  // update user display name
  Future<void> updateUserProfileName(String name) async {
    User? user = _auth.currentUser;

    if (user != null) {
      await user.updateDisplayName(name);
      await user.reload();
    }
  }

  // update user photo url
  Future<void> updateUserProfilePhotoUrl(String? photoUrl) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.updatePhotoURL(photoUrl);
      await user.reload();
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