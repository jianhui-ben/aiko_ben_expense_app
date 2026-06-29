import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/shared/util.dart';
import 'package:aiko_ben_expense_app/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Gamifies frugal behavior: counts no-spend days this month, the current
/// streak, and the longest streak, with a small dot calendar (no-spend days
/// highlighted). Inspired by habit/streak views in consumer health apps.
class NoSpendStreak extends StatelessWidget {
  const NoSpendStreak({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allTransactions = Provider.of<List<Transaction>?>(context) ?? [];

    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final dayCount = now.day;
    final thisMonthTransactions =
        Util.filterTransactionListToMonthOf(allTransactions, thisMonth);

    // Don't show until there's at least a little history this month.
    if (thisMonthTransactions.isEmpty) return const SizedBox.shrink();

    final spendDays = <int>{};
    for (final t in thisMonthTransactions) {
      final date = t.dateTime;
      if (date == null) continue;
      if (date.day <= dayCount) spendDays.add(date.day);
    }

    var noSpendCount = 0;
    var longest = 0;
    var run = 0;
    var current = 0;
    var currentBroken = false;
    for (var day = 1; day <= dayCount; day++) {
      final noSpend = !spendDays.contains(day);
      if (noSpend) {
        noSpendCount++;
        run++;
        if (run > longest) longest = run;
      } else {
        run = 0;
      }
    }
    // Current streak: consecutive no-spend days counting back from today.
    for (var day = dayCount; day >= 1 && !currentBroken; day--) {
      if (!spendDays.contains(day)) {
        current++;
      } else {
        currentBroken = true;
      }
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No-spend days', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _StreakStat(
                  value: '$current',
                  label: 'Current streak',
                  highlight: current > 0,
                ),
              ),
              Container(width: 1, height: 36, color: AppColors.border),
              Expanded(
                child: _StreakStat(value: '$noSpendCount', label: 'This month'),
              ),
              Container(width: 1, height: 36, color: AppColors.border),
              Expanded(
                child: _StreakStat(value: '$longest', label: 'Longest'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _DotCalendar(dayCount: dayCount, spendDays: spendDays),
          const SizedBox(height: AppSpacing.md),
          Text(
            current > 0
                ? "You're on a $current-day no-spend streak — keep it going."
                : 'Every no-spend day adds up. Aim for a streak this week.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _StreakStat extends StatelessWidget {
  final String value;
  final String label;
  final bool highlight;

  const _StreakStat({
    required this.value,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontSize: 22,
            color: highlight ? AppColors.secondary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}

class _DotCalendar extends StatelessWidget {
  final int dayCount;
  final Set<int> spendDays;

  const _DotCalendar({required this.dayCount, required this.spendDays});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var day = 1; day <= dayCount; day++)
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: spendDays.contains(day)
                  ? AppColors.surfaceVariant
                  : AppColors.secondary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(4),
              border: spendDays.contains(day)
                  ? null
                  : Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
            ),
          ),
      ],
    );
  }
}
