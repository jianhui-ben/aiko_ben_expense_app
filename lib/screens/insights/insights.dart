import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/screens/insights/monthly_dashboard.dart';
import 'package:aiko_ben_expense_app/screens/insights/weekly_dashboard.dart';
import 'package:aiko_ben_expense_app/screens/insights/yearly_dashboard.dart';
import 'package:aiko_ben_expense_app/services/database.dart';
import 'package:aiko_ben_expense_app/shared/constants.dart';
import 'package:aiko_ben_expense_app/shared/loading.dart';
import 'package:aiko_ben_expense_app/shared/util.dart';
import 'package:aiko_ben_expense_app/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Insights extends StatefulWidget {
  const Insights({super.key});

  @override
  State<Insights> createState() => _InsightsState();
}


class _InsightsState extends State<Insights> {

  Map<String, Category>? userCategoriesMap; // Store user categories here

  @override
  void initState() {
    super.initState();
    // Call the asynchronous function
    // in this case, it would only call the getUserCategoriesMap once
    fetchUserCategories();
  }

  Future<void> fetchUserCategories() async {
    final householdId = Provider.of<User?>(context, listen: false)!.householdId!;
    final fetchedCategoriesMap = await getHouseholdCategoriesMap(householdId);

    if (!mounted) return;
    setState(() {
      userCategoriesMap = fetchedCategoriesMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    DatabaseService db = DatabaseService(householdId: user?.householdId);

    final transactionStream = Provider.of<List<Transaction>?>(context);

    if (transactionStream == null) {
      return Container();
    }

    // List of dashboard widgets for each tab
    final List<Widget> dashboards = [
      WeeklyDashboard(transactions: Util.filterTransactionListToLastSevenDays(transactionStream, today)),
      MonthlyDashboard(transactions: Util.filterTransactionListToMonth(transactionStream, today)),
      YearlyDashboard(transactions: Util.filterTransactionListToYear(transactionStream, today)),
    ];

    if (userCategoriesMap == null) {
      return Loading();
    } else {
      db.setUserCategoriesMap(userCategoriesMap!);
      return AppScaffold(
        title: 'Insights',
        body: DefaultTabController(
          length: dashboards.length,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.border),
                    ),
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: Theme.of(context).textTheme.labelMedium,
                    tabs: const [
                      Tab(text: 'Week'),
                      Tab(text: 'Month'),
                      Tab(text: 'Year'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: dashboards,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}


// class WeeklyDashboard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text('Weekly Dashboard Content'),
//     );
//   }
// }

// class YearlyDashboard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text('Yearly Dashboard Content'),
//     );
//   }
// }
