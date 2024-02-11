
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

  Map<DateTime, List<Transaction>> _groupedTransactionsList = {};
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      scrollToTransaction(widget.selectedDate);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TransactionsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      scrollToTransaction(widget.selectedDate);
    }
  }

  void scrollToTransaction(DateTime date) {

    if (_scrollController.hasClients) {
      // Find the index of the first transaction that matches the selected date
      int dateIndex = _groupedTransactionsList.entries.toList().indexWhere((entry) {
        return entry.key.isAtSameMomentAs(date);
      });

      // If no transaction matches the selected date, find the last transaction before the selected date
      if (dateIndex == -1) {
        dateIndex = _groupedTransactionsList.entries.toList().indexWhere((entry) {
          return entry.key.isBefore(date);
        });
      }

      // If a matching date is found, calculate the offset and scroll to it
      if (dateIndex != -1) {
        // Get the number of transactions for the selected date
        int numOfTransactions = 0;
        // write me a for loop to get the total number of transactions for the selected date
        for (int i = 0; i < dateIndex; i++) {
          numOfTransactions += _groupedTransactionsList.entries.elementAt(i).value.length;
        }
        // Calculate the offset
        // each subtitle and padding is around 35 pixel and each transaction tile is 56 (by default) + 7 padding
        double offset = dateIndex * 35.0 + numOfTransactions * 63.0;
        // print("offset: $offset");
        // print("numOfTransactions: $numOfTransactions");
        _scrollController.animateTo(
          offset,
          duration: Duration(seconds: 1),
          curve: Curves.fastLinearToSlowEaseIn,
        );
      }
    }
  }

  void _onScroll() {
    // Your existing scroll logic here
  }

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
    filteredTransactionsList = Util.sortTransactionsByDateAndAmount(filteredTransactionsList);
    _groupedTransactionsList = groupTransactionsByDate(filteredTransactionsList);

    return filteredTransactionsList.isEmpty
        ? DefaultEmptyTransactionList()
        : ListView.builder(
        controller:  _scrollController,
            shrinkWrap: true,
            itemCount: _groupedTransactionsList.length,
            itemBuilder: (context, index) {
              final entry = _groupedTransactionsList.entries.elementAt(index);
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      // color: Colors.blue,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MMM d, yyyy').format(entry.key),
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            "Total: \$${Util.sumTotal(entry.value).toStringAsFixed(0)}",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
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

                              // // optional: Then show a snackbar. this could show some flutter error
                              // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              //     content: Text(
                              //         'transaction ${transaction.category.categoryName} removed')));
                            },
                            // Show a red background as the item is swiped away.
                            background: Container(color: Colors.red),
                            child: TransactionTile(
                                transactionId: transaction.transactionId,
                                selectedDate:
                                    transaction.dateTime ?? widget.selectedDate,
                                transactionCategory: transaction.category,
                                transactionComment:
                                    (transaction.transactionComment != null &&
                                            transaction
                                                .transactionComment!.isNotEmpty)
                                        ? transaction.transactionComment!
                                        : transaction.category.categoryName,
                                transactionAmount:
                                    transaction.transactionAmount));
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
