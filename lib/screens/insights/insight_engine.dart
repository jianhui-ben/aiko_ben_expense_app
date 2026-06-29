import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/shared/util.dart';
import 'package:flutter/material.dart';

/// Semantic tone for a generated insight. Drives the card's accent color.
enum InsightTone { alert, good, info, neutral }

/// A single plain-language takeaway shown in the smart insights feed.
@immutable
class Insight {
  final InsightTone tone;
  final IconData icon;
  final String title;
  final String body;

  const Insight({
    required this.tone,
    required this.icon,
    required this.title,
    required this.body,
  });
}

String _money(double amount) => '\$${amount.abs().toStringAsFixed(0)}';

/// Rule-based generator that turns the household ledger into a prioritized list
/// of narrative insights. Pure and deterministic given [now], so it can be unit
/// tested without Firebase or widgets. Returns an empty list when there's
/// nothing meaningful to say (e.g. no spend yet this month).
List<Insight> buildSpendingInsights({
  required List<Transaction> allTransactions,
  required double monthlyBudget,
  DateTime? now,
}) {
  final today = now ?? DateTime.now();
  final thisMonth = DateTime(today.year, today.month);
  final lastMonth = DateTime(today.year, today.month - 1);
  final cutoffDay = today.day;
  final daysThisMonth = Util.daysInMonth(thisMonth);

  final thisTxns = Util.filterTransactionListToMonthOf(allTransactions, thisMonth);
  final total = Util.sumTotal(thisTxns);

  // Nothing to say with an empty month.
  if (thisTxns.isEmpty || total <= 0) return const [];

  final lastToDateTxns =
      Util.filterTransactionListToMonthToDate(allTransactions, lastMonth, cutoffDay);
  final lastTotal = Util.sumTotal(lastToDateTxns);
  final projected = cutoffDay > 0 ? total / cutoffDay * daysThisMonth : total;

  final insights = <Insight>[];

  // 1. Budget pacing.
  if (monthlyBudget > 0) {
    if (projected > monthlyBudget * 1.02) {
      insights.add(Insight(
        tone: InsightTone.alert,
        icon: Icons.warning_amber_rounded,
        title: 'Heading over budget',
        body:
            'At this pace you\'ll spend ${_money(projected)} — about ${_money(projected - monthlyBudget)} '
            'over your ${_money(monthlyBudget)} budget.',
      ));
    } else if (total <= monthlyBudget) {
      insights.add(Insight(
        tone: InsightTone.good,
        icon: Icons.check_circle_outline,
        title: 'On track',
        body:
            'You\'re pacing about ${_money(monthlyBudget - projected)} under your '
            '${_money(monthlyBudget)} budget.',
      ));
    }
  }

  // 2. Fastest-growing and notably-shrinking categories.
  final thisByCat = _aggregateByCategory(thisTxns);
  final lastByCat = <String, double>{};
  for (final t in lastToDateTxns) {
    lastByCat[t.category.categoryId] =
        (lastByCat[t.category.categoryId] ?? 0) + t.transactionAmount;
  }

  _CategoryAgg? topGrower;
  double topGrowerDelta = 0;
  _CategoryAgg? topSaver;
  double topSaverDelta = 0;
  for (final agg in thisByCat.values) {
    final prev = lastByCat[agg.id] ?? 0;
    final delta = Util.percentChange(agg.amount, prev);
    if (delta == null) continue;
    if (delta >= 20 && agg.amount >= 20 && delta > topGrowerDelta) {
      topGrower = agg;
      topGrowerDelta = delta;
    }
    if (delta <= -25 && prev >= 20 && delta < topSaverDelta) {
      topSaver = agg;
      topSaverDelta = delta;
    }
  }
  if (topGrower != null) {
    insights.add(Insight(
      tone: InsightTone.alert,
      icon: Icons.trending_up,
      title: '${topGrower.name} is climbing',
      body:
          '${topGrower.name} is up ${topGrowerDelta.toStringAsFixed(0)}% vs the same point last month.',
    ));
  }
  if (topSaver != null) {
    insights.add(Insight(
      tone: InsightTone.good,
      icon: Icons.trending_down,
      title: 'Nice cut on ${topSaver.name}',
      body:
          'You\'ve spent ${topSaverDelta.abs().toStringAsFixed(0)}% less on ${topSaver.name} than last month.',
    ));
  }

  // 3. Dominant category.
  final sortedCats = thisByCat.values.toList()
    ..sort((a, b) => b.amount.compareTo(a.amount));
  if (sortedCats.isNotEmpty) {
    final leader = sortedCats.first;
    final share = total <= 0 ? 0.0 : (leader.amount / total) * 100;
    if (share >= 25 && leader != topGrower) {
      insights.add(Insight(
        tone: InsightTone.info,
        icon: Icons.donut_large,
        title: '${leader.name} leads your spending',
        body:
            '${leader.name} is ${share.toStringAsFixed(0)}% of this month\'s spend (${_money(leader.amount)}).',
      ));
    }
  }

  // 4. Overall pace vs the same point last month.
  final overallDelta = Util.percentChange(total, lastTotal);
  if (overallDelta != null && overallDelta.abs() >= 10) {
    if (overallDelta > 0) {
      insights.add(Insight(
        tone: InsightTone.info,
        icon: Icons.south_east,
        title: 'Spending up overall',
        body:
            'You\'ve spent ${overallDelta.toStringAsFixed(0)}% more than this point last month.',
      ));
    } else {
      insights.add(Insight(
        tone: InsightTone.good,
        icon: Icons.north_east,
        title: 'Spending down overall',
        body:
            'You\'re ${overallDelta.abs().toStringAsFixed(0)}% below where you were last month.',
      ));
    }
  }

  // 5. Compared with the rolling 6-month average.
  final avg = _sixMonthAverage(allTransactions, today);
  if (avg > 0) {
    if (projected >= avg * 1.15) {
      insights.add(Insight(
        tone: InsightTone.info,
        icon: Icons.show_chart,
        title: 'Above your average',
        body:
            'This month is tracking above your 6-month average of ${_money(avg)}/mo.',
      ));
    } else if (projected <= avg * 0.85) {
      insights.add(Insight(
        tone: InsightTone.good,
        icon: Icons.show_chart,
        title: 'Below your average',
        body:
            'This month is tracking below your 6-month average of ${_money(avg)}/mo.',
      ));
    }
  }

  // 6. Household contribution.
  final byMember = <String, double>{};
  for (final t in thisTxns) {
    final name = t.createdByName?.trim();
    if (name == null || name.isEmpty) continue;
    byMember[name] = (byMember[name] ?? 0) + t.transactionAmount;
  }
  if (byMember.length >= 2) {
    final attributed = byMember.values.fold<double>(0, (s, v) => s + v);
    final top = byMember.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final share = attributed <= 0 ? 0.0 : (top.value / attributed) * 100;
    if (share >= 55) {
      insights.add(Insight(
        tone: InsightTone.info,
        icon: Icons.group_outlined,
        title: '${top.key} is logging more',
        body:
            '${top.key} has logged ${share.toStringAsFixed(0)}% of this month\'s spend.',
      ));
    }
  }

  // 7. Standout single purchase.
  final biggest =
      thisTxns.reduce((a, b) => a.transactionAmount >= b.transactionAmount ? a : b);
  if (biggest.transactionAmount >= 50 &&
      biggest.transactionAmount >= total * 0.2) {
    final comment = biggest.transactionComment?.trim();
    final detail = (comment != null && comment.isNotEmpty)
        ? '$comment (${biggest.category.categoryName})'
        : biggest.category.categoryName;
    insights.add(Insight(
      tone: InsightTone.neutral,
      icon: Icons.receipt_long_outlined,
      title: 'Biggest purchase',
      body: '${_money(biggest.transactionAmount)} on $detail.',
    ));
  }

  return insights;
}

class _CategoryAgg {
  final String id;
  final String name;
  double amount;

  _CategoryAgg(this.id, this.name, this.amount);
}

Map<String, _CategoryAgg> _aggregateByCategory(List<Transaction> transactions) {
  final map = <String, _CategoryAgg>{};
  for (final t in transactions) {
    final id = t.category.categoryId;
    final existing = map[id];
    if (existing == null) {
      map[id] = _CategoryAgg(id, t.category.categoryName, t.transactionAmount);
    } else {
      existing.amount += t.transactionAmount;
    }
  }
  return map;
}

double _sixMonthAverage(List<Transaction> allTransactions, DateTime today) {
  final months = [
    for (int i = 5; i >= 0; i--) DateTime(today.year, today.month - i),
  ];
  final totals = months
      .map((m) => Util.sumTotal(Util.filterTransactionListToMonthOf(allTransactions, m)))
      .where((t) => t > 0)
      .toList();
  if (totals.isEmpty) return 0;
  return totals.fold<double>(0, (s, v) => s + v) / totals.length;
}
