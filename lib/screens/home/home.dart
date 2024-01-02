
import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/screens/home/category_icon_button.dart';
import 'package:aiko_ben_expense_app/screens/home/spending_and_budget/daily_and_monthly_total.dart';
import 'package:aiko_ben_expense_app/screens/home/transactions_list/transactions_list.dart';
import 'package:aiko_ben_expense_app/services/auth_service.dart';
import 'package:aiko_ben_expense_app/services/database.dart';
import 'package:aiko_ben_expense_app/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../shared/constants.dart';

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

  // TO-DO the orderedUserCategoryIds should be retrieved from setting collection as well
  List<String> orderedUserCategoryIds = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8"
  ];


  final numOfCategoriesInARow = 4;
  final numOfCategoriesInAColumn = 2;

  // by default select today's date
  DateTime selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  bool isDailyView = true;


  @override
  void initState() {
    super.initState();
    // Call the asynchronous function
    // in this case, it would only call the getUserCategoriesMap once
    fetchUserCategories();
  }

  @override
  Widget build(BuildContext context) {
    final isToday = selectedDate.isAtSameMomentAs(DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day));

    final user = Provider.of<User?>(context);
    DatabaseService db = DatabaseService(uid: user?.uid);

    if (userCategoriesMap == null) {
      return Loading();
    } else {
      db.setUserCategoriesMap(userCategoriesMap!);

      return Scaffold(
          body: Column(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.12,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //add a sizedbox at the front before the date
                        SizedBox(width: 15),
                        Text(
                          DateFormat('EEEE, d MMM').format(selectedDate),
                          style: topDateOnHomeTextStyle,
                        ),
                        // Calendar icon button
                        IconButton(
                          icon: Icon(
                            Icons.calendar_today,
                            color: Colors.grey,
                            size: 18,
                          ),
                          onPressed: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null && pickedDate != selectedDate) {
                              setState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: DailyAndMonthlyTotal(selectedDate: selectedDate),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.12,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: orderedUserCategoryIds.length,
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                          // Add some padding
                          child: CategoryIconButton(
                            category:
                                userCategoriesMap![orderedUserCategoryIds[index]]!,
                            selectedDate: selectedDate,
                          ) // The rest of your CategoryIconButton content
                          );
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                    child: TransactionsList(
                      selectedDate: selectedDate,
                      isDailyView: isDailyView,
                    ),
                  ),
                ),
              ]
          )
      );
    }
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

  void _selectDate(DateTime newDate) {
    setState(() {
      // print("set to new date: $newDate");
      selectedDate = newDate;
    });
  }
}