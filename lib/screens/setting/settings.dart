import 'package:aiko_ben_expense_app/screens/setting/account_screen.dart';
import 'package:aiko_ben_expense_app/screens/setting/category_setting_screen.dart';
import 'package:aiko_ben_expense_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  AuthService _auth = AuthService();
  String? displayName;
  String? avatarText;
  String? photoUrl;
  final _settingsCollection = FirebaseFirestore.instance.collection('settings');

  @override
  void initState() {
    super.initState();
    displayName = _auth.currentUser!.displayName;
    avatarText = displayName!.isNotEmpty ? displayName![0].toUpperCase() : '';
    photoUrl = _auth.currentUser!.photoURL;
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<User?>(
        stream: _auth.userChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show a loading spinner while waiting
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            User? user = snapshot.data;
            displayName = user!.displayName;
            avatarText = displayName!.isNotEmpty ? displayName![0].toUpperCase() : '';
            photoUrl = user!.photoURL;
            // Use the user data to build your widget
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              photoUrl != null ? NetworkImage(photoUrl!) : null,
                          child: photoUrl == null
                              ? Text(
                                  avatarText!,
                                  style: TextStyle(fontSize: 24),
                                )
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      displayName!,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    _buildListTile(
                      leadingIcon: Icons.account_circle,
                      title: 'Account',
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AccountScreen()),
                        );
                        await _auth.currentUser!.reload();
                      },
                    ),
                    _buildListTile(
                      leadingIcon: Icons.notifications,
                      title: 'Notification',
                      onTap: () {
                        // Navigate to Notification settings
                      },
                    ),
                    _buildListTile(
                      leadingIcon: Icons.category,
                      title: 'Category Settings',
                      onTap: () {
                        // Navigate to category settings
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CategorySettingScreen()),
                        );
                      },
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () async {
                        // Implement logout functionality
                        await _auth.signOut();
                      },
                      child: Text(
                        'Log Out',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
      }
    );
  }

  // Future<String> fetchUserName() async {
  //
  //   // final docSnapshot =
  //   //     await _settingsCollection.doc(_auth.currentUser!.uid).get();
  //   // print('profile email: ${_auth.firebaseAuthUser!.displayName}');
  //   // print("profile disaplay name:${_auth.firebaseAuthUser!.email}");
  //   // //print photourl
  //   // print("profile photo:${_auth.firebaseAuthUser!.photoURL}");
  //   // return docSnapshot['name'];
  //
  //   return _auth.firebaseAuthUser!.displayName;
  //
  // }

  Widget _buildListTile({
    required IconData leadingIcon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0), // Add your desired padding here
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(15), // Adjust the border radius as needed
        ),
        child: ListTile(
          leading: Icon(leadingIcon),
          title: Text(title),
          onTap: () {
            onTap();
          }
        ),
      ),
    );
  }
}
