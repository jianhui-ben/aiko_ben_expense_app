import 'package:flutter/material.dart';

enum CategoryIconGroup {
  foodDrink('Food & Drink'),
  homeBills('Home & Bills'),
  transport('Transport'),
  healthPersonal('Health & Personal'),
  funShopping('Fun & Shopping'),
  other('Other');

  const CategoryIconGroup(this.label);
  final String label;
}

class CategoryIconEntry {
  final String key;
  final String label;
  final CategoryIconGroup group;
  final IconData iconData;

  const CategoryIconEntry({
    required this.key,
    required this.label,
    required this.group,
    required this.iconData,
  });
}

/// Curated icon library for category customization (~100 entries).
const List<CategoryIconEntry> categoryIconLibrary = [
  // Food & Drink
  CategoryIconEntry(key: 'shopping_cart', label: 'Grocery', group: CategoryIconGroup.foodDrink, iconData: Icons.shopping_cart),
  CategoryIconEntry(key: 'local_grocery_store', label: 'Grocery store', group: CategoryIconGroup.foodDrink, iconData: Icons.local_grocery_store),
  CategoryIconEntry(key: 'grocery_organic', label: 'Organic', group: CategoryIconGroup.foodDrink, iconData: Icons.eco),
  CategoryIconEntry(key: 'grocery_snacks', label: 'Snacks', group: CategoryIconGroup.foodDrink, iconData: Icons.fastfood),
  CategoryIconEntry(key: 'grocery_beverages', label: 'Beverages', group: CategoryIconGroup.foodDrink, iconData: Icons.local_drink),
  CategoryIconEntry(key: 'grocery_fresh_produce', label: 'Produce', group: CategoryIconGroup.foodDrink, iconData: Icons.grass),
  CategoryIconEntry(key: 'restaurant', label: 'Restaurant', group: CategoryIconGroup.foodDrink, iconData: Icons.local_dining),
  CategoryIconEntry(key: 'restaurant_fast_food', label: 'Fast food', group: CategoryIconGroup.foodDrink, iconData: Icons.fastfood),
  CategoryIconEntry(key: 'restaurant_fine_dining', label: 'Fine dining', group: CategoryIconGroup.foodDrink, iconData: Icons.restaurant),
  CategoryIconEntry(key: 'coffee_shops', label: 'Coffee', group: CategoryIconGroup.foodDrink, iconData: Icons.local_cafe),
  CategoryIconEntry(key: 'restaurant_coffee_shops', label: 'Cafe', group: CategoryIconGroup.foodDrink, iconData: Icons.coffee),
  CategoryIconEntry(key: 'coffee_shops_desserts', label: 'Desserts', group: CategoryIconGroup.foodDrink, iconData: Icons.icecream),
  CategoryIconEntry(key: 'local_bar', label: 'Bar', group: CategoryIconGroup.foodDrink, iconData: Icons.local_bar),
  CategoryIconEntry(key: 'local_pizza', label: 'Pizza', group: CategoryIconGroup.foodDrink, iconData: Icons.local_pizza),
  CategoryIconEntry(key: 'bakery', label: 'Bakery', group: CategoryIconGroup.foodDrink, iconData: Icons.bakery_dining),
  CategoryIconEntry(key: 'liquor', label: 'Liquor', group: CategoryIconGroup.foodDrink, iconData: Icons.liquor),
  CategoryIconEntry(key: 'ramen', label: 'Takeout', group: CategoryIconGroup.foodDrink, iconData: Icons.ramen_dining),

  // Home & Bills
  CategoryIconEntry(key: 'house', label: 'House', group: CategoryIconGroup.homeBills, iconData: Icons.house),
  CategoryIconEntry(key: 'home_decor', label: 'Home decor', group: CategoryIconGroup.homeBills, iconData: Icons.home),
  CategoryIconEntry(key: 'home_decor_furniture', label: 'Furniture', group: CategoryIconGroup.homeBills, iconData: Icons.weekend),
  CategoryIconEntry(key: 'utility', label: 'Utility', group: CategoryIconGroup.homeBills, iconData: Icons.electrical_services),
  CategoryIconEntry(key: 'home_repairs_electrical_work', label: 'Electrical', group: CategoryIconGroup.homeBills, iconData: Icons.electric_bolt),
  CategoryIconEntry(key: 'bolt', label: 'Electricity', group: CategoryIconGroup.homeBills, iconData: Icons.bolt),
  CategoryIconEntry(key: 'water_drop', label: 'Water', group: CategoryIconGroup.homeBills, iconData: Icons.water_drop),
  CategoryIconEntry(key: 'wifi', label: 'Internet', group: CategoryIconGroup.homeBills, iconData: Icons.wifi),
  CategoryIconEntry(key: 'home_repairs', label: 'Repairs', group: CategoryIconGroup.homeBills, iconData: Icons.build),
  CategoryIconEntry(key: 'home_repairs_plumbing', label: 'Plumbing', group: CategoryIconGroup.homeBills, iconData: Icons.plumbing),
  CategoryIconEntry(key: 'diy_projects', label: 'DIY', group: CategoryIconGroup.homeBills, iconData: Icons.build_circle),
  CategoryIconEntry(key: 'diy_projects_tools', label: 'Tools', group: CategoryIconGroup.homeBills, iconData: Icons.handyman),
  CategoryIconEntry(key: 'cleaning', label: 'Cleaning', group: CategoryIconGroup.homeBills, iconData: Icons.cleaning_services),
  CategoryIconEntry(key: 'laundry', label: 'Laundry', group: CategoryIconGroup.homeBills, iconData: Icons.checkroom),
  CategoryIconEntry(key: 'local_laundry', label: 'Dry cleaning', group: CategoryIconGroup.homeBills, iconData: Icons.local_laundry_service),
  CategoryIconEntry(key: 'yard', label: 'Garden', group: CategoryIconGroup.homeBills, iconData: Icons.yard),
  CategoryIconEntry(key: 'rent', label: 'Rent', group: CategoryIconGroup.homeBills, iconData: Icons.apartment),

  // Transport
  CategoryIconEntry(key: 'travel', label: 'Travel', group: CategoryIconGroup.transport, iconData: Icons.flight),
  CategoryIconEntry(key: 'travel_hotel_stays', label: 'Hotel', group: CategoryIconGroup.transport, iconData: Icons.hotel),
  CategoryIconEntry(key: 'commute', label: 'Commute', group: CategoryIconGroup.transport, iconData: Icons.commute),
  CategoryIconEntry(key: 'directions_car', label: 'Car', group: CategoryIconGroup.transport, iconData: Icons.directions_car),
  CategoryIconEntry(key: 'car_maintenance', label: 'Car wash', group: CategoryIconGroup.transport, iconData: Icons.local_car_wash),
  CategoryIconEntry(key: 'car_maintenance_oil_change', label: 'Car service', group: CategoryIconGroup.transport, iconData: Icons.car_repair),
  CategoryIconEntry(key: 'car_maintenance_tire_replacement', label: 'Tires', group: CategoryIconGroup.transport, iconData: Icons.tire_repair),
  CategoryIconEntry(key: 'local_gas_station', label: 'Gas', group: CategoryIconGroup.transport, iconData: Icons.local_gas_station),
  CategoryIconEntry(key: 'train', label: 'Train', group: CategoryIconGroup.transport, iconData: Icons.train),
  CategoryIconEntry(key: 'directions_bus', label: 'Bus', group: CategoryIconGroup.transport, iconData: Icons.directions_bus),
  CategoryIconEntry(key: 'directions_bike', label: 'Bike', group: CategoryIconGroup.transport, iconData: Icons.directions_bike),
  CategoryIconEntry(key: 'outdoor_activities', label: 'Cycling', group: CategoryIconGroup.transport, iconData: Icons.pedal_bike),
  CategoryIconEntry(key: 'parking', label: 'Parking', group: CategoryIconGroup.transport, iconData: Icons.local_parking),
  CategoryIconEntry(key: 'taxi', label: 'Taxi', group: CategoryIconGroup.transport, iconData: Icons.local_taxi),
  CategoryIconEntry(key: 'rideshare', label: 'Rideshare', group: CategoryIconGroup.transport, iconData: Icons.hail),
  CategoryIconEntry(key: 'luggage', label: 'Luggage', group: CategoryIconGroup.transport, iconData: Icons.luggage),

  // Health & Personal
  CategoryIconEntry(key: 'medical', label: 'Medical', group: CategoryIconGroup.healthPersonal, iconData: Icons.medical_information),
  CategoryIconEntry(key: 'medical_prescription', label: 'Pharmacy', group: CategoryIconGroup.healthPersonal, iconData: Icons.medical_services),
  CategoryIconEntry(key: 'pet_expenses_veterinary_care', label: 'Vet', group: CategoryIconGroup.healthPersonal, iconData: Icons.local_hospital),
  CategoryIconEntry(key: 'fitness', label: 'Fitness', group: CategoryIconGroup.healthPersonal, iconData: Icons.fitness_center),
  CategoryIconEntry(key: 'fitness_gym_membership', label: 'Gym', group: CategoryIconGroup.healthPersonal, iconData: Icons.sports_gymnastics),
  CategoryIconEntry(key: 'fitness_yoga_classes', label: 'Yoga', group: CategoryIconGroup.healthPersonal, iconData: Icons.self_improvement),
  CategoryIconEntry(key: 'spa', label: 'Spa', group: CategoryIconGroup.healthPersonal, iconData: Icons.spa),
  CategoryIconEntry(key: 'content_cut', label: 'Haircut', group: CategoryIconGroup.healthPersonal, iconData: Icons.content_cut),
  CategoryIconEntry(key: 'child_care', label: 'Child care', group: CategoryIconGroup.healthPersonal, iconData: Icons.child_care),
  CategoryIconEntry(key: 'education', label: 'Education', group: CategoryIconGroup.healthPersonal, iconData: Icons.school),
  CategoryIconEntry(key: 'books_learning', label: 'Books', group: CategoryIconGroup.healthPersonal, iconData: Icons.menu_book),
  CategoryIconEntry(key: 'books_learning_online_courses', label: 'Courses', group: CategoryIconGroup.healthPersonal, iconData: Icons.book_online),
  CategoryIconEntry(key: 'health_insurance', label: 'Insurance', group: CategoryIconGroup.healthPersonal, iconData: Icons.health_and_safety),

  // Fun & Shopping
  CategoryIconEntry(key: 'entertainment', label: 'Entertainment', group: CategoryIconGroup.funShopping, iconData: Icons.gamepad),
  CategoryIconEntry(key: 'entertainment_concerts', label: 'Music', group: CategoryIconGroup.funShopping, iconData: Icons.music_note),
  CategoryIconEntry(key: 'entertainment_streaming_services', label: 'Streaming', group: CategoryIconGroup.funShopping, iconData: Icons.tv),
  CategoryIconEntry(key: 'movie', label: 'Movies', group: CategoryIconGroup.funShopping, iconData: Icons.movie),
  CategoryIconEntry(key: 'theater', label: 'Theater', group: CategoryIconGroup.funShopping, iconData: Icons.theater_comedy),
  CategoryIconEntry(key: 'sports', label: 'Sports', group: CategoryIconGroup.funShopping, iconData: Icons.sports_soccer),
  CategoryIconEntry(key: 'clothing', label: 'Clothing', group: CategoryIconGroup.funShopping, iconData: Icons.shopping_bag),
  CategoryIconEntry(key: 'clothing_shoes', label: 'Shoes', group: CategoryIconGroup.funShopping, iconData: Icons.ice_skating),
  CategoryIconEntry(key: 'gifts_celebrations', label: 'Gifts', group: CategoryIconGroup.funShopping, iconData: Icons.card_giftcard),
  CategoryIconEntry(key: 'gifts_celebrations_decorations', label: 'Party', group: CategoryIconGroup.funShopping, iconData: Icons.cake),
  CategoryIconEntry(key: 'subscription', label: 'Subscription', group: CategoryIconGroup.funShopping, iconData: Icons.subscriptions),
  CategoryIconEntry(key: 'tech_gadgets', label: 'Tech', group: CategoryIconGroup.funShopping, iconData: Icons.devices),
  CategoryIconEntry(key: 'tech_gadgets_accessories', label: 'Accessories', group: CategoryIconGroup.funShopping, iconData: Icons.devices_other),
  CategoryIconEntry(key: 'pet_expenses', label: 'Pets', group: CategoryIconGroup.funShopping, iconData: Icons.pets),
  CategoryIconEntry(key: 'photo', label: 'Photo', group: CategoryIconGroup.funShopping, iconData: Icons.photo_camera),
  CategoryIconEntry(key: 'art', label: 'Art', group: CategoryIconGroup.funShopping, iconData: Icons.palette),

  // Other
  CategoryIconEntry(key: 'investments', label: 'Investments', group: CategoryIconGroup.other, iconData: Icons.trending_up),
  CategoryIconEntry(key: 'savings', label: 'Savings', group: CategoryIconGroup.other, iconData: Icons.savings),
  CategoryIconEntry(key: 'payments', label: 'Payments', group: CategoryIconGroup.other, iconData: Icons.payments),
  CategoryIconEntry(key: 'work', label: 'Work', group: CategoryIconGroup.other, iconData: Icons.work),
  CategoryIconEntry(key: 'charity', label: 'Charity', group: CategoryIconGroup.other, iconData: Icons.volunteer_activism),
  CategoryIconEntry(key: 'taxes', label: 'Taxes', group: CategoryIconGroup.other, iconData: Icons.receipt_long),
  CategoryIconEntry(key: 'legal', label: 'Legal', group: CategoryIconGroup.other, iconData: Icons.gavel),
  CategoryIconEntry(key: 'outdoor_activities_camping_gear', label: 'Camping', group: CategoryIconGroup.other, iconData: Icons.cabin),
  CategoryIconEntry(key: 'beach', label: 'Beach', group: CategoryIconGroup.other, iconData: Icons.beach_access),
  CategoryIconEntry(key: 'category', label: 'General', group: CategoryIconGroup.other, iconData: Icons.category),
];

final Map<String, IconData> categoryIconKeyToIconData = {
  for (final entry in categoryIconLibrary) entry.key: entry.iconData,
};

final Map<IconData, String> categoryIconDataToKey = {
  for (final entry in categoryIconLibrary) entry.iconData: entry.key,
};

CategoryIconEntry? lookupCategoryIconEntry(String key) {
  for (final entry in categoryIconLibrary) {
    if (entry.key == key) return entry;
  }
  return null;
}

List<CategoryIconEntry> filterCategoryIcons({
  String? query,
  CategoryIconGroup? group,
}) {
  final normalized = query?.trim().toLowerCase() ?? '';
  return categoryIconLibrary.where((entry) {
    final matchesGroup = group == null || entry.group == group;
    final matchesQuery = normalized.isEmpty ||
        entry.label.toLowerCase().contains(normalized) ||
        entry.key.toLowerCase().contains(normalized);
    return matchesGroup && matchesQuery;
  }).toList();
}

IconData iconDataForKey(String? key) {
  return categoryIconKeyToIconData[key] ?? Icons.category;
}

String iconKeyForIconData(IconData iconData) {
  return categoryIconDataToKey[iconData] ?? 'category';
}
