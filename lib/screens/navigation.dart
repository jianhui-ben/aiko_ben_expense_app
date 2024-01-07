import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/screens/home/home.dart';
import 'package:aiko_ben_expense_app/screens/insights/insights.dart';
import 'package:aiko_ben_expense_app/screens/setting/settings.dart';
import 'package:aiko_ben_expense_app/services/database.dart';
import 'package:aiko_ben_expense_app/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

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


  //To-do: maybe move some authentification here
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User?>(context);
    DatabaseService db = DatabaseService(uid: user?.uid);

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
