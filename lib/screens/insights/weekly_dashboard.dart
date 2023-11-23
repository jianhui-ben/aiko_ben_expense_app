import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/expense_by_category_bar_chart.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/month_expense_spline_chart.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/total_amount.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/week_expense_spline_chart.dart';
import 'package:flutter/material.dart';

class WeeklyDashboard extends StatefulWidget {

  final List<Transaction> transactions;
  const WeeklyDashboard({super.key, required this.transactions});

  @override
  State<WeeklyDashboard> createState() => _WeeklyDashboardState();
}

class _WeeklyDashboardState extends State<WeeklyDashboard> {
  @override
  Widget build(BuildContext context) {

    List<Widget> charts = [
      TotalAmount(title: 'Week Total:', transactions: widget.transactions),
      WeekExpenseSplineChart(transactions: widget.transactions),
      ExpenseByCategoryBarChart(transactions: widget.transactions),
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
