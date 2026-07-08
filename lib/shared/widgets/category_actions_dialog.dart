import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/services/category_service.dart';
import 'package:flutter/material.dart';

Future<void> confirmHideCategory({
  required BuildContext context,
  required String householdId,
  required Category category,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hide category?'),
      content: Text(
        '"${category.categoryName}" will be removed from Home suggestions but kept for past transactions.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Hide'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await updateHouseholdCategoryHidden(householdId, category.categoryId, true);
  }
}

Future<void> confirmUnhideCategory({
  required BuildContext context,
  required String householdId,
  required Category category,
}) async {
  await updateHouseholdCategoryHidden(householdId, category.categoryId, false);
}

Future<void> confirmDeleteCategory({
  required BuildContext context,
  required String householdId,
  required Category category,
  required Map<String, Category> allCategories,
}) async {
  final txnCount =
      await countTransactionsForCategory(householdId, category.categoryId);

  if (!context.mounted) return;

  if (txnCount == 0) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text('Permanently delete "${category.categoryName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await deleteHouseholdCategory(
        householdId: householdId,
        categoryId: category.categoryId,
      );
    }
    return;
  }

  final reassignmentTargets = allCategories.values
      .where((c) => c.categoryId != category.categoryId && !c.isHidden)
      .toList();

  if (reassignmentTargets.isEmpty) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Create another category before deleting one with transactions.',
        ),
      ),
    );
    return;
  }

  if (!context.mounted) return;
  final action = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Category has transactions'),
      content: Text(
        '"${category.categoryName}" has $txnCount transaction(s). Hide it or reassign transactions before deleting.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'cancel'),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'hide'),
          child: const Text('Hide'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'reassign'),
          child: const Text('Reassign & delete'),
        ),
      ],
    ),
  );

  if (action == 'hide') {
    await updateHouseholdCategoryHidden(householdId, category.categoryId, true);
    return;
  }

  if (action != 'reassign' || !context.mounted) return;

  final targetId = await showDialog<String>(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text('Reassign transactions to'),
      children: reassignmentTargets
          .map(
            (c) => SimpleDialogOption(
              onPressed: () => Navigator.pop(context, c.categoryId),
              child: Text(c.categoryName),
            ),
          )
          .toList(),
    ),
  );

  if (targetId != null) {
    await deleteHouseholdCategory(
      householdId: householdId,
      categoryId: category.categoryId,
      reassignToCategoryId: targetId,
    );
  }
}
