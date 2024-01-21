import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/screens/setting/edit_category_icon_and_name.dart';
import 'package:aiko_ben_expense_app/services/auth_service.dart';
import 'package:aiko_ben_expense_app/services/database.dart';
import 'package:aiko_ben_expense_app/shared/constants.dart';
import 'package:aiko_ben_expense_app/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    final settingsCollection = FirebaseFirestore.instance.collection('settings').doc(uid);
    return StreamBuilder(
        stream: settingsCollection.snapshots(),
        builder: (context, _) {
          return FutureBuilder(
            future: Future.wait([
              getUserCategoriesMap(uid),
              getUserSelectedCategoryIds(uid),
            ]),
            builder:
                (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
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
                      ..sort((e1, e2) =>
                          int.parse(e1.key).compareTo(int.parse(e2.key))));

                return Scaffold(
                  appBar: AppBar(
                    title: Text('Category Settings'),
                    automaticallyImplyLeading: true, // Add a back button
                  ),
                  body: ListView.builder(
                    itemCount: userCategoriesMap.length,
                    itemBuilder: (context, index) {
                      final category =
                          userCategoriesMap.values.elementAt(index);
                      return ListTile(
                        leading: Icon(
                          category.categoryIcon.icon,
                          color:
                              categoryIconColor, // Use the category icon color
                        ),
                        title: Text(
                          category.categoryName,
                          style: const TextStyle(
                              color:
                                  categoryNameTextColor), // Use the category name text color
                        ),
                        trailing: Checkbox(
                          value: userSelectedCategoryIds
                              .contains(category.categoryId),
                          onChanged: (bool? newValue) {
                            setState(() {
                              if (newValue == true) {
                                userSelectedCategoryIds
                                    .add(category.categoryId);
                              } else {
                                userSelectedCategoryIds
                                    .remove(category.categoryId);
                              }
                              //Save the updated userSelectedCategoryIds to Firebase here
                              updateUserSelectedCategoryIds(
                                  uid, userSelectedCategoryIds);
                            });
                          },
                        ),
                      );
                    },
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () {
                      showModalBottomSheet(
                        //add constraints to the bottom sheet
                        constraints: BoxConstraints.loose(Size(
                            MediaQuery.of(context).size.width,
                            MediaQuery.of(context).size.height * 0.6)),
                        isScrollControlled: true,
                        // <= set to true. setting this without constrains may cause full screen bottomsheet.
                        context: context,
                        builder: (context) {
                          // clipRRect is used to make the bottomsheet rounded
                          return ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            ),
                            child: EditCategoryIconAndName(
                              userCategoriesMap: userCategoriesMap,
                            ),
                          );
                        },
                      );
                    },
                    child: Icon(Icons.edit),
                  ),
                );
              }
            },
          );
        });
  }
}
