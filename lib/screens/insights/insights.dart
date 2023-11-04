import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/screens/insights/monthly_dashboard.dart';
import 'package:aiko_ben_expense_app/services/database.dart';
import 'package:aiko_ben_expense_app/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Insights extends StatefulWidget {
  const Insights({super.key});

  @override
  State<Insights> createState() => _InsightsState();
}


class _InsightsState extends State<Insights> {
  // List of dashboard widgets for each tab
  final List<Widget> dashboards = [
    DailyDashboard(),
    WeeklyDashboard(),
    MonthlyDashboard(),
    YearlyDashboard(),
  ];

  Map<String, Category>? userCategoriesMap; // Store user categories here

  @override
  void initState() {
    super.initState();
    // Call the asynchronous function
    // in this case, it would only call the getUserCategoriesMap once
    fetchUserCategories();
  }

  Future<void> fetchUserCategories() async {
    final user = Provider.of<User?>(context, listen: false);
    final fetchedCategoriesMap = await getUserCategoriesMap(user!.uid);

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

    if (userCategoriesMap == null) {
      return Loading();
    } else {
      db.setUserCategoriesMap(userCategoriesMap!);
      return DefaultTabController(
          length: dashboards.length,
          child: StreamProvider<List<Transaction>?>.value(
            value: db.transactions,
            initialData: null,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Insights'),
                bottom: TabBar(
                  tabs: [
                    Tab(text: 'Day'),
                    Tab(text: 'Week'),
                    Tab(text: 'Month'),
                    Tab(text: 'Year'),
                  ],
                ),
              ),
              body: TabBarView(
                children: dashboards,
              ),
            ),
          ));
    }
  }
}

class DailyDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Daily Dashboard Content'),
    );
  }
}

class WeeklyDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Weekly Dashboard Content'),
    );
  }
}

// class MonthlyDashboard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text('Monthly Dashboard Content'),
//     );
//   }
// }

class YearlyDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Yearly Dashboard Content'),
    );
  }
}
