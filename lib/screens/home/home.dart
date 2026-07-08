import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/screens/single_transaction/add_or_edit_single_transaction.dart';
import 'package:aiko_ben_expense_app/screens/home/spending_and_budget/daily_and_monthly_total.dart';
import 'package:aiko_ben_expense_app/screens/home/transactions_list/transactions_list.dart';
import 'package:aiko_ben_expense_app/services/category_preferences.dart';
import 'package:aiko_ben_expense_app/services/category_usage_service.dart';
import 'package:aiko_ben_expense_app/services/database.dart';
import 'package:aiko_ben_expense_app/shared/loading.dart';
import 'package:aiko_ben_expense_app/shared/widgets/app_scaffold.dart';
import 'package:aiko_ben_expense_app/shared/widgets/category_chip.dart';
import 'package:aiko_ben_expense_app/shared/widgets/category_editor_sheet.dart';
import 'package:aiko_ben_expense_app/shared/widgets/category_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map<String, Category>? userCategoriesMap;
  List<String>? pinnedCategoryIds;
  String? lastUsedCategoryId;
  String householdName = 'Home';

  DateTime selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    super.initState();
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    final householdId = Provider.of<User?>(context, listen: false)!.householdId!;
    final fetchedCategoriesMap = await getHouseholdCategoriesMap(householdId);
    final fetchedPinnedIds = await getHouseholdPinnedCategoryIds(householdId);
    final fetchedName = await getHouseholdName(householdId);
    final lastUsed = await CategoryPreferences.getLastUsedCategory(householdId);

    if (!mounted) return;
    setState(() {
      userCategoriesMap = fetchedCategoriesMap;
      pinnedCategoryIds = fetchedPinnedIds;
      householdName = fetchedName;
      lastUsedCategoryId = lastUsed;
    });
  }


  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() => selectedDate = pickedDate);
    }
  }

  Future<void> _openAddSheet(Category category) async {
    final householdId = Provider.of<User?>(context, listen: false)!.householdId!;
    await CategoryPreferences.saveLastUsedCategory(
        householdId, category.categoryId);
    setState(() => lastUsedCategoryId = category.categoryId);

    if (!mounted) return;
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
          category: category,
          selectedDate: selectedDate,
        );
      },
    );
  }

  Future<void> _openCategoryPicker() async {
    final householdId = Provider.of<User?>(context, listen: false)!.householdId!;
    final transactions = context.read<List<Transaction>?>() ?? const [];
    final usageCounts = computeUsageCounts(transactions);

    await showCategoryPickerSheet(
      context: context,
      householdId: householdId,
      categories: userCategoriesMap!,
      pinnedCategoryIds: pinnedCategoryIds!,
      usageCounts: usageCounts,
      lastUsedCategoryId: lastUsedCategoryId,
      onCategorySelected: _openAddSheet,
    );
    await fetchHomeData();
  }

  Future<void> _showChipActions(Category category) async {
    final householdId = Provider.of<User?>(context, listen: false)!.householdId!;
    final isPinned = pinnedCategoryIds!.contains(category.categoryId);

    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit category'),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: Icon(isPinned ? Icons.push_pin_outlined : Icons.push_pin),
              title: Text(isPinned ? 'Unpin from Home' : 'Pin to Home'),
              onTap: () => Navigator.pop(context, isPinned ? 'unpin' : 'pin'),
            ),
            ListTile(
              leading: const Icon(Icons.visibility_off_outlined),
              title: const Text('Hide category'),
              onTap: () => Navigator.pop(context, 'hide'),
            ),
          ],
        ),
      ),
    );

    if (!mounted || action == null) return;

    switch (action) {
      case 'edit':
        await showCategoryEditorSheet(
          context: context,
          householdId: householdId,
          category: category,
          pinnedCategoryIds: pinnedCategoryIds!,
        );
        await fetchHomeData();
      case 'pin':
        await pinCategory(householdId, category.categoryId);
        await fetchHomeData();
      case 'unpin':
        await unpinCategory(householdId, category.categoryId);
        await fetchHomeData();
      case 'hide':
        await updateHouseholdCategoryHidden(
            householdId, category.categoryId, true);
        await fetchHomeData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<List<Transaction>?>() ?? const [];

    if (userCategoriesMap == null || pinnedCategoryIds == null) {
      return const Loading();
    }

    final usageCounts = computeUsageCounts(transactions);
    final hiddenIds = userCategoriesMap!.values
        .where((c) => c.isHidden)
        .map((c) => c.categoryId)
        .toSet();
    final homeCategoryIds = resolveHomeCategoryIds(
      pinnedIds: pinnedCategoryIds!,
      usageCounts: usageCounts,
      hiddenIds: hiddenIds,
      allCategoryIds: userCategoriesMap!.keys.toSet(),
    );

    return AppScaffold(
      title: householdName,
      subtitle: DateFormat('EEEE, d MMM').format(selectedDate),
      trailing: IconButton(
        icon: const Icon(Icons.calendar_today_outlined, size: 22),
        onPressed: _pickDate,
        tooltip: 'Pick date',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: SpendingSummary(selectedDate: selectedDate),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 88,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: homeCategoryIds.length + 1,
              itemBuilder: (context, index) {
                if (index == homeCategoryIds.length) {
                  return MoreCategoryChip(onTap: _openCategoryPicker);
                }
                final category =
                    userCategoriesMap![homeCategoryIds[index]]!;
                return CategoryChip(
                  category: category,
                  onTap: () => _openAddSheet(category),
                  onLongPress: () => _showChipActions(category),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: TransactionsList(
              selectedDate: selectedDate,
              isDailyView: true,
            ),
          ),
        ],
      ),
    );
  }
}
