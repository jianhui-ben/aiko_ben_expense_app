import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/shared/util.dart';
import 'package:intl/intl.dart';

/// The three time windows the Insights page can be viewed through.
enum InsightPeriod { week, month, year }

/// Resolves a period into its transaction sets and a human label, plus the
/// comparable previous window used for period-over-period deltas. Keeping this
/// in one place lets the generic modules (category breakdown, household split)
/// behave correctly on every tab without duplicating date math.
class PeriodRange {
  final InsightPeriod period;
  final String label;

  /// Transactions inside the current window.
  final List<Transaction> current;

  /// Transactions inside the previous comparable window (same length / same
  /// point-in-period), used for fair deltas.
  final List<Transaction> comparison;

  const PeriodRange({
    required this.period,
    required this.label,
    required this.current,
    required this.comparison,
  });

  factory PeriodRange.of(
    InsightPeriod period,
    List<Transaction> all, {
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final day = DateTime(today.year, today.month, today.day);

    switch (period) {
      case InsightPeriod.week:
        final start = day.subtract(const Duration(days: 6));
        final prevEnd = day.subtract(const Duration(days: 7));
        final prevStart = day.subtract(const Duration(days: 13));
        return PeriodRange(
          period: period,
          label: 'Last 7 days',
          current: Util.filterTransactionListToDateRange(all, start, day),
          comparison:
              Util.filterTransactionListToDateRange(all, prevStart, prevEnd),
        );

      case InsightPeriod.month:
        final thisMonth = DateTime(today.year, today.month);
        final lastMonth = DateTime(today.year, today.month - 1);
        return PeriodRange(
          period: period,
          label: DateFormat('MMMM yyyy').format(thisMonth),
          current: Util.filterTransactionListToMonthOf(all, thisMonth),
          comparison: Util.filterTransactionListToMonthToDate(
              all, lastMonth, today.day),
        );

      case InsightPeriod.year:
        final lastYearStart = DateTime(today.year - 1);
        final lastYearCutoff = DateTime(today.year - 1, today.month, today.day);
        return PeriodRange(
          period: period,
          label: '${today.year}',
          current: Util.filterTransactionListToYear(all, today),
          comparison: Util.filterTransactionListToDateRange(
              all, lastYearStart, lastYearCutoff),
        );
    }
  }
}
