import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/spline_chart.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/total_amount.dart';
import 'package:flutter/material.dart';

class MonthlyDashboard extends StatefulWidget {

  final List<Transaction> transactions;
  const MonthlyDashboard({super.key, required this.transactions});

  @override
  State<MonthlyDashboard> createState() => _MonthlyDashboardState();
}

class _MonthlyDashboardState extends State<MonthlyDashboard> {

  @override
  Widget build(BuildContext context) {

    List<Widget> charts = [
      TotalAmount(title: 'Monthly Total:', transactions: widget.transactions),
      SplineChart(),
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
