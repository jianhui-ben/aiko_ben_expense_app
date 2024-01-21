import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/services/auth_service.dart';
import 'package:aiko_ben_expense_app/services/database.dart';
import 'package:aiko_ben_expense_app/shared/loading.dart';
import 'package:flutter/material.dart';

class CategorySettingScreen extends StatefulWidget {
  const CategorySettingScreen({super.key});

  @override
  State<CategorySettingScreen> createState() => _CategorySettingScreenState();
}

class _CategorySettingScreenState extends State<CategorySettingScreen> {
  String uid = AuthService().currentUser!.uid;
  Map<String, bool> checkboxStates = {};

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        getUserCategoriesMap(uid),
        getUserSelectedCategoryIds(uid),
      ]),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading(); // Show a loading spinner while waiting
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          Map<String, Category> userCategoriesMap = snapshot.data![0];
          List<String> userSelectedCategoryIds = snapshot.data![1];

          //sort userCategoriesMap by categoryId
          userCategoriesMap = Map.fromEntries(
              userCategoriesMap.entries.toList()
                ..sort((e1, e2) => int.parse(e1.key).compareTo(int.parse(e2.key)))
          );

          return Scaffold(
            appBar: AppBar(
              title: Text('Category Settings'),
              automaticallyImplyLeading: true, // Add a back button
            ),
            body: ListView.builder(
              itemCount: userCategoriesMap.length,
              itemBuilder: (context, index) {
                final category = userCategoriesMap.values.elementAt(index);
                return ListTile(
                  leading: category.categoryIcon,
                  title: Text(category.categoryName),
                  trailing: Checkbox(
                    value: userSelectedCategoryIds.contains(category.categoryId),
                    onChanged: (bool? newValue) {
                      setState(() {
                        if (newValue == true) {
                          userSelectedCategoryIds.add(category.categoryId);
                        } else {
                          userSelectedCategoryIds.remove(category.categoryId);
                        }
                        //Save the updated userSelectedCategoryIds to Firebase here
                        updateUserSelectedCategoryIds(uid, userSelectedCategoryIds);
                      });
                    },
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
