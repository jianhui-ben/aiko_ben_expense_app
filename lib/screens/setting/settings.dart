import 'package:aiko_ben_expense_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  Settings({Key? key}) : super(key: key);

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
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
                  'A',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Aiko Duan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Account'),
              onTap: () {
                // Navigate to Account settings
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notification'),
              onTap: () {
                // Navigate to Notification settings
              },
            ),
            ListTile(
              leading: Icon(Icons.category),
              title: Text('Category Settings'),
              onTap: () {
                // Navigate to Category Settings
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
