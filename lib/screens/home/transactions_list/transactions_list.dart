
import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/screens/home/transactions_list/transaction_tile.dart';
import 'package:aiko_ben_expense_app/services/database.dart';
import 'package:aiko_ben_expense_app/shared/util.dart';
import 'package:aiko_ben_expense_app/shared/widgets/amount_text.dart';
import 'package:aiko_ben_expense_app/shared/widgets/empty_state.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
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

    final theme = Theme.of(context);

    return filteredTransactionsList.isEmpty
        ? const DefaultEmptyTransactionList()
        : ListView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xxxl,
            ),
            itemCount: _groupedTransactionsList.length,
            itemBuilder: (context, index) {
              final entry = _groupedTransactionsList.entries.elementAt(index);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.xs,
                        right: AppSpacing.xs,
                        bottom: AppSpacing.sm,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatGroupLabel(entry.key),
                            style: theme.textTheme.labelMedium,
                          ),
                          AmountText(
                            amount: Util.sumTotal(entry.value),
                            style: theme.textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                    ...entry.value.map((transaction) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Dismissible(
                          key: Key(transaction.transactionId),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) async {
                            await DatabaseService(householdId: user!.householdId)
                                .removeTransactionById(transaction.transactionId);
                          },
                          background: _dismissBackground(),
                          child: TransactionTile(
                            transactionId: transaction.transactionId,
                            selectedDate:
                                transaction.dateTime ?? widget.selectedDate,
                            transactionCategory: transaction.category,
                            transactionComment:
                                (transaction.transactionComment != null &&
                                        transaction.transactionComment!.isNotEmpty)
                                    ? transaction.transactionComment!
                                    : transaction.category.categoryName,
                            transactionAmount: transaction.transactionAmount,
                            createdByName: transaction.createdByName,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            });
  }

  String _formatGroupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';
    return DateFormat('EEEE, MMM d').format(date);
  }

  Widget _dismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: const Icon(Icons.delete_outline, color: Colors.white),
    );
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
  const DefaultEmptyTransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'No expenses yet',
      subtitle: 'Tap a category above to add your first expense.',
    );
  }
}
