
import 'package:flutter/material.dart';

class Category {
  final String categoryId;
  String categoryName;
  final Icon categoryIcon;
  final String iconKey;
  final bool isHidden;

  Category({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    this.iconKey = 'category',
    this.isHidden = false,
  });

  bool get isCustom => categoryId.startsWith('custom_');

  Category copyWith({
    String? categoryName,
    Icon? categoryIcon,
    String? iconKey,
    bool? isHidden,
  }) {
    return Category(
      categoryId: categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      iconKey: iconKey ?? this.iconKey,
      isHidden: isHidden ?? this.isHidden,
    );
  }
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
    categoryName: 'Laundry',
    categoryIcon: const Icon(Icons.checkroom),
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


final Map<String, Category> defaultCategoriesMap = {
  for (final category in defaultCategories) category.categoryId: category,
};

Category? getCategory(String categoryId) {
  return defaultCategoriesMap[categoryId];
}