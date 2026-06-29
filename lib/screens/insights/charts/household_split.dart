import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/screens/insights/period_range.dart';
import 'package:aiko_ben_expense_app/shared/widgets/app_card.dart';
import 'package:aiko_ben_expense_app/shared/widgets/member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Who logged what in the period. Unique to a shared household app — turns the
/// existing `createdByName` field into a transparency view and the foundation
/// for a future "settle up" feature. Hidden when spend isn't attributed.
class HouseholdSplit extends StatelessWidget {
  final InsightPeriod period;

  const HouseholdSplit({super.key, required this.period});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allTransactions = Provider.of<List<Transaction>?>(context) ?? [];
    final range = PeriodRange.of(period, allTransactions);

    final byMember = <String, double>{};
    for (final t in range.current) {
      final name = t.createdByName?.trim();
      if (name == null || name.isEmpty) continue;
      byMember[name] = (byMember[name] ?? 0) + t.transactionAmount;
    }

    // A "split" needs at least two attributed contributors.
    if (byMember.length < 2) return const SizedBox.shrink();

    final members = byMember.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final attributed = members.fold<double>(0, (s, e) => s + e.value);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Household split', style: theme.textTheme.titleMedium),
              const Spacer(),
              Text(range.label, style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _ProportionBar(members: members, total: attributed),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < members.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            _MemberRow(
              name: members[i].key,
              amount: members[i].value,
              share: attributed <= 0 ? 0 : (members[i].value / attributed) * 100,
              color: AppColors.chartColorAt(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProportionBar extends StatelessWidget {
  final List<MapEntry<String, double>> members;
  final double total;

  const _ProportionBar({required this.members, required this.total});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Row(
        children: [
          for (var i = 0; i < members.length; i++)
            Expanded(
              flex: (members[i].value * 100).round().clamp(1, 1 << 30),
              child: Container(
                height: 10,
                color: AppColors.chartColorAt(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  final String name;
  final double amount;
  final double share;
  final Color color;

  const _MemberRow({
    required this.name,
    required this.amount,
    required this.share,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        MemberAvatar(name: name, size: 32),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text('${share.toStringAsFixed(0)}% of spend',
                      style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
        Text('\$${amount.toStringAsFixed(0)}', style: theme.textTheme.titleMedium),
      ],
    );
  }
}
