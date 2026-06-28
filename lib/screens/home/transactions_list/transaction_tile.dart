import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/screens/single_transaction/add_or_edit_single_transaction.dart';
import 'package:aiko_ben_expense_app/shared/widgets/amount_text.dart';
import 'package:aiko_ben_expense_app/shared/widgets/app_card.dart';
import 'package:aiko_ben_expense_app/shared/widgets/member_avatar.dart';
import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  final DateTime selectedDate;
  final Category transactionCategory;
  final String transactionComment;
  final double transactionAmount;
  final String transactionId;
  final String? createdByName;

  const TransactionTile({
    super.key,
    required this.selectedDate,
    required this.transactionCategory,
    required this.transactionComment,
    required this.transactionAmount,
    required this.transactionId,
    this.createdByName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasMember = createdByName != null && createdByName!.trim().isNotEmpty;

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      onTap: () => _openEditSheet(context),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: IconTheme(
              data: const IconThemeData(
                color: AppColors.categoryAccent,
                size: 20,
              ),
              child: transactionCategory.categoryIcon,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transactionComment,
                  style: theme.textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasMember) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MemberAvatar(name: createdByName!, size: 16),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          createdByName!,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          AmountText(
            amount: transactionAmount,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  void _openEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints.loose(
        Size(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height * 0.6,
        ),
      ),
      builder: (context) {
        return AddOrEditSingleTransaction(
          category: transactionCategory,
          transactionComment: transactionComment,
          transactionAmount: transactionAmount,
          selectedDate: selectedDate,
          transactionId: transactionId,
        );
      },
    );
  }
}
