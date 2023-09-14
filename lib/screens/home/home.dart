
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/screens/home/transactions_list/transactions_list.dart';
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
    String? _defaultTransactionComment;

    final user = Provider.of<User?>(context);

    return StreamProvider<List<Transaction>?>.value(
        value: DatabaseService(uid: user?.uid).transactions,
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
            body: Column(children: [
              Container(
                height: 120.0,
                child: ElevatedButton(
                  child: const Text('add a default transaction'),
                  onPressed: () async {
                    await DatabaseService(uid: user?.uid).addNewTransaction(
                        _defaultCategoryId,
                        _defaultTransactionAmoung,
                        _defaultTransactionComment);
                  },
                ),
              ),
              Container(
                // A fixed-height child.
                color: const Color(0xffeeee00), // Yellow
                height: 120.0,
                alignment: Alignment.center,
                child: const Text('placeholder for total'),
              ),

              Expanded(
                child: Container(
                    color: const Color(0xffee0038),
                    child: SingleChildScrollView(
                      physics: ScrollPhysics(),
                      child: Column(
                        children:
                        [
                          TransactionsList()
                        ],
                      ),
                    )
                    // child: TransactionsList())
                    ),
              ),
            ])));
  }

  // write some quick test case for scrollable window
  testCase() {
    List<Text> testList = [];

    for (int i = 1; i <= 100; i++) {
      testList.add(Text("test$i"));
    }
    return testList;
  }

}
