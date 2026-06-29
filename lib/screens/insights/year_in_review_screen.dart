import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/shared/util.dart';
import 'package:aiko_ben_expense_app/shared/widgets/app_card.dart';
import 'package:aiko_ben_expense_app/shared/widgets/app_scaffold.dart';
import 'package:aiko_ben_expense_app/shared/widgets/delta_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Aggregated "Wrapped"-style recap of a year's spending. Pure and
/// deterministic given [now] so it can be unit tested.
class YearInReviewData {
  final int year;
  final double total;
  final double? deltaVsLastYear;
  final int transactionCount;
  final int noSpendDays;
  final String? biggestCategoryName;
  final double biggestCategoryAmount;
  final double biggestCategoryShare;
  final String? busiestMonthLabel;
  final double busiestMonthAmount;
  final DateTime? mostExpensiveDay;
  final double mostExpensiveDayAmount;
  final Transaction? biggestPurchase;
  final String? topContributorName;
  final double topContributorShare;

  const YearInReviewData({
    required this.year,
    required this.total,
    required this.deltaVsLastYear,
    required this.transactionCount,
    required this.noSpendDays,
    required this.biggestCategoryName,
    required this.biggestCategoryAmount,
    required this.biggestCategoryShare,
    required this.busiestMonthLabel,
    required this.busiestMonthAmount,
    required this.mostExpensiveDay,
    required this.mostExpensiveDayAmount,
    required this.biggestPurchase,
    required this.topContributorName,
    required this.topContributorShare,
  });

  bool get hasData => transactionCount > 0;
}

YearInReviewData buildYearInReview({
  required List<Transaction> allTransactions,
  DateTime? now,
}) {
  final today = now ?? DateTime.now();
  final year = today.year;

  final yearTxns = Util.filterTransactionListToYear(allTransactions, today);
  final total = Util.sumTotal(yearTxns);

  // vs last year, same point in the year (year-to-date fairness).
  final lastYearCutoff = DateTime(year - 1, today.month, today.day);
  final lastYearYtd = allTransactions.where((t) {
    final d = t.dateTime;
    return d != null && d.year == year - 1 && !d.isAfter(lastYearCutoff);
  }).fold<double>(0, (s, t) => s + t.transactionAmount);
  final delta = Util.percentChange(total, lastYearYtd);

  // Biggest category.
  final byCategory = <String, double>{};
  for (final t in yearTxns) {
    byCategory[t.category.categoryName] =
        (byCategory[t.category.categoryName] ?? 0) + t.transactionAmount;
  }
  String? biggestCategoryName;
  double biggestCategoryAmount = 0;
  byCategory.forEach((name, amount) {
    if (amount > biggestCategoryAmount) {
      biggestCategoryAmount = amount;
      biggestCategoryName = name;
    }
  });

  // Busiest month.
  final byMonth = <int, double>{};
  for (final t in yearTxns) {
    byMonth[t.dateTime!.month] =
        (byMonth[t.dateTime!.month] ?? 0) + t.transactionAmount;
  }
  String? busiestMonthLabel;
  double busiestMonthAmount = 0;
  byMonth.forEach((month, amount) {
    if (amount > busiestMonthAmount) {
      busiestMonthAmount = amount;
      busiestMonthLabel = DateFormat('MMMM').format(DateTime(year, month));
    }
  });

  // Most expensive day.
  final byDay = <DateTime, double>{};
  for (final t in yearTxns) {
    final d = t.dateTime!;
    final key = DateTime(d.year, d.month, d.day);
    byDay[key] = (byDay[key] ?? 0) + t.transactionAmount;
  }
  DateTime? mostExpensiveDay;
  double mostExpensiveDayAmount = 0;
  byDay.forEach((day, amount) {
    if (amount > mostExpensiveDayAmount) {
      mostExpensiveDayAmount = amount;
      mostExpensiveDay = day;
    }
  });

  // Biggest single purchase.
  Transaction? biggestPurchase;
  for (final t in yearTxns) {
    if (biggestPurchase == null ||
        t.transactionAmount > biggestPurchase.transactionAmount) {
      biggestPurchase = t;
    }
  }

  // No-spend days year-to-date.
  final daysElapsed = today.difference(DateTime(year)).inDays + 1;
  final noSpendDays = (daysElapsed - byDay.length).clamp(0, daysElapsed);

  // Top household contributor.
  final byMember = <String, double>{};
  for (final t in yearTxns) {
    final name = t.createdByName?.trim();
    if (name == null || name.isEmpty) continue;
    byMember[name] = (byMember[name] ?? 0) + t.transactionAmount;
  }
  String? topContributorName;
  double topContributorShare = 0;
  if (byMember.length >= 2) {
    final attributed = byMember.values.fold<double>(0, (s, v) => s + v);
    final top = byMember.entries.reduce((a, b) => a.value >= b.value ? a : b);
    topContributorName = top.key;
    topContributorShare = attributed <= 0 ? 0 : (top.value / attributed) * 100;
  }

  return YearInReviewData(
    year: year,
    total: total,
    deltaVsLastYear: delta,
    transactionCount: yearTxns.length,
    noSpendDays: noSpendDays,
    biggestCategoryName: biggestCategoryName,
    biggestCategoryAmount: biggestCategoryAmount,
    biggestCategoryShare:
        total <= 0 ? 0 : (biggestCategoryAmount / total) * 100,
    busiestMonthLabel: busiestMonthLabel,
    busiestMonthAmount: busiestMonthAmount,
    mostExpensiveDay: mostExpensiveDay,
    mostExpensiveDayAmount: mostExpensiveDayAmount,
    biggestPurchase: biggestPurchase,
    topContributorName: topContributorName,
    topContributorShare: topContributorShare,
  );
}

class YearInReviewScreen extends StatelessWidget {
  final List<Transaction> transactions;

  const YearInReviewScreen({super.key, required this.transactions});

  String _money(double amount) => '\$${amount.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final data = buildYearInReview(allTransactions: transactions);
    final theme = Theme.of(context);

    return AppScaffold(
      title: '${data.year} in Review',
      subtitle: 'Your year so far',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxxl,
        ),
        children: [
          _HeroCard(
            total: _money(data.total),
            delta: data.deltaVsLastYear,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Expenses logged',
                  value: '${data.transactionCount}',
                  accent: AppColors.chartColorAt(4),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _StatCard(
                  label: 'No-spend days',
                  value: '${data.noSpendDays}',
                  accent: AppColors.secondary,
                ),
              ),
            ],
          ),
          if (data.busiestMonthLabel != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _HighlightCard(
              icon: Icons.calendar_month,
              accent: AppColors.chartColorAt(2),
              label: 'Busiest month',
              value: data.busiestMonthLabel!,
              detail: '${_money(data.busiestMonthAmount)} spent',
            ),
          ],
          if (data.biggestCategoryName != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _HighlightCard(
              icon: Icons.donut_large,
              accent: AppColors.primary,
              label: 'Top category',
              value: data.biggestCategoryName!,
              detail:
                  '${_money(data.biggestCategoryAmount)} · ${data.biggestCategoryShare.toStringAsFixed(0)}% of spend',
            ),
          ],
          if (data.mostExpensiveDay != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _HighlightCard(
              icon: Icons.local_fire_department_outlined,
              accent: AppColors.error,
              label: 'Priciest day',
              value: DateFormat('EEEE, MMM d').format(data.mostExpensiveDay!),
              detail: '${_money(data.mostExpensiveDayAmount)} in one day',
            ),
          ],
          if (data.biggestPurchase != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _HighlightCard(
              icon: Icons.receipt_long_outlined,
              accent: AppColors.chartColorAt(5),
              label: 'Biggest single purchase',
              value: _money(data.biggestPurchase!.transactionAmount),
              detail: _purchaseDetail(data.biggestPurchase!),
            ),
          ],
          if (data.topContributorName != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _HighlightCard(
              icon: Icons.group_outlined,
              accent: AppColors.chartColorAt(3),
              label: 'Top contributor',
              value: data.topContributorName!,
              detail:
                  '${data.topContributorShare.toStringAsFixed(0)}% of logged spend',
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Text(
              'Recap updates as the year goes on',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  String _purchaseDetail(Transaction t) {
    final comment = t.transactionComment?.trim();
    if (comment != null && comment.isNotEmpty) {
      return '$comment · ${t.category.categoryName}';
    }
    return t.category.categoryName;
  }
}

class _HeroCard extends StatelessWidget {
  final String total;
  final double? delta;

  const _HeroCard({required this.total, required this.delta});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('You\'ve spent', style: theme.textTheme.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            total,
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          DeltaBadge(delta: delta, showFallback: true, fallbackLabel: 'vs last year'),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _StatCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineLarge?.copyWith(color: accent),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String label;
  final String value;
  final String detail;

  const _HighlightCard({
    required this.icon,
    required this.accent,
    required this.label,
    required this.value,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelSmall),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
