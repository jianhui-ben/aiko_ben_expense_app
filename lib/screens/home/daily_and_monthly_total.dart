import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DailyAndMonthlyTotal extends StatelessWidget {

  final DateTime selectedDate;

  const DailyAndMonthlyTotal({super.key, required this.selectedDate});


  // calculate the total transaction amount for the current month
  double calculateMonthlyTotal(List<Transaction> transactions) {
    return transactions
        .where((transaction) =>
    transaction.dateTime!.year == selectedDate.year &&
        transaction.dateTime!.month == selectedDate.month)
        .fold(0.0, (double sum, transaction) => sum + transaction.transactionAmount);
  }

  // calculate the total transaction amount for the current day
  double calculateDailyTotal(List<Transaction> transactions) {
    return transactions
        .where((transaction) =>
    transaction.dateTime!.year == selectedDate.year &&
        transaction.dateTime!.month == selectedDate.month &&
        transaction.dateTime!.day == selectedDate.day)
        .fold(0.0, (double sum, transaction) => sum + transaction.transactionAmount);
  }


  @override
  Widget build(BuildContext context) {

    final transactionStream = Provider.of<List<Transaction>?>(context);

    if (transactionStream == null) {
      return Container();
    }

    // // Filter transactions based on the selected date.
    List<Transaction> filteredTransactionsList = transactionStream.where((transaction) {
      final transactionDate = transaction.dateTime!;
      return transactionDate.year == selectedDate.year &&
          transactionDate.month == selectedDate.month &&
          transactionDate.day == selectedDate.day;
    }).toList();

    if (transactionStream == null) {
      // return const Loading(); // or some other better loading widget
      return Container();
    }

    double monthlyTotal = calculateMonthlyTotal(transactionStream);
    double dailyTotal = calculateDailyTotal(filteredTransactionsList);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjust spacing as needed
          children: [
            // Left column for Daily Total
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Daily Total',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${dailyTotal.toStringAsFixed(0)}', // Round to closest integer and add $
                  style: TextStyle(fontSize: 24), // Adjust the font size as needed
                ),
              ],
            ),
            // Right column for Monthly Total
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Monthly Total',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${monthlyTotal.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 24), // Adjust the font size as needed
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
