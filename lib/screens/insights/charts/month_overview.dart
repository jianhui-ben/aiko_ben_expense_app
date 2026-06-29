import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/overview_parts.dart';
import 'package:aiko_ben_expense_app/screens/insights/household_budget_builder.dart';
import 'package:aiko_ben_expense_app/shared/util.dart';
import 'package:aiko_ben_expense_app/shared/widgets/app_card.dart';
import 'package:aiko_ben_expense_app/shared/widgets/delta_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Month hero: leads with spend-so-far, the vs-last-month delta, budget pacing,
/// projected total, and a cumulative this-month-vs-last-month curve.
class MonthOverview extends StatelessWidget {
  const MonthOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final allTransactions = Provider.of<List<Transaction>?>(context) ?? [];

    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final lastMonth = DateTime(now.year, now.month - 1);
    final cutoffDay = now.day;
    final daysThisMonth = Util.daysInMonth(thisMonth);
    final daysLastMonth = Util.daysInMonth(lastMonth);

    final thisMonthTransactions =
        Util.filterTransactionListToMonthOf(allTransactions, thisMonth);
    final lastMonthTransactions =
        Util.filterTransactionListToMonthOf(allTransactions, lastMonth);
    final lastMonthToDateTransactions =
        Util.filterTransactionListToMonthToDate(allTransactions, lastMonth, cutoffDay);

    final spent = Util.sumTotal(thisMonthTransactions);
    final lastMonthToDate = Util.sumTotal(lastMonthToDateTransactions);
    final projected = cutoffDay > 0 ? spent / cutoffDay * daysThisMonth : spent;
    final delta = Util.percentChange(spent, lastMonthToDate);

    final data = _OverviewData(
      monthLabel: DateFormat('MMMM yyyy').format(thisMonth),
      spent: spent,
      delta: delta,
      projected: projected,
      thisCumulative:
          Util.cumulativeDailyTotals(thisMonthTransactions, thisMonth, cutoffDay),
      lastCumulative: Util.cumulativeDailyTotals(
          lastMonthTransactions, lastMonth, daysLastMonth),
    );

    return HouseholdBudgetBuilder(
      builder: (context, budget) => _OverviewCard(data: data, budget: budget),
    );
  }
}

class _OverviewData {
  final String monthLabel;
  final double spent;
  final double? delta;
  final double projected;
  final List<double> thisCumulative;
  final List<double> lastCumulative;

  const _OverviewData({
    required this.monthLabel,
    required this.spent,
    required this.delta,
    required this.projected,
    required this.thisCumulative,
    required this.lastCumulative,
  });
}

class _OverviewCard extends StatelessWidget {
  final _OverviewData data;
  final double budget;

  const _OverviewCard({required this.data, required this.budget});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final budgetLeft = budget - data.spent;
    final overBudget = budgetLeft < 0;
    final overProjected = data.projected > budget;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Spent this month', style: theme.textTheme.labelMedium),
              const Spacer(),
              Text(data.monthLabel, style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatMoney(data.spent), style: theme.textTheme.headlineLarge),
              const SizedBox(width: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: DeltaBadge(
                  delta: data.delta,
                  showSuffix: true,
                  showFallback: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          BudgetBar(spent: data.spent, budget: budget),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.lg),
          MetricTilesRow(
            tiles: [
              MetricTileData(
                label: 'Projected total',
                value: formatMoney(data.projected),
                color: overProjected ? AppColors.error : AppColors.textPrimary,
              ),
              MetricTileData(
                label: overBudget ? 'Over budget' : 'Budget left',
                value: formatMoney(budgetLeft.abs()),
                color: overBudget ? AppColors.error : AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Cumulative spend vs last month',
              style: theme.textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 200,
            child: _CumulativeSpendChart(
              thisCumulative: data.thisCumulative,
              lastCumulative: data.lastCumulative,
            ),
          ),
        ],
      ),
    );
  }
}

class _CumulativePoint {
  final int day;
  final double amount;

  _CumulativePoint(this.day, this.amount);
}

class _CumulativeSpendChart extends StatelessWidget {
  final List<double> thisCumulative;
  final List<double> lastCumulative;

  const _CumulativeSpendChart({
    required this.thisCumulative,
    required this.lastCumulative,
  });

  List<_CumulativePoint> _points(List<double> cumulative) {
    return [
      for (var i = 0; i < cumulative.length; i++)
        _CumulativePoint(i + 1, cumulative[i]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      margin: EdgeInsets.zero,
      plotAreaBorderWidth: 0,
      legend: const Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      primaryXAxis: NumericAxis(
        title: const AxisTitle(text: 'Day of month'),
        interval: 5,
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
      ),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0),
        majorGridLines: const MajorGridLines(color: AppColors.border),
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(width: 0),
      ),
      series: <CartesianSeries<_CumulativePoint, num>>[
        SplineSeries<_CumulativePoint, num>(
          name: 'This month',
          dataSource: _points(thisCumulative),
          xValueMapper: (point, _) => point.day,
          yValueMapper: (point, _) => point.amount,
          color: AppColors.primary,
          width: 3,
          splineType: SplineType.natural,
        ),
        SplineSeries<_CumulativePoint, num>(
          name: 'Last month',
          dataSource: _points(lastCumulative),
          xValueMapper: (point, _) => point.day,
          yValueMapper: (point, _) => point.amount,
          color: AppColors.textTertiary,
          width: 2,
          dashArray: const <double>[5, 5],
          splineType: SplineType.natural,
        ),
      ],
    );
  }
}
