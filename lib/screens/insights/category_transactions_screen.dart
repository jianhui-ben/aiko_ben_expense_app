import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/screens/home/transactions_list/transaction_tile.dart';
import 'package:aiko_ben_expense_app/shared/util.dart';
import 'package:aiko_ben_expense_app/shared/widgets/app_scaffold.dart';
import 'package:aiko_ben_expense_app/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';

/// Drill-down reached by tapping a category in the insights breakdown. Shows
/// every transaction in that category for the given period. Receives a static
/// snapshot (the insights subtree's transaction stream isn't an ancestor of
/// pushed routes), so it does not live-update after edits — tapping a row still
/// opens the edit sheet via the global `User` provider.
class CategoryTransactionsScreen extends StatelessWidget {
  final Category category;
  final String periodLabel;
  final List<Transaction> transactions;

  const CategoryTransactionsScreen({
    super.key,
    required this.category,
    required this.periodLabel,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = Util.sortTransactionsByDateAndAmount([...transactions]);
    final total = Util.sumTotal(transactions);

    return AppScaffold(
      title: category.categoryName,
      subtitle:
          '$periodLabel · \$${total.toStringAsFixed(0)} · ${transactions.length} '
          '${transactions.length == 1 ? 'expense' : 'expenses'}',
      body: sorted.isEmpty
          ? const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No expenses',
              subtitle: 'There are no expenses in this category for this period.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xxxl,
              ),
              itemCount: sorted.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final transaction = sorted[index];
                final comment = transaction.transactionComment;
                return TransactionTile(
                  transactionId: transaction.transactionId,
                  selectedDate: transaction.dateTime ?? DateTime.now(),
                  transactionCategory: transaction.category,
                  transactionComment: (comment != null && comment.isNotEmpty)
                      ? comment
                      : transaction.category.categoryName,
                  transactionAmount: transaction.transactionAmount,
                  createdByName: transaction.createdByName,
                );
              },
            ),
    );
  }
}
