
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:flutter/material.dart';

class Category {

  final String categoryId;
  final String categoryName;
  final Icon categoryIcon;
  late List<Transaction?> transactionsUnderCategory;

  Category({required this.categoryId, required this.categoryName, required this.categoryIcon});

}

final List<Category> defaultCategories = [
  Category(
    categoryId: '1',
    categoryName: 'Grocery',
    categoryIcon: const Icon(Icons.shopping_cart),
  ),
  Category(
    categoryId: '2',
    categoryName: 'House',
    categoryIcon: const Icon(Icons.house),
  ),
  Category(
    categoryId: '3',
    categoryName: 'Travel',
    categoryIcon: const Icon(Icons.flight),
  ),
  Category(
    categoryId: '4',
    categoryName: 'Restaurant',
    categoryIcon: const Icon(Icons.local_dining),
  ),
  Category(
    categoryId: '5',
    categoryName: 'Travel',
    categoryIcon: const Icon(Icons.flight),
  ),
  Category(
    categoryId: '6',
    categoryName: 'Medical',
    categoryIcon: const Icon(Icons.medical_information),
  ),
  Category(
    categoryId: '7',
    categoryName: 'Utility',
    categoryIcon: const Icon(Icons.electrical_services),
  ),
  Category(
    categoryId: '8',
    categoryName: 'Commute',
    categoryIcon: const Icon(Icons.commute),
  ),
  // Add more default categories as needed
];