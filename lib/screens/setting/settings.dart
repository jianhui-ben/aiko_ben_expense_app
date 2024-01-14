import 'package:aiko_ben_expense_app/screens/setting/account_screen.dart';
import 'package:aiko_ben_expense_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final AuthService _auth = AuthService();
  final _settingsCollection = FirebaseFirestore.instance.collection('settings');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: fetchUserName(), // Fetch the user's display name
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show a loading spinner while waiting
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            String displayName = snapshot.data!;
            String avatarText =
                displayName.isNotEmpty ? displayName[0].toUpperCase() : '';
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: CircleAvatar(
                        radius: 40,
                        child: Text(
                          avatarText,
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      displayName,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    _buildListTile(
                      leadingIcon: Icons.account_circle,
                      title: 'Account',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AccountScreen()),
                        );
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
                        // Navigate to Notification settings
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
        });
  }

  Future<String> fetchUserName() async {
    final docSnapshot =
        await _settingsCollection.doc(_auth.currentUser!.uid).get();
    return docSnapshot['name'];
  }

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
          onTap: onTap,
        ),
      ),
    );
  }
}
