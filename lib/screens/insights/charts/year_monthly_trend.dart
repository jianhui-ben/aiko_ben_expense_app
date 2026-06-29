import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/bar_trend_card.dart';
import 'package:aiko_ben_expense_app/shared/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Spend for each month of the current year with an average line. The big
/// picture: which months ran hot and how the current month compares.
class YearMonthlyTrend extends StatelessWidget {
  const YearMonthlyTrend({super.key});

  @override
  Widget build(BuildContext context) {
    final allTransactions = Provider.of<List<Transaction>?>(context) ?? [];

    final now = DateTime.now();
    final monthFormat = DateFormat('MMM');

    final bars = [
      for (int month = 1; month <= 12; month++)
        TrendBar(
          monthFormat.format(DateTime(now.year, month)),
          Util.sumTotal(Util.filterTransactionListToMonthOf(
              allTransactions, DateTime(now.year, month))),
        ),
    ];

    return BarTrendCard(
      title: 'Monthly spend',
      bars: bars,
      highlightIndex: now.month - 1,
    );
  }
}
