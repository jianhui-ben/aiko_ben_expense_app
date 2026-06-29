import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:flutter/material.dart';

/// Builds a [Category] for tests.
Category cat(String id, String name) => Category(
      categoryId: id,
      categoryName: name,
      categoryIcon: const Icon(Icons.category),
    );

int _seq = 0;

/// Builds a [Transaction] for tests with sensible defaults.
Transaction tx({
  required Category category,
  required double amount,
  required DateTime date,
  String? comment,
  String? by,
}) {
  return Transaction(
    transactionId: 'tx-${_seq++}',
    category: category,
    transactionAmount: amount,
    dateTime: date,
    transactionComment: comment,
    createdByName: by,
  );
}
