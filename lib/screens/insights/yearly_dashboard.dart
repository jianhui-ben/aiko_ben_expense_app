import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/month_expense_by_day_spline_chart.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/total_amount.dart';
import 'package:flutter/material.dart';

class YearlyDashboard extends StatefulWidget {

  final List<Transaction> transactions;
  const YearlyDashboard({super.key, required this.transactions});

  @override
  State<YearlyDashboard> createState() => _YearlyDashboardState();
}

class _YearlyDashboardState extends State<YearlyDashboard> {
  @override
  Widget build(BuildContext context) {

    List<Widget> charts = [
      TotalAmount(title: 'Year Total:', transactions: widget.transactions),
      MonthExpenseByDaySplineChart(transactions: widget.transactions),
    ];

    return Scaffold(
      body: ListView.builder(
        itemCount: charts.length,
        itemBuilder: (BuildContext context, int index) {
          return charts[index];
        },
      ),
    );
  }
}
