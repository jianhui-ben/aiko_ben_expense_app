import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/shared/util.dart';
import 'package:aiko_ben_expense_app/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Which days of the week the household spends most this month. Borrowed from
/// behavior-rhythm views (e.g. Apple Health) — surfaces habits like weekend
/// splurges that a running total hides.
class WeekdayRhythm extends StatelessWidget {
  const WeekdayRhythm({super.key});

  static const _labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allTransactions = Provider.of<List<Transaction>?>(context) ?? [];

    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final thisMonthTransactions =
        Util.filterTransactionListToMonthOf(allTransactions, thisMonth);

    // DateTime.weekday: Mon = 1 ... Sun = 7.
    final totals = List<double>.filled(7, 0.0);
    for (final transaction in thisMonthTransactions) {
      final date = transaction.dateTime;
      if (date == null) continue;
      totals[date.weekday - 1] += transaction.transactionAmount;
    }

    final data = [
      for (var i = 0; i < 7; i++) _WeekdayTotal(_labels[i], totals[i]),
    ];

    final maxIndex = _indexOfMax(totals);
    final hasData = totals.any((t) => t > 0);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Spending rhythm', style: theme.textTheme.titleMedium),
              const Spacer(),
              if (hasData)
                Text('Busiest: ${_labels[maxIndex]}',
                    style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 180,
            child: SfCartesianChart(
              margin: EdgeInsets.zero,
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
              ),
              primaryYAxis: NumericAxis(
                numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0),
                majorGridLines: const MajorGridLines(color: AppColors.border),
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(width: 0),
              ),
              series: <CartesianSeries<_WeekdayTotal, String>>[
                ColumnSeries<_WeekdayTotal, String>(
                  dataSource: data,
                  xValueMapper: (d, _) => d.label,
                  yValueMapper: (d, _) => d.amount,
                  pointColorMapper: (d, index) => index == maxIndex && hasData
                      ? AppColors.primary
                      : AppColors.categoryAccent,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                  width: 0.65,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _indexOfMax(List<double> values) {
    var maxIndex = 0;
    for (var i = 1; i < values.length; i++) {
      if (values[i] > values[maxIndex]) maxIndex = i;
    }
    return maxIndex;
  }
}

class _WeekdayTotal {
  final String label;
  final double amount;

  _WeekdayTotal(this.label, this.amount);
}
