import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/bar_trend_card.dart';
import 'package:aiko_ben_expense_app/shared/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Rolling 6-month spend history with an average reference line so the user can
/// tell at a glance whether the current month is high, low, or typical.
class SixMonthTrend extends StatelessWidget {
  const SixMonthTrend({super.key});

  @override
  Widget build(BuildContext context) {
    final allTransactions = Provider.of<List<Transaction>?>(context) ?? [];

    final now = DateTime.now();
    final months = [
      for (int i = 5; i >= 0; i--) DateTime(now.year, now.month - i),
    ];

    final bars = months
        .map((month) => TrendBar(
              DateFormat('MMM').format(month),
              Util.sumTotal(
                  Util.filterTransactionListToMonthOf(allTransactions, month)),
            ))
        .toList();

    return BarTrendCard(
      title: '6-month trend',
      bars: bars,
      highlightIndex: bars.length - 1,
      showValueLabels: true,
    );
  }
}
