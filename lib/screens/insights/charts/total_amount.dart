import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/shared/util.dart';
import 'package:flutter/material.dart';

class TotalAmount extends StatelessWidget {

  final String title;
  final List<Transaction> transactions;

  const TotalAmount({super.key, required this.title, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          '\$${Util.sumTotal(transactions).toStringAsFixed(0)}',
          // Round to closest integer and add $
          style: TextStyle(fontSize: 24), // Adjust the font size as needed
        ),
      ],
    );
  }
}

