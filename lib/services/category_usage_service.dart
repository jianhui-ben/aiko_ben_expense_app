import 'package:aiko_ben_expense_app/models/transaction.dart' as app_transaction;

const int defaultUsageWindowDays = 30;
const int defaultHomeChipCount = 8;

/// Counts transactions per category within [windowDays] ending today.
Map<String, int> computeUsageCounts(
  List<app_transaction.Transaction> transactions, {
  int windowDays = defaultUsageWindowDays,
}) {
  final now = DateTime.now();
  final windowStart = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: windowDays));

  final counts = <String, int>{};
  for (final txn in transactions) {
    final date = txn.dateTime;
    if (date == null || date.isBefore(windowStart)) continue;
    final id = txn.category.categoryId;
    counts[id] = (counts[id] ?? 0) + 1;
  }
  return counts;
}

/// Pinned first, then most-used non-pinned. Reserves one slot for "+ More".
List<String> resolveHomeCategoryIds({
  required List<String> pinnedIds,
  required Map<String, int> usageCounts,
  required Set<String> hiddenIds,
  required Set<String> allCategoryIds,
  int maxVisible = defaultHomeChipCount,
}) {
  final result = pinnedIds
      .where((id) => allCategoryIds.contains(id) && !hiddenIds.contains(id))
      .toList();

  final maxCategorySlots = maxVisible - 1; // reserve "+ More"
  final remaining = allCategoryIds
      .where((id) => !hiddenIds.contains(id) && !result.contains(id))
      .toList()
    ..sort((a, b) => (usageCounts[b] ?? 0).compareTo(usageCounts[a] ?? 0));

  final slotsLeft = maxCategorySlots - result.length;
  if (slotsLeft > 0) {
    result.addAll(remaining.take(slotsLeft));
  }
  return result;
}

List<String> sortCategoryIdsByUsage({
  required Iterable<String> categoryIds,
  required Map<String, int> usageCounts,
}) {
  final ids = categoryIds.toList()
    ..sort((a, b) {
      final countCompare =
          (usageCounts[b] ?? 0).compareTo(usageCounts[a] ?? 0);
      if (countCompare != 0) return countCompare;
      return a.compareTo(b);
    });
  return ids;
}
