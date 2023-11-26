
import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/screens/home/transactions_list/transaction_tile.dart';
import 'package:aiko_ben_expense_app/services/database.dart';
import 'package:aiko_ben_expense_app/shared/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    // List<Transaction> filteredTransactionsList = widget.isDailyView
    //     ? filterTransactionsByDate(transactionStream, widget.selectedDate)
    //     : filterTransactionsByMonth(transactionStream, widget.selectedDate);

    // new design use the current month transactions
    List<Transaction> filteredTransactionsList = filterTransactionsByMonth(transactionStream, widget.selectedDate);
    Map<DateTime, List<Transaction>> groupedTransactionsList =
    groupTransactionsByDate(filteredTransactionsList);

    return filteredTransactionsList.isEmpty
        ? DefaultEmptyTransactionList()
        : ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: groupedTransactionsList.length,
            itemBuilder: (context, index) {
              final entry = groupedTransactionsList.entries.elementAt(index);
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMM d, yyyy').format(entry.key),
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          "Total: \$${Util.sumTotal(entry.value).toStringAsFixed(0)}",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    Divider(height: 1),
                    Column(
                      children: entry.value.map((transaction) {
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
                      }).toList(),
                    ),
                  ],
                ),
              );
            });
  }

  Map<DateTime, List<Transaction>> groupTransactionsByDate(
      List<Transaction> transactions) {
    Map<DateTime, List<Transaction>> groupedTransactions = {};

    for (var transaction in transactions) {
      final transactionDate = DateTime(
        transaction.dateTime!.year,
        transaction.dateTime!.month,
        transaction.dateTime!.day,
      );

      if (!groupedTransactions.containsKey(transactionDate)) {
        groupedTransactions[transactionDate] = [];
      }

      groupedTransactions[transactionDate]!.add(transaction);
    }

    return groupedTransactions;
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

class DefaultEmptyTransactionList extends StatelessWidget {
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
            'No transactions this month.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
