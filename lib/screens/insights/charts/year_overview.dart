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
import 'package:provider/provider.dart';

/// Year hero: spend year-to-date, vs the same point last year, paced against an
/// annual budget (monthly × 12), plus monthly average and a projected year-end.
class YearOverview extends StatelessWidget {
  const YearOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final allTransactions = Provider.of<List<Transaction>?>(context) ?? [];
    final now = DateTime.now();
    final range = PeriodRange.of(InsightPeriod.year, allTransactions, now: now);

    final spent = Util.sumTotal(range.current);
    final previous = Util.sumTotal(range.comparison);
    final delta = Util.percentChange(spent, previous);

    final monthsElapsed = now.month;
    final monthlyAvg = monthsElapsed > 0 ? spent / monthsElapsed : spent;

    final startOfYear = DateTime(now.year);
    final dayOfYear = now.difference(startOfYear).inDays + 1;
    final daysInYear =
        DateTime(now.year + 1).difference(startOfYear).inDays;
    final projected = dayOfYear > 0 ? spent / dayOfYear * daysInYear : spent;

    return HouseholdBudgetBuilder(
      builder: (context, monthlyBudget) {
        final annualBudget = monthlyBudget * 12;
        return _card(context, spent, delta, monthlyAvg, projected,
            annualBudget, range.label);
      },
    );
  }

  Widget _card(
    BuildContext context,
    double spent,
    double? delta,
    double monthlyAvg,
    double projected,
    double annualBudget,
    String rangeLabel,
  ) {
    final theme = Theme.of(context);
    final overProjected = projected > annualBudget;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Spent in $rangeLabel', style: theme.textTheme.labelMedium),
              const Spacer(),
              Text('Year to date', style: theme.textTheme.bodySmall),
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
                  fallbackLabel: 'vs last year',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          BudgetBar(
            spent: spent,
            budget: annualBudget,
            targetNoun: 'annual budget',
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.lg),
          MetricTilesRow(
            tiles: [
              MetricTileData(
                  label: 'Monthly average', value: formatMoney(monthlyAvg)),
              MetricTileData(
                label: 'Projected year-end',
                value: formatMoney(projected),
                color: overProjected ? AppColors.error : AppColors.textPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
