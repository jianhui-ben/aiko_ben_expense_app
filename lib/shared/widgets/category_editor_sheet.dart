import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/services/category_service.dart';
import 'package:aiko_ben_expense_app/shared/category_icon_library.dart';
import 'package:aiko_ben_expense_app/shared/constants.dart';
import 'package:flutter/material.dart';

Future<Category?> showCategoryEditorSheet({
  required BuildContext context,
  required String householdId,
  Category? category,
  List<String> pinnedCategoryIds = const [],
  bool pinByDefault = false,
}) {
  return showModalBottomSheet<Category>(
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints.loose(
      Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height * 0.85,
      ),
    ),
    builder: (context) => CategoryEditorSheet(
      householdId: householdId,
      category: category,
      pinnedCategoryIds: pinnedCategoryIds,
      pinByDefault: pinByDefault,
    ),
  );
}

class CategoryEditorSheet extends StatefulWidget {
  final String householdId;
  final Category? category;
  final List<String> pinnedCategoryIds;
  final bool pinByDefault;

  const CategoryEditorSheet({
    super.key,
    required this.householdId,
    this.category,
    this.pinnedCategoryIds = const [],
    this.pinByDefault = false,
  });

  bool get isEditing => category != null;

  @override
  State<CategoryEditorSheet> createState() => _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends State<CategoryEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _searchController;
  late String _selectedIconKey;
  late bool _pinToHome;
  CategoryIconGroup? _selectedGroup;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.categoryName ?? '');
    _searchController = TextEditingController();
    _selectedIconKey = widget.category?.iconKey ?? 'category';
    _pinToHome = widget.category != null
        ? widget.pinnedCategoryIds.contains(widget.category!.categoryId)
        : widget.pinByDefault;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<CategoryIconEntry> get _filteredIcons => filterCategoryIcons(
        query: _searchController.text,
        group: _selectedGroup,
      );

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (widget.isEditing) {
        await updateHouseholdCategory(
          householdId: widget.householdId,
          categoryId: widget.category!.categoryId,
          name: name,
          iconKey: _selectedIconKey,
          pinToHome: _pinToHome,
        );
        if (!mounted) return;
        Navigator.pop(
          context,
          widget.category!.copyWith(
            categoryName: name,
            categoryIcon: Icon(iconDataForKey(_selectedIconKey)),
            iconKey: _selectedIconKey,
          ),
        );
      } else {
        final categoryId = await createHouseholdCategory(
          householdId: widget.householdId,
          name: name,
          iconKey: _selectedIconKey,
          pinToHome: _pinToHome,
        );
        if (!mounted) return;
        Navigator.pop(
          context,
          Category(
            categoryId: categoryId,
            categoryName: name,
            categoryIcon: Icon(iconDataForKey(_selectedIconKey)),
            iconKey: _selectedIconKey,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save category: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Column(
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
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.isEditing ? 'Edit category' : 'New category',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  color: categoryNameTextColor,
                ),
                decoration: const InputDecoration(
                  hintText: 'Category name',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              title: const Text('Pin to Home'),
              subtitle: const Text('Always show on the home screen'),
              value: _pinToHome,
              onChanged: (value) => setState(() => _pinToHome = value),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search icons',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: [
                  _GroupChip(
                    label: 'All',
                    selected: _selectedGroup == null,
                    onTap: () => setState(() => _selectedGroup = null),
                  ),
                  ...CategoryIconGroup.values.map(
                    (group) => _GroupChip(
                      label: group.label,
                      selected: _selectedGroup == group,
                      onTap: () => setState(() => _selectedGroup = group),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                ),
                itemCount: _filteredIcons.length,
                itemBuilder: (context, index) {
                  final entry = _filteredIcons[index];
                  final isSelected = entry.key == _selectedIconKey;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIconKey = entry.key),
                    child: Tooltip(
                      message: entry.label,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryContainer
                              : AppColors.surfaceVariant,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: AppColors.primary, width: 2)
                              : null,
                        ),
                        child: Icon(
                          entry.iconData,
                          color: isSelected
                              ? AppColors.primary
                              : categoryIconColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GroupChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
