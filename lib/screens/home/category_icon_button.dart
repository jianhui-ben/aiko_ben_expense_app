
import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/screens/single_transaction/add_or_edit_single_transaction.dart';
import 'package:flutter/material.dart';

class CategoryIconButton extends StatefulWidget {

  final Category category;
  final DateTime selectedDate;

  const CategoryIconButton({super.key, required this.category, required this.selectedDate});

  @override
  State<CategoryIconButton> createState() => _CategoryIconButtonState();
}

class _CategoryIconButtonState extends State<CategoryIconButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width / 5, // Adjust the width here
          height: MediaQuery.of(context).size.width / 5, // Adjust the height here
          child: IconButton.filled(
            icon: widget.category.categoryIcon,
            iconSize: MediaQuery.of(context).size.width / 7, // Adjust the icon size here
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddOrEditSingleTransaction(
                    category: widget.category,
                    selectedDate: widget.selectedDate,
                  ),
                  // settings: RouteSettings(arguments: {"some key": some value}), //added here for quick reminder
                ),
              );
            },
          ),
        ),
        Container(
          // width: MediaQuery.of(context).size.width / 5, // Adjust the width here
          child: Text(
            widget.category.categoryName, // Display the category name
            style: TextStyle(fontSize: 12), // Adjust the font size as needed
            textAlign: TextAlign.center, // Center the text
          ),
        ),
      ],
    );
  }
}

