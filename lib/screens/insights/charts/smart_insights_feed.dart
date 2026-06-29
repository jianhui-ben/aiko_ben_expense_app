import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/screens/insights/household_budget_builder.dart';
import 'package:aiko_ben_expense_app/screens/insights/insight_engine.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const int _kMaxInsights = 6;

/// The hero of the redesigned Insights page: a horizontal feed of auto-generated,
/// plain-language takeaways. Leads with "the answer" before any raw chart.
/// Renders nothing when there's nothing meaningful to surface yet.
class SmartInsightsFeed extends StatelessWidget {
  const SmartInsightsFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final allTransactions = Provider.of<List<Transaction>?>(context) ?? [];
    return HouseholdBudgetBuilder(
      builder: (context, budget) =>
          _buildFor(context, allTransactions, budget),
    );
  }

  Widget _buildFor(
    BuildContext context,
    List<Transaction> allTransactions,
    double budget,
  ) {
    final theme = Theme.of(context);
    final insights = buildSpendingInsights(
      allTransactions: allTransactions,
      monthlyBudget: budget,
    );

    if (insights.isEmpty) return const SizedBox.shrink();

    final shown = insights.take(_kMaxInsights).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Insights', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 132,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: EdgeInsets.zero,
            itemCount: shown.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) => _InsightCard(insight: shown[index]),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

Color _toneColor(InsightTone tone) {
  switch (tone) {
    case InsightTone.alert:
      return AppColors.error;
    case InsightTone.good:
      return AppColors.secondary;
    case InsightTone.info:
      return AppColors.primary;
    case InsightTone.neutral:
      return AppColors.textSecondary;
  }
}

class _InsightCard extends StatelessWidget {
  final Insight insight;

  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _toneColor(insight.tone);

    return Container(
      width: 264,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(insight.icon, size: 16, color: color),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  insight.title,
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: Text(
              insight.body,
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
