import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/services/auth_service.dart';
import 'package:aiko_ben_expense_app/services/database.dart';
import 'package:aiko_ben_expense_app/shared/constants.dart';
import 'package:flutter/material.dart';

class EditCategoryIconAndName extends StatefulWidget {
  final Map<String, Category> userCategoriesMap;

  EditCategoryIconAndName({required this.userCategoriesMap});

  @override
  _EditCategoryIconAndNameState createState() => _EditCategoryIconAndNameState();
}

class _EditCategoryIconAndNameState extends State<EditCategoryIconAndName> {
  Category? selectedCategory;
  final categoryNameController = TextEditingController();
  final ValueNotifier<bool> hasCategoryNameChanged = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.userCategoriesMap.values.first; // Select the first category by default
  }

  @override
  Widget build(BuildContext context) {
    categoryNameController.text = selectedCategory?.categoryName ?? '';
    return Column(
      children: [
        // drag handler
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Opacity(
            opacity: 0.40,
            child: Container(
              width: 32,
              height: 4,
              decoration: ShapeDecoration(
                color: Color(0xFF79747E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.07,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the children horizontally
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: TextField(
                    controller: categoryNameController,
                    style: const TextStyle(fontSize: 24, color: categoryNameTextColor),
                    textAlign: TextAlign.center, // Center the text
                    decoration: InputDecoration(
                      border: InputBorder.none, // Remove the border
                    ),
                    onChanged: (newName) {
                      hasCategoryNameChanged.value = newName != selectedCategory?.categoryName;
                    },
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: hasCategoryNameChanged,
                  builder: (BuildContext context, bool hasChanged, Widget? child) {
                    return hasChanged
                        ? IconButton(
                            icon: Icon(Icons.check),
                            onPressed: () {
                              // Update the category name in Firebase here
                              updateUserCategoryName(
                                  AuthService().currentUser!.uid,
                                  selectedCategory!.categoryId,
                                  categoryNameController.text);
                              setState(() {
                                selectedCategory!.categoryName =
                                    categoryNameController.text;
                              });
                            },
                          )
                        : Container();
                  },
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 5,
              children: widget.userCategoriesMap.values.map((category) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory =
                          category; // Update the selected category when the icon is tapped
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      // get constant's iconTheme color
                      color: category == selectedCategory
                          ? getCustomTheme().iconTheme.color
                          : null,
                      // Change the background color if the category is selected
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category.categoryIcon.icon,
                      color: categoryIconColor,
                      size: MediaQuery.of(context).size.width * 0.1,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}