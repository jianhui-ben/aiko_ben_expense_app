import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

String formatMoney(double amount) => '\$${amount.toStringAsFixed(0)}';

/// A budget/target pacing bar with a caption row, shared by the overview heroes.
class BudgetBar extends StatelessWidget {
  final double spent;
  final double budget;

  /// Noun used in the caption, e.g. "budget" or "weekly target".
  final String targetNoun;

  const BudgetBar({
    super.key,
    required this.spent,
    required this.budget,
    this.targetNoun = 'budget',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final over = spent > budget;
    final percent = budget <= 0 ? 0.0 : (spent / budget).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearPercentIndicator(
          padding: EdgeInsets.zero,
          lineHeight: 10,
          percent: percent,
          barRadius: const Radius.circular(AppRadius.sm),
          progressColor: over ? AppColors.error : AppColors.primary,
          backgroundColor: AppColors.surfaceVariant,
          animation: true,
          animationDuration: 600,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Text('${(percent * 100).round()}% of $targetNoun used',
                style: theme.textTheme.bodySmall),
            const Spacer(),
            Text('${formatMoney(spent)} / ${formatMoney(budget)}',
                style: theme.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}

class MetricTileData {
  final String label;
  final String value;
  final Color color;

  const MetricTileData({
    required this.label,
    required this.value,
    this.color = AppColors.textPrimary,
  });
}

/// A row of equal-width metric tiles separated by hairline dividers.
class MetricTilesRow extends StatelessWidget {
  final List<MetricTileData> tiles;

  const MetricTilesRow({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < tiles.length; i++) {
      if (i > 0) {
        children.add(Container(width: 1, height: 36, color: AppColors.border));
      }
      children.add(Expanded(child: _MetricTile(data: tiles[i])));
    }
    return Row(children: children);
  }
}

class _MetricTile extends StatelessWidget {
  final MetricTileData data;

  const _MetricTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(data.label, style: theme.textTheme.labelSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          data.value,
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontSize: 18, color: data.color),
        ),
      ],
    );
  }
}
