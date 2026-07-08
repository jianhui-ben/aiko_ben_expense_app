import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/services/category_usage_service.dart';
import 'package:aiko_ben_expense_app/shared/constants.dart';
import 'package:aiko_ben_expense_app/shared/widgets/category_editor_sheet.dart';
import 'package:flutter/material.dart';

typedef CategorySelectedCallback = void Function(Category category);

Future<void> showCategoryPickerSheet({
  required BuildContext context,
  required String householdId,
  required Map<String, Category> categories,
  required List<String> pinnedCategoryIds,
  required Map<String, int> usageCounts,
  String? lastUsedCategoryId,
  required CategorySelectedCallback onCategorySelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints.loose(
      Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height * 0.75,
      ),
    ),
    builder: (context) => CategoryPickerSheet(
      householdId: householdId,
      categories: categories,
      pinnedCategoryIds: pinnedCategoryIds,
      usageCounts: usageCounts,
      lastUsedCategoryId: lastUsedCategoryId,
      onCategorySelected: onCategorySelected,
    ),
  );
}

class CategoryPickerSheet extends StatefulWidget {
  final String householdId;
  final Map<String, Category> categories;
  final List<String> pinnedCategoryIds;
  final Map<String, int> usageCounts;
  final String? lastUsedCategoryId;
  final CategorySelectedCallback onCategorySelected;

  const CategoryPickerSheet({
    super.key,
    required this.householdId,
    required this.categories,
    required this.pinnedCategoryIds,
    required this.usageCounts,
    this.lastUsedCategoryId,
    required this.onCategorySelected,
  });

  @override
  State<CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<CategoryPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  late Map<String, Category> _categories;

  @override
  void initState() {
    super.initState();
    _categories = Map<String, Category>.from(widget.categories);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Category> _visibleCategories() {
    final query = _searchController.text.trim().toLowerCase();
    return _categories.values.where((category) {
      if (query.isEmpty) return true;
      return category.categoryName.toLowerCase().contains(query);
    }).toList();
  }

  List<Category> _pinnedCategories() {
    return widget.pinnedCategoryIds
        .where((id) => _categories.containsKey(id) && !_categories[id]!.isHidden)
        .map((id) => _categories[id]!)
        .toList();
  }

  List<Category> _frequentCategories() {
    final pinned = widget.pinnedCategoryIds.toSet();
    final ids = sortCategoryIdsByUsage(
      categoryIds: _categories.keys.where(
        (id) => !pinned.contains(id) && !_categories[id]!.isHidden,
      ),
      usageCounts: widget.usageCounts,
    );
    return ids
        .where((id) => (widget.usageCounts[id] ?? 0) > 0)
        .take(8)
        .map((id) => _categories[id]!)
        .toList();
  }

  List<Category> _allCategories() {
    final ids = sortCategoryIdsByUsage(
      categoryIds: _categories.keys,
      usageCounts: widget.usageCounts,
    );
    return ids.map((id) => _categories[id]!).toList();
  }

  void _select(Category category) {
    Navigator.pop(context);
    widget.onCategorySelected(category);
  }

  Future<void> _createCategory() async {
    final created = await showCategoryEditorSheet(
      context: context,
      householdId: widget.householdId,
      pinnedCategoryIds: widget.pinnedCategoryIds,
      pinByDefault: true,
    );
    if (created == null || !mounted) return;
    setState(() => _categories[created.categoryId] = created);
    _select(created);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSearching = _searchController.text.trim().isNotEmpty;
    final searchResults = _visibleCategories();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Material(
        color: AppColors.surface,
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Choose category',
                style: theme.textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
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
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryContainer,
                      child: const Icon(Icons.add, color: AppColors.primary),
                    ),
                    title: const Text('Create new category'),
                    onTap: _createCategory,
                  ),
                  if (isSearching) ...[
                    _SectionHeader(title: 'Results'),
                    ...searchResults.map((c) => _CategoryTile(
                          category: c,
                          isLastUsed: c.categoryId == widget.lastUsedCategoryId,
                          usageCount: widget.usageCounts[c.categoryId],
                          onTap: () => _select(c),
                        )),
                  ] else ...[
                    if (widget.lastUsedCategoryId != null &&
                        _categories.containsKey(widget.lastUsedCategoryId) &&
                        !_categories[widget.lastUsedCategoryId]!.isHidden) ...[
                      _SectionHeader(title: 'Last used'),
                      _CategoryTile(
                        category: _categories[widget.lastUsedCategoryId]!,
                        isLastUsed: true,
                        usageCount:
                            widget.usageCounts[widget.lastUsedCategoryId],
                        onTap: () =>
                            _select(_categories[widget.lastUsedCategoryId]!),
                      ),
                    ],
                    if (_pinnedCategories().isNotEmpty) ...[
                      _SectionHeader(title: 'Pinned'),
                      ..._pinnedCategories().map(
                        (c) => _CategoryTile(
                          category: c,
                          isPinned: true,
                          usageCount: widget.usageCounts[c.categoryId],
                          onTap: () => _select(c),
                        ),
                      ),
                    ],
                    if (_frequentCategories().isNotEmpty) ...[
                      _SectionHeader(title: 'Frequent'),
                      ..._frequentCategories().map(
                        (c) => _CategoryTile(
                          category: c,
                          usageCount: widget.usageCounts[c.categoryId],
                          onTap: () => _select(c),
                        ),
                      ),
                    ],
                    _SectionHeader(title: 'All categories'),
                    ..._allCategories().map(
                      (c) => _CategoryTile(
                        category: c,
                        isPinned: widget.pinnedCategoryIds.contains(c.categoryId),
                        usageCount: widget.usageCounts[c.categoryId],
                        onTap: () => _select(c),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.md,
        bottom: AppSpacing.xs,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final bool isPinned;
  final bool isLastUsed;
  final int? usageCount;

  const _CategoryTile({
    required this.category,
    required this.onTap,
    this.isPinned = false,
    this.isLastUsed = false,
    this.usageCount,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.surfaceVariant,
        child: Icon(category.categoryIcon.icon, color: categoryIconColor),
      ),
      title: Text(
        category.categoryName,
        style: TextStyle(
          color: category.isHidden ? AppColors.textTertiary : null,
        ),
      ),
      subtitle: _subtitle(),
      trailing: isPinned ? const Icon(Icons.push_pin, size: 18) : null,
      onTap: onTap,
    );
  }

  Widget? _subtitle() {
    if (isLastUsed) return const Text('Last used');
    if (category.isHidden) return const Text('Hidden');
    if (usageCount != null && usageCount! > 0) {
      return Text('$usageCount transactions (30d)');
    }
    return null;
  }
}
