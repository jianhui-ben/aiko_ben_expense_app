import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'amount_text.dart';

class SummaryCard extends StatelessWidget {
  final double dailyTotal;
  final double monthlyTotal;
  final double monthlyBudget;

  const SummaryCard({
    super.key,
    required this.dailyTotal,
    required this.monthlyTotal,
    required this.monthlyBudget,
  });

  double get _remaining => monthlyBudget - monthlyTotal;

  double get _budgetPercent {
    if (monthlyBudget <= 0) return 0;
    return (monthlyTotal / monthlyBudget).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = _remaining;
    final overBudget = remaining < 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Spending', style: theme.textTheme.labelMedium),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _Stat(label: 'Today', amount: dailyTotal, theme: theme),
                    const SizedBox(width: AppSpacing.xxl),
                    _Stat(label: 'Month', amount: monthlyTotal, theme: theme),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  overBudget
                      ? '${_formatCurrency(remaining.abs())} over budget'
                      : '${_formatCurrency(remaining)} left',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: overBudget ? AppColors.error : AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          CircularPercentIndicator(
            radius: 36,
            lineWidth: 8,
            percent: _budgetPercent,
            center: Text(
              '${(_budgetPercent * 100).round()}%',
              style: theme.textTheme.labelSmall,
            ),
            progressColor: overBudget ? AppColors.error : AppColors.primary,
            backgroundColor: AppColors.primaryContainer,
            circularStrokeCap: CircularStrokeCap.round,
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(0)}';
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final double amount;
  final ThemeData theme;

  const _Stat({
    required this.label,
    required this.amount,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        AmountText(
          amount: amount,
          style: theme.textTheme.headlineSmall?.copyWith(fontSize: 18),
        ),
      ],
    );
  }
}
