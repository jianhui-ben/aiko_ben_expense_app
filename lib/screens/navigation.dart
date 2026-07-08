import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/screens/home/home.dart';
import 'package:aiko_ben_expense_app/screens/insights/insights.dart';
import 'package:aiko_ben_expense_app/screens/setting/settings.dart';
import 'package:aiko_ben_expense_app/services/database.dart';
import 'package:aiko_ben_expense_app/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Navigation extends StatefulWidget {
  final String householdId;

  const Navigation({super.key, required this.householdId});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {

  int currentPageIndex = 0;
  NavigationDestinationLabelBehavior labelBehavior =
      NavigationDestinationLabelBehavior.alwaysShow;

  // tabs from navigation bar
  final List<Widget> _pages = [
    Home(),
    Insights(),
    Settings(),
  ];


  Map<String, Category>? userCategoriesMap; // Store household categories here

  @override
  void initState() {
    super.initState();
    fetchUserCategories();
  }

  Future<void> fetchUserCategories() async {
    final fetchedCategoriesMap =
        await getHouseholdCategoriesMap(widget.householdId);

    if (!mounted) return;
    setState(() {
      userCategoriesMap = fetchedCategoriesMap;
    });
  }


  @override
  Widget build(BuildContext context) {
    DatabaseService db = DatabaseService(householdId: widget.householdId);

    if (userCategoriesMap == null) {
      return Loading();
    } else {
      db.setUserCategoriesMap(userCategoriesMap!);
      return StreamProvider<List<Transaction>?>.value(
          value: db.transactions,
          initialData: null,
          child: Scaffold(
            body: _pages[currentPageIndex],
            bottomNavigationBar: NavigationBar(
              labelBehavior: labelBehavior,
              selectedIndex: currentPageIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  // print("curent tab index: $index");
                  currentPageIndex = index;
                });
              },
              destinations: const <Widget>[
                NavigationDestination(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights),
                  label: 'Insights',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ));
    }
  }
}
