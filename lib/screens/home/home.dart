
import 'package:aiko_ben_expense_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});


  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text("Home"),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              await _auth.signOut();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.person), // Your icon
                SizedBox(height: 1), // Spacer between icon and text
                Text(
                  'logout',
                  style: TextStyle(
                    fontSize: 10,
                  ),
                ), // Your text
              ],
            ),
          ),
        ],
      ),
      body: Placeholder(),
    );
  }
}
