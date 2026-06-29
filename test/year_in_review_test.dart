import 'package:aiko_ben_expense_app/screens/insights/year_in_review_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'insights_test_helpers.dart';

void main() {
  final grocery = cat('1', 'Grocery');
  final restaurant = cat('4', 'Restaurant');
  final travel = cat('3', 'Travel');

  final now = DateTime(2026, 6, 15);

  test('aggregates the year-to-date recap and compares with last year', () {
    final transactions = [
      // This year (2026): total 800.
      tx(category: grocery, amount: 100, date: DateTime(2026, 1, 10), by: 'Ben'),
      tx(category: restaurant, amount: 200, date: DateTime(2026, 2, 14), by: 'Aiko'),
      tx(category: travel, amount: 500, date: DateTime(2026, 3, 20), by: 'Ben'),
      // Last year to date (through Jun 15, 2025): total 400.
      tx(category: grocery, amount: 100, date: DateTime(2025, 1, 10), by: 'Ben'),
      tx(category: restaurant, amount: 300, date: DateTime(2025, 5, 1), by: 'Aiko'),
      // Last year AFTER the cutoff — must not count toward the comparison.
      tx(category: travel, amount: 900, date: DateTime(2025, 12, 1), by: 'Ben'),
    ];

    final data = buildYearInReview(allTransactions: transactions, now: now);

    expect(data.year, 2026);
    expect(data.total, 800);
    expect(data.transactionCount, 3);
    expect(data.hasData, isTrue);

    // 800 vs 400 last-year-to-date = +100%.
    expect(data.deltaVsLastYear, isNotNull);
    expect(data.deltaVsLastYear!, closeTo(100, 0.001));

    expect(data.biggestCategoryName, 'Travel');
    expect(data.biggestCategoryAmount, 500);
    expect(data.busiestMonthLabel, 'March');
    expect(data.mostExpensiveDayAmount, 500);
    expect(data.biggestPurchase?.transactionAmount, 500);

    // Ben logged 600 of 800 attributed -> top contributor at 75%.
    expect(data.topContributorName, 'Ben');
    expect(data.topContributorShare, closeTo(75, 0.001));

    expect(data.noSpendDays, greaterThan(0));
  });

  test('hasData is false with no transactions', () {
    final data = buildYearInReview(allTransactions: const [], now: now);
    expect(data.hasData, isFalse);
    expect(data.total, 0);
  });
}
