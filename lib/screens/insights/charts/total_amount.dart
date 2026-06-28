import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/shared/util.dart';
import 'package:flutter/material.dart';

class TotalAmount extends StatelessWidget {

  final String title;
  final List<Transaction> transactions;

  const TotalAmount({super.key, required this.title, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.labelMedium),
        Text(
          '\$${Util.sumTotal(transactions).toStringAsFixed(0)}',
          style: theme.textTheme.headlineLarge,
        ),
      ],
    );
  }
}

