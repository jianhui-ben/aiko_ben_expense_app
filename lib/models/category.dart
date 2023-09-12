
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:flutter/material.dart';

class Category {

  final String categoryId;
  final String categoryName;
  final Icon categoryIcon;
  late List<Transaction?> transactionsUnderCategory;

  Category({required this.categoryId, required this.categoryName, required this.categoryIcon});

}