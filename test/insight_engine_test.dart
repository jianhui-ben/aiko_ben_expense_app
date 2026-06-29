import 'package:aiko_ben_expense_app/screens/insights/insight_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import 'insights_test_helpers.dart';

void main() {
  final grocery = cat('1', 'Grocery');
  final restaurant = cat('4', 'Restaurant');

  // Mid-month so projections and to-date comparisons are exercised.
  final now = DateTime(2026, 6, 15);

  List<String> titlesOf(List<Insight> insights) =>
      insights.map((i) => i.title).toList();

  test('returns nothing when there is no spend this month', () {
    final result = buildSpendingInsights(
      allTransactions: const [],
      monthlyBudget: 1000,
      now: now,
    );
    expect(result, isEmpty);
  });

  test('flags over-budget pacing, fastest-growing and dominant categories', () {
    final transactions = [
      // This month (June 2026): total 800.
      tx(category: restaurant, amount: 300, date: DateTime(2026, 6, 5)),
      tx(category: grocery, amount: 500, date: DateTime(2026, 6, 10)),
      // Last month to date (through the 15th): total 400.
      tx(category: restaurant, amount: 100, date: DateTime(2026, 5, 5)),
      tx(category: grocery, amount: 300, date: DateTime(2026, 5, 10)),
      // After the cutoff last month — must NOT affect the to-date comparison.
      tx(category: grocery, amount: 1000, date: DateTime(2026, 5, 20)),
    ];

    final insights = buildSpendingInsights(
      allTransactions: transactions,
      monthlyBudget: 1000,
      now: now,
    );
    final titles = titlesOf(insights);

    // projected = 800 / 15 * 30 = 1600 > budget 1000.
    expect(titles, contains('Heading over budget'));
    // Restaurant grew 200% (100 -> 300), the steepest climb.
    expect(titles.any((t) => t.contains('Restaurant') && t.contains('climbing')),
        isTrue);
    // Grocery is 500/800 = 62.5% of spend.
    expect(titles.any((t) => t.contains('Grocery') && t.contains('leads')),
        isTrue);
  });

  test('reports on-track pacing when projected spend is under budget', () {
    final transactions = [
      tx(category: grocery, amount: 100, date: DateTime(2026, 6, 10)),
    ];

    final insights = buildSpendingInsights(
      allTransactions: transactions,
      monthlyBudget: 1000,
      now: now,
    );

    // projected = 100 / 15 * 30 = 200, well under 1000.
    expect(titlesOf(insights), contains('On track'));
  });
}
