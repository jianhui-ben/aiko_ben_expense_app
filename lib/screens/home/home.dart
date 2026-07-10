import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/screens/single_transaction/add_or_edit_single_transaction.dart';
import 'package:aiko_ben_expense_app/screens/home/spending_and_budget/daily_and_monthly_total.dart';
import 'package:aiko_ben_expense_app/screens/home/transactions_list/transactions_list.dart';
import 'package:aiko_ben_expense_app/services/database.dart';
import 'package:aiko_ben_expense_app/shared/loading.dart';
import 'package:aiko_ben_expense_app/shared/widgets/app_scaffold.dart';
import 'package:aiko_ben_expense_app/shared/widgets/category_chip.dart';
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
  List<String>? orderedUserCategoryIds;
  String householdName = 'Home';

  // by default select today's date
  DateTime selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    super.initState();
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    final householdId =
        Provider.of<User?>(context, listen: false)?.householdId;
    // User may have left the household while this fetch was in flight.
    if (householdId == null) return;

    try {
      final fetchedCategoriesMap =
          await getHouseholdCategoriesMap(householdId);
      final fetchedOrderedIds =
          await getHouseholdSelectedCategoryIds(householdId);
      final fetchedName = await getHouseholdName(householdId);

      if (!mounted) return;
      // Re-check: leave can clear householdId between the awaits above.
      if (Provider.of<User?>(context, listen: false)?.householdId == null) {
        return;
      }
      setState(() {
        userCategoriesMap = fetchedCategoriesMap;
        orderedUserCategoryIds = fetchedOrderedIds;
        householdName = fetchedName;
      });
    } catch (_) {
      // Permission-denied (or similar) after leaving is expected; ignore.
      if (!mounted) return;
    }
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

  void _openAddSheet(Category category) {
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

  @override
  Widget build(BuildContext context) {
    if (userCategoriesMap == null || orderedUserCategoryIds == null) {
      return const Loading();
    }

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
              itemCount: orderedUserCategoryIds!.length,
              itemBuilder: (context, index) {
                final category =
                    userCategoriesMap![orderedUserCategoryIds![index]]!;
                return CategoryChip(
                  category: category,
                  onTap: () => _openAddSheet(category),
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
