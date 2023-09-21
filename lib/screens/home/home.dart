
import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/screens/home/category_icon_button.dart';
import 'package:aiko_ben_expense_app/screens/home/transactions_list/transactions_list.dart';
import 'package:aiko_ben_expense_app/services/auth_service.dart';
import 'package:aiko_ben_expense_app/services/database.dart';
import 'package:aiko_ben_expense_app/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  int currentPageIndex = 0;
  NavigationDestinationLabelBehavior labelBehavior =
      NavigationDestinationLabelBehavior.alwaysShow;
  Map<String, Category>? userCategoriesMap; // Store user categories here
  List<String> orderedUserCategoryIds = ["1", "2", "3", "4", "5", "6", "7", "8"];

  final numOfCategoriesInARow = 4;
  final numOfCategoriesInAColumn = 2;

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

    if (userCategoriesMap == null) {
      return Loading();
    } else {
      DatabaseService db = DatabaseService(uid: user?.uid);
      db.setUserCategoriesMap(userCategoriesMap!);
      return StreamProvider<List<Transaction>?>.value(
          value: db.transactions,
          initialData: null,
          child: Scaffold(
              appBar: AppBar(
                elevation: 0.0,
                title: Text("Home"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () async {
                      await _auth.signOut();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.person), // Your icon
                        SizedBox(height: 1), // Spacer between icon and text
                        Text(
                          'logout',
                          style: TextStyle(
                            fontSize: 10,
                          ),
                        ), // Your text
                      ],
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: NavigationBar(
                labelBehavior: labelBehavior,
                selectedIndex: currentPageIndex,
                onDestinationSelected: (int index) {
                  setState(() {
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
              body:
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  color: Colors.red,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CategoryIconButton(category: userCategoriesMap![orderedUserCategoryIds[0]]!),
                          SizedBox(width: 16),
                          CategoryIconButton(category: userCategoriesMap![orderedUserCategoryIds[1]]!),
                          SizedBox(width: 16),
                          CategoryIconButton(category: userCategoriesMap![orderedUserCategoryIds[2]]!),
                          SizedBox(width: 16),
                          CategoryIconButton(category: userCategoriesMap![orderedUserCategoryIds[3]]!),
                        ],
                      ), //first row
                      Row(
                        children: [
                          CategoryIconButton(category: userCategoriesMap![orderedUserCategoryIds[4]]!),
                          SizedBox(width: 16),
                          CategoryIconButton(category: userCategoriesMap![orderedUserCategoryIds[5]]!),
                          SizedBox(width: 16),
                          CategoryIconButton(category: userCategoriesMap![orderedUserCategoryIds[6]]!),
                          SizedBox(width: 16),
                          CategoryIconButton(category: userCategoriesMap![orderedUserCategoryIds[7]]!),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  // A fixed-height child.
                  color: const Color(0xffeeee00), // Yellow
                  height: 120.0,
                  alignment: Alignment.center,
                  child: const Text('placeholder for total'),
                ),
                Expanded(
                  child: Container(
                      color: Colors.blue,
                      child: SingleChildScrollView(
                        physics: ScrollPhysics(),
                        child: Column(
                          children: [TransactionsList()],
                        ),
                      )
                    // child: TransactionsList())
                  ),
                ),
              ])));
    }
  }

  // write some quick test case for scrollable window
  testCase() {
    List<Text> testList = [];

    for (int i = 1; i <= 100; i++) {
      testList.add(Text("test$i"));
    }
    return testList;
  }

}
