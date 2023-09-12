
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/screens/home/transactions_list.dart';
import 'package:aiko_ben_expense_app/services/auth_service.dart';
import 'package:aiko_ben_expense_app/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {

    String _defaultCategoryId = "123";
    double _defaultTransactionAmoung = 100.0;
    String _defaultTransactionComment = "comment";

    final user = Provider.of<User?>(context);


    return StreamProvider<List<Transaction>?>.value(
      value: DatabaseService().transactions,
      initialData: null,
      child: Scaffold(
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
        body: Column(
          children: [
            ElevatedButton(
              child: const Text('add a default transaction'),
              onPressed: () async {
                await DatabaseService(uid: user?.uid).addNewTransaction(
                    _defaultCategoryId, _defaultTransactionAmoung,
                    _defaultTransactionComment);
              },
            ),
            TransactionsList()
          ],
        )
      ),
    );
  }
}
