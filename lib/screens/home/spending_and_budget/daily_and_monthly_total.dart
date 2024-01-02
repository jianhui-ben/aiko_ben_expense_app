import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/screens/home/spending_and_budget/set_budget_and_donut_chart.dart';
import 'package:aiko_ben_expense_app/shared/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DailyAndMonthlyTotal extends StatelessWidget {
  final DateTime selectedDate;

  const DailyAndMonthlyTotal(
      {super.key, required this.selectedDate});

  // calculate the total transaction amount for the current month
  double calculateMonthlyTotal(List<Transaction> transactions) {
    return transactions
        .where((transaction) =>
            transaction.dateTime!.year == selectedDate.year &&
            transaction.dateTime!.month == selectedDate.month)
        .fold(0.0,
            (double sum, transaction) => sum + transaction.transactionAmount);
  }

  // calculate the total transaction amount for the current day
  double calculateDailyTotal(List<Transaction> transactions) {
    return transactions
        .where((transaction) =>
            transaction.dateTime!.year == selectedDate.year &&
            transaction.dateTime!.month == selectedDate.month &&
            transaction.dateTime!.day == selectedDate.day)
        .fold(0.0,
            (double sum, transaction) => sum + transaction.transactionAmount);
  }

  @override
  Widget build(BuildContext context) {
    final transactionStream = Provider.of<List<Transaction>?>(context);

    if (transactionStream == null) {
      return Container();
    }

    List<Transaction> filteredTransactionsList = Util.filterTransactionListToDate(transactionStream, selectedDate);

    if (transactionStream == null) {
      // return const Loading(); // or some other better loading widget
      return Container();
    }

    double monthlyTotal = calculateMonthlyTotal(transactionStream);
    double dailyTotal = calculateDailyTotal(filteredTransactionsList);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          // height: MediaQuery.of(context).size.height * 0.12,
          width: MediaQuery.of(context).size.width * 0.42,
          decoration: ShapeDecoration(
            color: Color(0xFFCEEAFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Spending',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                  width: MediaQuery.of(context).size.width * 0.42,
                  height: 70,
                  decoration: ShapeDecoration(
                    color: Color(0xFFFCFCFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Daily',
                            style: TextStyle(fontSize: 10),
                          ),
                          Text(
                            '\$${dailyTotal.toStringAsFixed(0)}',
                            // Replace with your daily total variable
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Monthly',
                            style: TextStyle(fontSize: 10),
                          ),
                          Text(
                            '\$${monthlyTotal.toStringAsFixed(0)}',
                            // Replace with your monthly total variable
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  )),
            ],
          ),
        ),
        SetBudgetAndDonutChart(monthlyTransactionTotal: monthlyTotal),
      ],
    );
  }

}


