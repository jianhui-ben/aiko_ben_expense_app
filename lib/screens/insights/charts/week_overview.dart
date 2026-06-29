import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/overview_parts.dart';
import 'package:aiko_ben_expense_app/screens/insights/household_budget_builder.dart';
import 'package:aiko_ben_expense_app/screens/insights/period_range.dart';
import 'package:aiko_ben_expense_app/shared/util.dart';
import 'package:aiko_ben_expense_app/shared/widgets/app_card.dart';
import 'package:aiko_ben_expense_app/shared/widgets/delta_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Week hero: spend over the last 7 days, vs the prior 7 days, paced against a
/// weekly target derived from the monthly budget, plus daily average and the
/// busiest day. A recent, fast-moving lens rather than a month-long one.
class WeekOverview extends StatelessWidget {
  const WeekOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final allTransactions = Provider.of<List<Transaction>?>(context) ?? [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final range = PeriodRange.of(InsightPeriod.week, allTransactions, now: now);

    final spent = Util.sumTotal(range.current);
    final previous = Util.sumTotal(range.comparison);
    final delta = Util.percentChange(spent, previous);
    final dailyAvg = spent / 7;

    // Busiest of the last 7 days.
    String busiestLabel = '—';
    double busiestAmount = -1;
    final dayFormat = DateFormat('EEE');
    for (int i = 0; i < 7; i++) {
      final day = today.subtract(Duration(days: i));
      final amount = Util.sumTotal(
          Util.filterTransactionListToDateRange(allTransactions, day, day));
      if (amount > busiestAmount) {
        busiestAmount = amount;
        busiestLabel = amount > 0 ? dayFormat.format(day) : '—';
      }
    }

    return HouseholdBudgetBuilder(
      builder: (context, monthlyBudget) {
        final daysThisMonth = Util.daysInMonth(today);
        final weeklyTarget = monthlyBudget * 7 / daysThisMonth;
        return _card(context, spent, delta, dailyAvg, busiestLabel,
            weeklyTarget, range.label);
      },
    );
  }

  Widget _card(
    BuildContext context,
    double spent,
    double? delta,
    double dailyAvg,
    String busiestLabel,
    double weeklyTarget,
    String rangeLabel,
  ) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Spent this week', style: theme.textTheme.labelMedium),
              const Spacer(),
              Text(rangeLabel, style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatMoney(spent), style: theme.textTheme.headlineLarge),
              const SizedBox(width: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: DeltaBadge(
                  delta: delta,
                  showFallback: true,
                  fallbackLabel: 'vs last week',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          BudgetBar(
            spent: spent,
            budget: weeklyTarget,
            targetNoun: 'weekly target',
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.lg),
          MetricTilesRow(
            tiles: [
              MetricTileData(
                  label: 'Daily average', value: formatMoney(dailyAvg)),
              MetricTileData(label: 'Busiest day', value: busiestLabel),
            ],
          ),
        ],
      ),
    );
  }
}
