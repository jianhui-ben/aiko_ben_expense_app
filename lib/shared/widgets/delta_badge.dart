import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Compact pill showing period-over-period change. Up is framed as "more
/// spending" (error/red), down as "less" (secondary/green), and near-zero as
/// neutral. When [delta] is null there is no baseline to compare against; the
/// badge either renders [fallbackLabel] (e.g. on the hero) or nothing.
class DeltaBadge extends StatelessWidget {
  final double? delta;
  final bool showSuffix;
  final String fallbackLabel;
  final bool showFallback;

  const DeltaBadge({
    super.key,
    required this.delta,
    this.showSuffix = false,
    this.fallbackLabel = 'vs last month',
    this.showFallback = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = delta;

    if (value == null) {
      if (!showFallback) return const SizedBox.shrink();
      return Text(fallbackLabel, style: theme.textTheme.bodySmall);
    }

    final isFlat = value.abs() < 0.5;
    final isUp = value > 0;
    final color = isFlat
        ? AppColors.textSecondary
        : isUp
            ? AppColors.error
            : AppColors.secondary;
    final icon = isFlat
        ? Icons.remove
        : isUp
            ? Icons.arrow_upward
            : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            '${value.abs().toStringAsFixed(0)}%${showSuffix ? ' vs last mo' : ''}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
