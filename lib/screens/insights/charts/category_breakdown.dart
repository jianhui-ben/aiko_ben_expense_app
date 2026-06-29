import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/screens/insights/category_transactions_screen.dart';
import 'package:aiko_ben_expense_app/screens/insights/period_range.dart';
import 'package:aiko_ben_expense_app/shared/util.dart';
import 'package:aiko_ben_expense_app/shared/widgets/app_card.dart';
import 'package:aiko_ben_expense_app/shared/widgets/delta_badge.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// "Where the money went" — a donut of the period's spend by category plus a
/// ranked list with each category's share and change vs the previous comparable
/// period. Tapping a row drills into that category's transactions. Works for
/// any [InsightPeriod].
class CategoryBreakdown extends StatelessWidget {
  final InsightPeriod period;

  const CategoryBreakdown({super.key, required this.period});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allTransactions = Provider.of<List<Transaction>?>(context) ?? [];
    final range = PeriodRange.of(period, allTransactions);

    final lastByCategory = _sumByCategory(range.comparison);
    final grouped = _groupByCategory(range.current);
    final total = Util.sumTotal(range.current);

    final rows = grouped.entries
        .map((entry) => _CategoryRowData(
              category: entry.value.category,
              amount: entry.value.amount,
              transactions: entry.value.transactions,
              share: total <= 0 ? 0 : (entry.value.amount / total) * 100,
              delta: Util.percentChange(
                  entry.value.amount, lastByCategory[entry.key] ?? 0),
            ))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Where the money went', style: theme.textTheme.titleMedium),
              const Spacer(),
              Text(range.label, style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Text(
                  'No expenses in this period yet.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 200,
              child: _CategoryDonut(rows: rows, total: total),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (var i = 0; i < rows.length; i++)
              _CategoryRow(
                data: rows[i],
                color: AppColors.chartColorAt(i),
                periodLabel: range.label,
              ),
          ],
        ],
      ),
    );
  }

  Map<String, _CategoryAgg> _groupByCategory(List<Transaction> transactions) {
    final map = <String, _CategoryAgg>{};
    for (final transaction in transactions) {
      final id = transaction.category.categoryId;
      final agg = map[id];
      if (agg == null) {
        map[id] = _CategoryAgg(
          category: transaction.category,
          amount: transaction.transactionAmount,
          transactions: [transaction],
        );
      } else {
        agg.amount += transaction.transactionAmount;
        agg.transactions.add(transaction);
      }
    }
    return map;
  }

  Map<String, double> _sumByCategory(List<Transaction> transactions) {
    final map = <String, double>{};
    for (final transaction in transactions) {
      final id = transaction.category.categoryId;
      map[id] = (map[id] ?? 0) + transaction.transactionAmount;
    }
    return map;
  }
}

class _CategoryAgg {
  final Category category;
  double amount;
  final List<Transaction> transactions;

  _CategoryAgg({
    required this.category,
    required this.amount,
    required this.transactions,
  });
}

class _CategoryRowData {
  final Category category;
  final double amount;
  final double share;
  final double? delta;
  final List<Transaction> transactions;

  _CategoryRowData({
    required this.category,
    required this.amount,
    required this.share,
    required this.delta,
    required this.transactions,
  });
}

class _CategoryDonut extends StatelessWidget {
  final List<_CategoryRowData> rows;
  final double total;

  const _CategoryDonut({required this.rows, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SfCircularChart(
      margin: EdgeInsets.zero,
      annotations: <CircularChartAnnotation>[
        CircularChartAnnotation(
          widget: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total', style: theme.textTheme.labelSmall),
              Text(
                '\$${total.toStringAsFixed(0)}',
                style: theme.textTheme.headlineSmall,
              ),
            ],
          ),
        ),
      ],
      series: <CircularSeries<_CategoryRowData, String>>[
        DoughnutSeries<_CategoryRowData, String>(
          dataSource: rows,
          xValueMapper: (row, _) => row.category.categoryName,
          yValueMapper: (row, _) => row.amount,
          pointColorMapper: (row, index) => AppColors.chartColorAt(index),
          innerRadius: '68%',
          radius: '92%',
          strokeColor: AppColors.surface,
          strokeWidth: 2,
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final _CategoryRowData data;
  final Color color;
  final String periodLabel;

  const _CategoryRow({
    required this.data,
    required this.color,
    required this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CategoryTransactionsScreen(
                category: data.category,
                periodLabel: periodLabel,
                transactions: data.transactions,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: IconTheme(
                  data: IconThemeData(color: color, size: 18),
                  child: data.category.categoryIcon,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.category.categoryName,
                      style: theme.textTheme.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${data.share.toStringAsFixed(0)}% of spend',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${data.amount.toStringAsFixed(0)}',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  DeltaBadge(delta: data.delta),
                ],
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
