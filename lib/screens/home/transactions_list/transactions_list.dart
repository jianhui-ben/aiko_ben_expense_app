
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/screens/home/transactions_list/transaction_tile.dart';
import 'package:aiko_ben_expense_app/services/database.dart';
import 'package:aiko_ben_expense_app/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionsList extends StatefulWidget {
  const TransactionsList({super.key});

  @override
  State<TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {

  @override
  Widget build(BuildContext context) {

    // check the transaction stream
    final transactionStream = Provider.of<List<Transaction>?>(context);
    final user = Provider.of<User?>(context);

    // print('Number of transactions: ${transactionStream?.length}');
    if (transactionStream == null) {
      return const Loading();
    }
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: transactionStream.length,
        itemBuilder: (context, index){
          final transaction = transactionStream[index];

          return  Dismissible(
            // Each Dismissible must contain a Key. Keys allow Flutter to
            // uniquely identify widgets.
              key: Key(transaction.transactionId),
              // Provide a function that tells the app
              // what to do after an item has been swiped away.
              onDismissed: (direction) async {
                await DatabaseService(uid: user!.uid).removeTransactionById(transaction.transactionId);

                // Then show a snackbar.
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'transaction ${transaction.transactionId} dismissed')));
              },
              // Show a red background as the item is swiped away.
              background: Container(color: Colors.red),
              child: TransactionTile(transaction : transactionStream[index]));
        });
  }
}
