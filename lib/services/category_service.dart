import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/shared/category_icon_library.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

DocumentReference<Map<String, dynamic>> householdDocRef(String householdId) =>
    FirebaseFirestore.instance.collection('households').doc(householdId);

Category parseCategory(String categoryId, Map<String, dynamic> data) {
  final iconKey = data['categoryIcon'] as String? ?? 'category';
  return Category(
    categoryId: categoryId,
    categoryName: data['categoryName'] as String? ?? 'Category',
    categoryIcon: Icon(iconDataForKey(iconKey)),
    iconKey: iconKey,
    isHidden: data['isHidden'] as bool? ?? false,
  );
}

Map<String, Category> parseCategoriesFromHouseholdData(
    Map<String, dynamic>? householdData) {
  final categoriesData =
      Map<String, dynamic>.from(householdData?['categories'] ?? {});
  return {
    for (final entry in categoriesData.entries)
      entry.key:
          parseCategory(entry.key, Map<String, dynamic>.from(entry.value)),
  };
}

List<String> parsePinnedCategoryIdsFromHouseholdData(
    Map<String, dynamic>? householdData) {
  if (householdData == null) return [];
  if (householdData.containsKey('pinnedCategoryIds')) {
    return List<String>.from(householdData['pinnedCategoryIds']);
  }
  return List<String>.from(householdData['selectedCategoryIds'] ?? const []);
}

Future<Map<String, Category>> getHouseholdCategoriesMap(
    String householdId) async {
  final household = await householdDocRef(householdId).get();
  if (!household.exists) {
    throw Exception('Failed to get household categories map');
  }

  final categoriesData =
      Map<String, dynamic>.from(household.data()!['categories'] ?? {});
  return {
    for (final entry in categoriesData.entries)
      entry.key: parseCategory(entry.key, Map<String, dynamic>.from(entry.value)),
  };
}

Future<List<String>> getHouseholdPinnedCategoryIds(String householdId) async {
  final household = await householdDocRef(householdId).get();
  if (!household.exists) {
    throw Exception('Failed to get household pinned category ids');
  }

  final data = household.data()!;
  if (data.containsKey('pinnedCategoryIds')) {
    return List<String>.from(data['pinnedCategoryIds']);
  }

  final selected =
      List<String>.from(data['selectedCategoryIds'] ?? const <String>[]);
  if (selected.isNotEmpty) {
    await householdDocRef(householdId).update({
      'pinnedCategoryIds': selected,
    });
  }
  return selected;
}

Future<void> updateHouseholdPinnedCategoryIds(
  String householdId,
  List<String> pinnedCategoryIds,
) async {
  await householdDocRef(householdId).update({
    'pinnedCategoryIds': pinnedCategoryIds,
  });
}

Future<void> updateHouseholdCategoryName(
  String householdId,
  String categoryId,
  String newCategoryName,
) async {
  await householdDocRef(householdId).update({
    'categories.$categoryId.categoryName': newCategoryName,
  });
}

Future<void> updateHouseholdCategoryIcon(
  String householdId,
  String categoryId,
  String iconKey,
) async {
  await householdDocRef(householdId).update({
    'categories.$categoryId.categoryIcon': iconKey,
  });
}

Future<void> updateHouseholdCategoryHidden(
  String householdId,
  String categoryId,
  bool isHidden,
) async {
  await householdDocRef(householdId).update({
    'categories.$categoryId.isHidden': isHidden,
  });
}

Future<String> createHouseholdCategory({
  required String householdId,
  required String name,
  required String iconKey,
  bool pinToHome = false,
}) async {
  final categoryId = 'custom_${const Uuid().v4()}';
  final ref = householdDocRef(householdId);

  await ref.update({
    'categories.$categoryId': {
      'categoryName': name,
      'categoryIcon': iconKey,
      'isHidden': false,
      'createdAt': FieldValue.serverTimestamp(),
    },
  });

  if (pinToHome) {
    final pinned = await getHouseholdPinnedCategoryIds(householdId);
    if (!pinned.contains(categoryId)) {
      pinned.add(categoryId);
      await updateHouseholdPinnedCategoryIds(householdId, pinned);
    }
  }

  return categoryId;
}

Future<void> updateHouseholdCategory({
  required String householdId,
  required String categoryId,
  required String name,
  required String iconKey,
  required bool pinToHome,
}) async {
  final batch = FirebaseFirestore.instance.batch();
  final ref = householdDocRef(householdId);

  batch.update(ref, {
    'categories.$categoryId.categoryName': name,
    'categories.$categoryId.categoryIcon': iconKey,
  });

  final pinned = await getHouseholdPinnedCategoryIds(householdId);
  final isPinned = pinned.contains(categoryId);

  if (pinToHome && !isPinned) {
    pinned.add(categoryId);
    batch.update(ref, {'pinnedCategoryIds': pinned});
  } else if (!pinToHome && isPinned) {
    pinned.remove(categoryId);
    batch.update(ref, {'pinnedCategoryIds': pinned});
  }

  await batch.commit();
}

Future<void> pinCategory(String householdId, String categoryId) async {
  final pinned = await getHouseholdPinnedCategoryIds(householdId);
  if (!pinned.contains(categoryId)) {
    pinned.add(categoryId);
    await updateHouseholdPinnedCategoryIds(householdId, pinned);
  }
}

Future<void> unpinCategory(String householdId, String categoryId) async {
  final pinned = await getHouseholdPinnedCategoryIds(householdId);
  if (pinned.remove(categoryId)) {
    await updateHouseholdPinnedCategoryIds(householdId, pinned);
  }
}

Future<int> countTransactionsForCategory(
  String householdId,
  String categoryId,
) async {
  final snap = await householdDocRef(householdId)
      .collection('transactions')
      .where('categoryId', isEqualTo: categoryId)
      .count()
      .get();
  return snap.count ?? 0;
}

Future<void> reassignTransactionsCategory({
  required String householdId,
  required String fromCategoryId,
  required String toCategoryId,
}) async {
  final snap = await householdDocRef(householdId)
      .collection('transactions')
      .where('categoryId', isEqualTo: fromCategoryId)
      .get();

  if (snap.docs.isEmpty) return;

  final batch = FirebaseFirestore.instance.batch();
  for (final doc in snap.docs) {
    batch.update(doc.reference, {'categoryId': toCategoryId});
  }
  await batch.commit();
}

Future<void> deleteHouseholdCategory({
  required String householdId,
  required String categoryId,
  String? reassignToCategoryId,
}) async {
  final txnCount = await countTransactionsForCategory(householdId, categoryId);
  if (txnCount > 0 && reassignToCategoryId == null) {
    throw StateError('Category has transactions and no reassignment target');
  }

  if (txnCount > 0 && reassignToCategoryId != null) {
    await reassignTransactionsCategory(
      householdId: householdId,
      fromCategoryId: categoryId,
      toCategoryId: reassignToCategoryId,
    );
  }

  final pinned = await getHouseholdPinnedCategoryIds(householdId);
  pinned.remove(categoryId);

  await householdDocRef(householdId).update({
    'pinnedCategoryIds': pinned,
    'categories.$categoryId': FieldValue.delete(),
  });
}

/// Legacy helpers kept for backward compatibility during migration.
Future<List<String>> getHouseholdSelectedCategoryIds(String householdId) =>
    getHouseholdPinnedCategoryIds(householdId);

Future<void> updateHouseholdSelectedCategoryIds(
  String householdId,
  List<String> selectedCategoryIds,
) =>
    updateHouseholdPinnedCategoryIds(householdId, selectedCategoryIds);
