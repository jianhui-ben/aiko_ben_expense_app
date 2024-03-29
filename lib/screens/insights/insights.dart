import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/screens/insights/monthly_dashboard.dart';
import 'package:aiko_ben_expense_app/screens/insights/weekly_dashboard.dart';
import 'package:aiko_ben_expense_app/screens/insights/yearly_dashboard.dart';
import 'package:aiko_ben_expense_app/services/auth_service.dart';
import 'package:aiko_ben_expense_app/services/database.dart';
import 'package:aiko_ben_expense_app/shared/constants.dart';
import 'package:aiko_ben_expense_app/shared/loading.dart';
import 'package:aiko_ben_expense_app/shared/util.dart';
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
    final fetchedCategoriesMap = await getUserCategoriesMap(AuthService().currentUser!.uid);

    // TO-DO update orderedUserCategoryIds

    // Update the state with the fetched data
    setState(() {
      userCategoriesMap = fetchedCategoriesMap;
    });
    // print(userCategoriesMap);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    DatabaseService db = DatabaseService(uid: user?.uid);

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
      return DefaultTabController(
          length: dashboards.length,
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.12,
                child: Column(
                  children: [
                    Spacer(),
                    TabBar(
                      tabs: [
                        Tab(text: 'Week'),
                        Tab(text: 'Month'),
                        Tab(text: 'Year'),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: dashboards,
                ),
              ),
            ],
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
