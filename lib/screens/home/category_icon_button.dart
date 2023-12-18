
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

  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width / 6, // Adjust the width here

          decoration: BoxDecoration(
            color: _isSelected ?  Color(0xFFB69DF8) : Colors.white,
            // Set the background color based on the state
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: widget.category.categoryIcon,
            iconSize: MediaQuery.of(context).size.width / 8,
            // Adjust the icon size here
            color: _isSelected ? Colors.white : Color(0xFFB69DF8),
            // Set the icon color based on the state
            onPressed: () async {
              setState(() {
                _isSelected =
                    true; // Toggle the state when the button is pressed
              });

              // have this showBottomSheet to show different colors on category icon button automatically
              final showBottomSheet = await showModalBottomSheet(
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
                    child: AddOrEditSingleTransaction(
                      category: widget.category,
                      selectedDate: widget.selectedDate,
                    ),
                  );
                },
              );

              if (showBottomSheet == null) {
                setState(() {
                  _isSelected = false;
                });
              }
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

