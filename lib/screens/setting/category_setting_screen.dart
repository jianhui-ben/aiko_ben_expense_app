import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/services/category_usage_service.dart';
import 'package:aiko_ben_expense_app/services/database.dart';
import 'package:aiko_ben_expense_app/shared/constants.dart';
import 'package:aiko_ben_expense_app/shared/loading.dart';
import 'package:aiko_ben_expense_app/shared/widgets/category_actions_dialog.dart';
import 'package:aiko_ben_expense_app/shared/widgets/category_editor_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategorySettingScreen extends StatefulWidget {
  const CategorySettingScreen({super.key});

  @override
  State<CategorySettingScreen> createState() => _CategorySettingScreenState();
}

class _CategorySettingScreenState extends State<CategorySettingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Category> _sortedCategories(
    Map<String, Category> categories,
    Map<String, int> usageCounts,
  ) {
    final ids = sortCategoryIdsByUsage(
      categoryIds: categories.keys,
      usageCounts: usageCounts,
    );
    return ids
        .map((id) => categories[id]!)
        .where((category) {
          if (_query.isEmpty) return true;
          return category.categoryName.toLowerCase().contains(_query);
        })
        .toList();
  }

  Future<void> _createCategory(
    String householdId,
    List<String> pinnedIds,
  ) async {
    await showCategoryEditorSheet(
      context: context,
      householdId: householdId,
      pinnedCategoryIds: pinnedIds,
      pinByDefault: false,
    );
  }

  Future<void> _editCategory(
    String householdId,
    Category category,
    List<String> pinnedIds,
  ) async {
    await showCategoryEditorSheet(
      context: context,
      householdId: householdId,
      category: category,
      pinnedCategoryIds: pinnedIds,
    );
  }

  Future<void> _showCategoryMenu({
    required String householdId,
    required Category category,
    required List<String> pinnedIds,
    required Map<String, Category> categories,
  }) async {
    final isPinned = pinnedIds.contains(category.categoryId);
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: Icon(isPinned ? Icons.push_pin_outlined : Icons.push_pin),
              title: Text(isPinned ? 'Unpin from Home' : 'Pin to Home'),
              onTap: () => Navigator.pop(context, isPinned ? 'unpin' : 'pin'),
            ),
            if (category.isHidden)
              ListTile(
                leading: const Icon(Icons.visibility_outlined),
                title: const Text('Unhide'),
                onTap: () => Navigator.pop(context, 'unhide'),
              )
            else
              ListTile(
                leading: const Icon(Icons.visibility_off_outlined),
                title: const Text('Hide'),
                onTap: () => Navigator.pop(context, 'hide'),
              ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.error),
              title: Text('Delete', style: TextStyle(color: AppColors.error)),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );

    if (!mounted || action == null) return;

    switch (action) {
      case 'edit':
        await _editCategory(householdId, category, pinnedIds);
      case 'pin':
        await pinCategory(householdId, category.categoryId);
      case 'unpin':
        await unpinCategory(householdId, category.categoryId);
      case 'hide':
        await confirmHideCategory(
          context: context,
          householdId: householdId,
          category: category,
        );
      case 'unhide':
        await confirmUnhideCategory(
          context: context,
          householdId: householdId,
          category: category,
        );
      case 'delete':
        await confirmDeleteCategory(
          context: context,
          householdId: householdId,
          category: category,
          allCategories: categories,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final householdId = Provider.of<User?>(context)!.householdId!;
    final transactions = context.watch<List<Transaction>?>() ?? const [];
    final usageCounts = computeUsageCounts(transactions);
    final householdDoc =
        FirebaseFirestore.instance.collection('households').doc(householdId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: householdDoc.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Loading());
        }

        final householdData = snapshot.data!.data();
        final categories = parseCategoriesFromHouseholdData(householdData);
        final pinnedIds =
            parsePinnedCategoryIdsFromHouseholdData(householdData);
        final sorted = _sortedCategories(categories, usageCounts);

        return Scaffold(
              appBar: AppBar(
                title: const Text('Category Settings'),
              ),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search categories',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sorted.length,
                      itemBuilder: (context, index) {
                        final category = sorted[index];
                        final count = usageCounts[category.categoryId] ?? 0;
                        final isPinned =
                            pinnedIds.contains(category.categoryId);

                        return ListTile(
                          leading: Icon(
                            category.categoryIcon.icon,
                            color: category.isHidden
                                ? AppColors.textTertiary
                                : categoryIconColor,
                          ),
                          title: Text(
                            category.categoryName,
                            style: TextStyle(
                              color: category.isHidden
                                  ? AppColors.textTertiary
                                  : categoryNameTextColor,
                            ),
                          ),
                          subtitle: category.isHidden
                              ? const Text('Hidden')
                              : (count > 0
                                  ? Text('$count transactions (30d)')
                                  : null),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isPinned)
                                const Padding(
                                  padding: EdgeInsets.only(right: AppSpacing.sm),
                                  child: Icon(Icons.push_pin, size: 18),
                                ),
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () => _showCategoryMenu(
                                  householdId: householdId,
                                  category: category,
                                  pinnedIds: pinnedIds,
                                  categories: categories,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _editCategory(
                            householdId,
                            category,
                            pinnedIds,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => _createCategory(householdId, pinnedIds),
                child: const Icon(Icons.add),
              ),
            );
      },
    );
  }
}
