
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
          width: MediaQuery.of(context).size.width / 6, // Adjust the width here
          child:
          IconButton.filled(
            icon: widget.category.categoryIcon,
            iconSize: MediaQuery.of(context).size.width / 8, // Adjust the icon size here
            onPressed: () {
              showModalBottomSheet(
                constraints: BoxConstraints.loose(Size(
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height * 0.8)),
                // <= this is set to 3/4 of screen size.
                isScrollControlled: true, // <= set to true. setting this without constrains may cause full screen bottomsheet.
                context: context,
                builder: (context) {
                  return AddOrEditSingleTransaction(
                    category: widget.category,
                    selectedDate: widget.selectedDate,
                  );
                },
              );
            },
          ),
        ),
        Container(
          // width: MediaQuery.of(context).size.width / 6, // Adjust the width here
          child: Text(
            widget.category.categoryName, // Display the category name
            style: TextStyle(fontSize: 14), // Adjust the font size as needed
            textAlign: TextAlign.center, // Center the text
          ),
        ),
      ],
    );
  }
}

