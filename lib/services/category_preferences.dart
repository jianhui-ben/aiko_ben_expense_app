import 'package:shared_preferences/shared_preferences.dart';

const _lastCategoryKeyPrefix = 'last_category_';

class CategoryPreferences {
  static Future<void> saveLastUsedCategory(
      String householdId, String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_lastCategoryKeyPrefix$householdId', categoryId);
  }

  static Future<String?> getLastUsedCategory(String householdId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_lastCategoryKeyPrefix$householdId');
  }
}
