
import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/screens/single_transaction/add_new_single_transaction.dart';
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
        IconButton.filled(
          icon: widget.category.categoryIcon,
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNewSingleTransaction(
                  category: widget.category,
                  selectedDate: widget.selectedDate,
                  // transactionAmount: null,
                  // transactionComment: null,
                ),
                // settings: RouteSettings(arguments: {"some key": some value}), //added here for quick reminder
              ),
            );
          },
        ),
        Text(
          widget.category.categoryName, // Display the category name
          style: TextStyle(fontSize: 12), // Adjust the font size as needed
        ),
      ],
    );
  }
}

