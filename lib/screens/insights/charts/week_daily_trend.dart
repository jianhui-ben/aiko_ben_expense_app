import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/bar_trend_card.dart';
import 'package:aiko_ben_expense_app/shared/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Daily spend for the last 7 days with an average line. A daily view is far
/// more actionable than a cumulative one over a short window.
class WeekDailyTrend extends StatelessWidget {
  const WeekDailyTrend({super.key});

  @override
  Widget build(BuildContext context) {
    final allTransactions = Provider.of<List<Transaction>?>(context) ?? [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayFormat = DateFormat('E');

    final bars = [
      for (int i = 6; i >= 0; i--)
        () {
          final day = today.subtract(Duration(days: i));
          final total = Util.sumTotal(
              Util.filterTransactionListToDateRange(allTransactions, day, day));
          return TrendBar(dayFormat.format(day), total);
        }(),
    ];

    return BarTrendCard(
      title: 'Daily spend',
      bars: bars,
      highlightIndex: bars.length - 1,
      showValueLabels: true,
      height: 180,
    );
  }
}
