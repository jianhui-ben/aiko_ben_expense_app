
import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/screens/home/transactions_list/transaction_tile.dart';
import 'package:aiko_ben_expense_app/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// this has to be stateful because it has a gestrure detector to the scrolldownn function on home screen
class TransactionsList extends StatefulWidget {

  // add this userCategoriesMap for future usage
  final Map<String, Category>? userCategoriesMap;
  final DateTime selectedDate;
  final bool isDailyView;

  const TransactionsList(
      {super.key,
      this.userCategoriesMap,
      required this.selectedDate,
      required this.isDailyView});

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
    List<Transaction> filteredTransactionsList = widget.isDailyView
        ? filterTransactionsByDate(transactionStream, widget.selectedDate)
        : filterTransactionsByMonth(transactionStream, widget.selectedDate);

    return filteredTransactionsList.isEmpty
        ? DefaultTransactionList()
        : ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: filteredTransactionsList.length,
            itemBuilder: (context, index) {
              final transaction = filteredTransactionsList[index];

              return Dismissible(
                  // Each Dismissible must contain a Key. Keys allow Flutter to
                  // uniquely identify widgets.
                  key: Key(transaction.transactionId),
                  // Provide a function that tells the app
                  // what to do after an item has been swiped away.
                  onDismissed: (direction) async {
                    await DatabaseService(uid: user!.uid)
                        .removeTransactionById(transaction.transactionId);

                    // optional: Then show a snackbar.
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'transaction ${transaction.transactionId} dismissed')));
                  },
                  // Show a red background as the item is swiped away.
                  background: Container(color: Colors.red),
                  child: TransactionTile(
                      transactionId: transaction.transactionId,
                      selectedDate: filteredTransactionsList[index].dateTime ??
                          widget.selectedDate,
                      transactionCategory:
                          filteredTransactionsList[index].category,
                      transactionComment: (filteredTransactionsList[index]
                                      .transactionComment !=
                                  null &&
                              filteredTransactionsList[index]
                                  .transactionComment!
                                  .isNotEmpty)
                          ? filteredTransactionsList[index].transactionComment!
                          : filteredTransactionsList[index]
                              .category
                              .categoryName,
                      transactionAmount:
                          filteredTransactionsList[index].transactionAmount));
            });
  }


  List<Transaction> filterTransactionsByDate(
      List<Transaction> transactions, DateTime selectedDate) {
    return transactions.where((transaction) {
      final transactionDate = transaction.dateTime!;
      return transactionDate.year == selectedDate.year &&
          transactionDate.month == selectedDate.month &&
          transactionDate.day == selectedDate.day;
    }).toList();
  }

  List<Transaction> filterTransactionsByMonth(
      List<Transaction> transactions, DateTime selectedDate) {
    return transactions.where((transaction) {
      final transactionDate = transaction.dateTime!;
      return transactionDate.year == selectedDate.year &&
          transactionDate.month == selectedDate.month;
    }).toList();
  }

}

class DefaultTransactionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No transactions for the selected date',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
