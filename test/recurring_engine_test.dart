import 'package:aiko_ben_expense_app/screens/insights/recurring_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import 'insights_test_helpers.dart';

void main() {
  final subscription = cat('14', 'Subscription');
  final grocery = cat('1', 'Grocery');
  final house = cat('2', 'House');

  final now = DateTime(2026, 6, 15);

  test('detects a stable monthly charge and ignores one-offs and noisy spend',
      () {
    final transactions = [
      // Netflix: stable amount across 4 distinct months -> recurring.
      tx(category: subscription, amount: 20.0, date: DateTime(2026, 3, 3), comment: 'Netflix'),
      tx(category: subscription, amount: 20.5, date: DateTime(2026, 4, 3), comment: 'Netflix'),
      tx(category: subscription, amount: 19.5, date: DateTime(2026, 5, 3), comment: 'Netflix'),
      tx(category: subscription, amount: 20.0, date: DateTime(2026, 6, 3), comment: 'Netflix'),
      // Grocery: 3 distinct months but wildly varying amounts -> excluded.
      tx(category: grocery, amount: 50, date: DateTime(2026, 1, 10), comment: 'Grocery run'),
      tx(category: grocery, amount: 300, date: DateTime(2026, 2, 10), comment: 'Grocery run'),
      tx(category: grocery, amount: 120, date: DateTime(2026, 3, 10), comment: 'Grocery run'),
      // One-off -> excluded.
      tx(category: house, amount: 400, date: DateTime(2026, 4, 22), comment: 'Plumber'),
    ];

    final items = detectRecurringExpenses(allTransactions: transactions, now: now);
    final names = items.map((i) => i.name).toList();

    expect(names, contains('Netflix'));
    expect(names, isNot(contains('Grocery run')));
    expect(names, isNot(contains('Plumber')));

    final netflix = items.firstWhere((i) => i.name == 'Netflix');
    expect(netflix.distinctMonths, 4);
    expect(netflix.typicalAmount, closeTo(20.0, 0.6));
    expect(estimatedMonthlyRecurringCost(items), closeTo(20.0, 0.6));
  });

  test('ignores charges older than the 12-month window', () {
    final transactions = [
      tx(category: subscription, amount: 20, date: DateTime(2024, 1, 3), comment: 'Old'),
      tx(category: subscription, amount: 20, date: DateTime(2024, 2, 3), comment: 'Old'),
      tx(category: subscription, amount: 20, date: DateTime(2024, 3, 3), comment: 'Old'),
    ];

    final items = detectRecurringExpenses(allTransactions: transactions, now: now);
    expect(items, isEmpty);
  });
}
