
import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/screens/home/transactions_list/transaction_tile.dart';
import 'package:aiko_ben_expense_app/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionsList extends StatefulWidget {


  // add this userCategoriesMap for future usage
  final Map<String, Category>? userCategoriesMap;
  final DateTime selectedDate;

  const TransactionsList({super.key, this.userCategoriesMap, required this.selectedDate});

  @override
  State<TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {

  @override
  Widget build(BuildContext context) {

    // check the transaction stream
    final transactionStream = Provider.of<List<Transaction>?>(context);
    final user = Provider.of<User?>(context);

    if (transactionStream == null) {
      // return const Loading(); // or some other better loading widget
      return Container();
    }

    // // Filter transactions based on the selected date.
    List<Transaction> filteredTransactionsList = transactionStream.where((transaction) {
      final transactionDate = transaction.dateTime!;
      return transactionDate.year == widget.selectedDate.year &&
          transactionDate.month == widget.selectedDate.month &&
          transactionDate.day == widget.selectedDate.day;
    }).toList();

    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: filteredTransactionsList.length,
        itemBuilder: (context, index){
          final transaction = filteredTransactionsList[index];

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
              child: TransactionTile(
                  transactionIcon:
                  filteredTransactionsList[index].category.categoryIcon,
                  transactionComment:
                      (filteredTransactionsList[index].transactionComment != null &&
                          filteredTransactionsList[index]
                                  .transactionComment!
                                  .isNotEmpty)
                          ? filteredTransactionsList[index].transactionComment!
                          : filteredTransactionsList[index].category.categoryName,
                  transactionAmount:
                  filteredTransactionsList[index].transactionAmount));
        });
  }
}
