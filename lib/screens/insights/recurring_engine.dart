import 'dart:math';

import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:flutter/material.dart';

/// A charge that appears to repeat on a roughly monthly cadence with a stable
/// amount — i.e. a likely subscription or bill.
@immutable
class RecurringItem {
  final String name;
  final String categoryName;
  final double typicalAmount;
  final int occurrences;
  final int distinctMonths;
  final DateTime lastDate;

  const RecurringItem({
    required this.name,
    required this.categoryName,
    required this.typicalAmount,
    required this.occurrences,
    required this.distinctMonths,
    required this.lastDate,
  });
}

/// Detects likely recurring charges by grouping transactions with the same
/// description and keeping groups that (a) appear in at least 3 distinct months
/// within the last 12 months and (b) have a stable amount (low variation).
/// Pure and deterministic given [now] for easy testing.
List<RecurringItem> detectRecurringExpenses({
  required List<Transaction> allTransactions,
  DateTime? now,
}) {
  final today = now ?? DateTime.now();
  final windowStart = DateTime(today.year, today.month - 11);

  final groups = <String, List<Transaction>>{};
  for (final t in allTransactions) {
    final date = t.dateTime;
    if (date == null) continue;
    if (date.isBefore(windowStart)) continue;
    final raw = t.transactionComment?.trim();
    if (raw == null || raw.isEmpty) continue;
    groups.putIfAbsent(raw.toLowerCase(), () => []).add(t);
  }

  final items = <RecurringItem>[];
  groups.forEach((_, txns) {
    final distinctMonths =
        txns.map((t) => t.dateTime!.year * 12 + t.dateTime!.month).toSet();
    if (distinctMonths.length < 3) return;

    final amounts = txns.map((t) => t.transactionAmount).toList();
    final mean = amounts.reduce((a, b) => a + b) / amounts.length;
    if (mean <= 0) return;
    final variance = amounts
            .map((a) => (a - mean) * (a - mean))
            .reduce((a, b) => a + b) /
        amounts.length;
    final coefficientOfVariation = sqrt(variance) / mean;
    if (coefficientOfVariation > 0.2) return;

    final mostRecent =
        txns.reduce((a, b) => a.dateTime!.isAfter(b.dateTime!) ? a : b);

    items.add(RecurringItem(
      name: (mostRecent.transactionComment ?? '').trim(),
      categoryName: mostRecent.category.categoryName,
      typicalAmount: _median(amounts),
      occurrences: txns.length,
      distinctMonths: distinctMonths.length,
      lastDate: mostRecent.dateTime!,
    ));
  });

  items.sort((a, b) => b.typicalAmount.compareTo(a.typicalAmount));
  return items;
}

/// Estimated monthly cost of all detected recurring charges.
double estimatedMonthlyRecurringCost(List<RecurringItem> items) {
  return items.fold<double>(0, (sum, item) => sum + item.typicalAmount);
}

double _median(List<double> values) {
  final sorted = [...values]..sort();
  final mid = sorted.length ~/ 2;
  if (sorted.length.isOdd) return sorted[mid];
  return (sorted[mid - 1] + sorted[mid]) / 2;
}
