import 'package:aiko_ben_expense_app/screens/home/daily_and_monthly_total.dart';
import 'package:flutter/material.dart';

class MonthlyDashboard extends StatefulWidget {

  const MonthlyDashboard({super.key});

  @override
  State<MonthlyDashboard> createState() => _MonthlyDashboardState();
}

class _MonthlyDashboardState extends State<MonthlyDashboard> {
  //insights page always consider today's date as selectedDate
  static DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  List<Widget> charts = [
    DailyAndMonthlyTotal(selectedDate: today, isDailyView: false),
    DailyAndMonthlyTotal(selectedDate: today, isDailyView: false),
    DailyAndMonthlyTotal(selectedDate: today, isDailyView: false),
    DailyAndMonthlyTotal(selectedDate: today, isDailyView: false),
    DailyAndMonthlyTotal(selectedDate: today, isDailyView: false),
    DailyAndMonthlyTotal(selectedDate: today, isDailyView: false)
  ];


  @override
  Widget build(BuildContext context) {
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
