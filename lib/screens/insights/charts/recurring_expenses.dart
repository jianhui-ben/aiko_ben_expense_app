import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/screens/insights/recurring_engine.dart';
import 'package:aiko_ben_expense_app/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// "Likely recurring" — surfaces repeating, stable-amount charges (subscriptions
/// and bills) so the household can spot money leaks. Hidden when none detected.
class RecurringExpenses extends StatelessWidget {
  const RecurringExpenses({super.key});

  static const int _maxShown = 6;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allTransactions = Provider.of<List<Transaction>?>(context) ?? [];

    final items = detectRecurringExpenses(allTransactions: allTransactions);
    if (items.isEmpty) return const SizedBox.shrink();

    final shown = items.take(_maxShown).toList();
    final monthlyCost = estimatedMonthlyRecurringCost(shown);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Likely recurring', style: theme.textTheme.titleMedium),
              const Spacer(),
              Text('~\$${monthlyCost.toStringAsFixed(0)}/mo',
                  style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Detected from repeating charges',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < shown.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            _RecurringRow(item: shown[i]),
          ],
        ],
      ),
    );
  }
}

class _RecurringRow extends StatelessWidget {
  final RecurringItem item;

  const _RecurringRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.autorenew,
              size: 18, color: AppColors.categoryAccent),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: theme.textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Monthly · ${item.categoryName} · last ${DateFormat('MMM d').format(item.lastDate)}',
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text('\$${item.typicalAmount.toStringAsFixed(0)}',
            style: theme.textTheme.titleMedium),
      ],
    );
  }
}
