import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:flutter/material.dart';

final List<Category> allCategories = [
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
  Category(
    categoryId: '9',
    categoryName: 'Education',
    categoryIcon: const Icon(Icons.school),
  ),
  Category(
    categoryId: '10',
    categoryName: 'Investments',
    categoryIcon: const Icon(Icons.trending_up),
  ),
  Category(
    categoryId: '11',
    categoryName: 'Entertainment',
    categoryIcon: const Icon(Icons.gamepad),
  ),
  Category(
    categoryId: '12',
    categoryName: 'Clothing',
    categoryIcon: const Icon(Icons.shopping_bag),
  ),
  Category(
    categoryId: '13',
    categoryName: 'Home Repairs',
    categoryIcon: const Icon(Icons.build),
  ),
  Category(
    categoryId: '14',
    categoryName: 'Subscription',
    categoryIcon: const Icon(Icons.subscriptions),
  ),
  Category(
    categoryId: '15',
    categoryName: 'Fitness',
    categoryIcon: const Icon(Icons.fitness_center),
  ),
  Category(
    categoryId: '16',
    categoryName: 'Tech Gadgets',
    categoryIcon: const Icon(Icons.devices),
  ),
  Category(
    categoryId: '17',
    categoryName: 'Pet Expenses',
    categoryIcon: const Icon(Icons.pets),
  ),
  Category(
    categoryId: '18',
    categoryName: 'Home Decor',
    categoryIcon: const Icon(Icons.home),
  ),
  Category(
    categoryId: '19',
    categoryName: 'Grocery - Organic',
    categoryIcon: const Icon(Icons.eco),
  ),
  Category(
    categoryId: '20',
    categoryName: 'Car Maintenance',
    categoryIcon: const Icon(Icons.local_car_wash),
  ),
  Category(
    categoryId: '21',
    categoryName: 'Books & Learning',
    categoryIcon: const Icon(Icons.menu_book),
  ),
  Category(
    categoryId: '22',
    categoryName: 'Coffee Shops',
    categoryIcon: const Icon(Icons.local_cafe),
  ),
  Category(
    categoryId: '23',
    categoryName: 'Outdoor Activities',
    categoryIcon: const Icon(Icons.directions_bike),
  ),
  Category(
    categoryId: '24',
    categoryName: 'DIY Projects',
    categoryIcon: const Icon(Icons.build_circle),
  ),
  Category(
    categoryId: '25',
    categoryName: 'Gifts & Celebrations',
    categoryIcon: const Icon(Icons.card_giftcard),
  ),
  Category(
    categoryId: '26',
    categoryName: 'Restaurant - Fast Food',
    categoryIcon: const Icon(Icons.fastfood),
  ),
  Category(
    categoryId: '27',
    categoryName: 'Restaurant - Fine Dining',
    categoryIcon: const Icon(Icons.local_dining),
  ),
  Category(
    categoryId: '28',
    categoryName: 'Restaurant - Coffee Shops',
    categoryIcon: const Icon(Icons.local_cafe),
  ),
  Category(
    categoryId: '29',
    categoryName: 'Grocery - Fresh Produce',
    categoryIcon: const Icon(Icons.local_grocery_store),
  ),
  Category(
    categoryId: '30',
    categoryName: 'Grocery - Snacks',
    categoryIcon: const Icon(Icons.fastfood),
  ),
  Category(
    categoryId: '31',
    categoryName: 'Medical - Prescription',
    categoryIcon: const Icon(Icons.medical_services),
  ),
  Category(
    categoryId: '32',
    categoryName: 'Fitness - Gym Membership',
    categoryIcon: const Icon(Icons.fitness_center),
  ),
  Category(
    categoryId: '33',
    categoryName: 'Home Repairs - Plumbing',
    categoryIcon: const Icon(Icons.plumbing),
  ),
  Category(
    categoryId: '34',
    categoryName: 'Entertainment - Concerts',
    categoryIcon: const Icon(Icons.music_note),
  ),
  Category(
    categoryId: '35',
    categoryName: 'Car Maintenance - Oil Change',
    categoryIcon: const Icon(Icons.local_car_wash),
  ),
  Category(
    categoryId: '36',
    categoryName: 'Tech Gadgets - Accessories',
    categoryIcon: const Icon(Icons.devices_other),
  ),
  Category(
    categoryId: '37',
    categoryName: 'Pet Expenses - Veterinary Care',
    categoryIcon: const Icon(Icons.local_hospital),
  ),
  Category(
    categoryId: '38',
    categoryName: 'Home Decor - Furniture',
    categoryIcon: const Icon(Icons.weekend),
  ),
  Category(
    categoryId: '39',
    categoryName: 'Grocery - Beverages',
    categoryIcon: const Icon(Icons.local_drink),
  ),
  Category(
    categoryId: '40',
    categoryName: 'Car Maintenance - Tire Replacement',
    categoryIcon: const Icon(Icons.electric_rickshaw),
  ),
  Category(
    categoryId: '41',
    categoryName: 'Books & Learning - Online Courses',
    categoryIcon: const Icon(Icons.book_online),
  ),
  Category(
    categoryId: '42',
    categoryName: 'Coffee Shops - Desserts',
    categoryIcon: const Icon(Icons.icecream),
  ),
  Category(
    categoryId: '43',
    categoryName: 'Outdoor Activities - Camping Gear',
    categoryIcon: const Icon(Icons.local_fire_department_sharp),
  ),
  Category(
    categoryId: '44',
    categoryName: 'DIY Projects - Tools',
    categoryIcon: const Icon(Icons.build),
  ),
  Category(
    categoryId: '45',
    categoryName: 'Gifts & Celebrations - Decorations',
    categoryIcon: const Icon(Icons.cake),
  ),
  Category(
    categoryId: '46',
    categoryName: 'Travel - Hotel Stays',
    categoryIcon: const Icon(Icons.hotel),
  ),
  Category(
    categoryId: '47',
    categoryName: 'Clothing - Shoes',
    categoryIcon: const Icon(Icons.shopping_bag),
  ),
  Category(
    categoryId: '48',
    categoryName: 'Home Repairs - Electrical Work',
    categoryIcon: const Icon(Icons.electrical_services),
  ),
  Category(
    categoryId: '49',
    categoryName: 'Entertainment - Streaming Services',
    categoryIcon: const Icon(Icons.tv),
  ),
  Category(
    categoryId: '50',
    categoryName: 'Fitness - Yoga Classes',
    categoryIcon: const Icon(Icons.self_improvement),
  ),
];
