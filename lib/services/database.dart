import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/shared/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart' as my_user_transaction;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// All shared ledger data lives under `households/{householdId}`:
/// - transactions in the `transactions` subcollection
/// - budget / categories / selectedCategoryIds as fields on the household doc
class DatabaseService {

  final String? householdId;
  final Uuid uuid = Uuid();
  late Map<String, Category> categoriesMap;

  DatabaseService({this.householdId});

  DocumentReference<Map<String, dynamic>> get _householdDoc =>
      FirebaseFirestore.instance.collection('households').doc(householdId);

  CollectionReference<Map<String, dynamic>> get _transactionsCollection =>
      _householdDoc.collection('transactions');

  void setUserCategoriesMap(Map<String, Category> categoriesMapFromHome) {
    categoriesMap = categoriesMapFromHome;
  }

  Stream<List<my_user_transaction.Transaction>?>? get transactions {
    return _transactionsCollection.snapshots().map((docSnapshot) {
      List<my_user_transaction.Transaction> userTransactions = [];
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in docSnapshot.docs) {
        userTransactions.add(my_user_transaction.Transaction(
          transactionId: doc["transactionId"],
          category: categoriesMap[doc["categoryId"]]!,
          transactionAmount: doc["transactionAmount"],
          transactionComment: doc["transactionComment"],
          dateTime: doc["dateTime"].toDate(),
          createdByUid: doc.data().containsKey("createdByUid")
              ? doc["createdByUid"]
              : null,
          createdByName: doc.data().containsKey("createdByName")
              ? doc["createdByName"]
              : null,
        ));
      }
      return userTransactions;
    });
  }

  Future addNewTransaction(
    String categoryId,
    double transactionAmount,
    String? transactionComment,
    DateTime selectedDate, {
    String? createdByUid,
    String? createdByName,
  }) async {
    var newTransaction = <String, dynamic>{
      "transactionId": generateTransactionId(),
      "dateTime": selectedDate,
      "categoryId": categoryId,
      "transactionAmount": transactionAmount,
      "transactionComment": transactionComment ?? "Shopping",
      "createdByUid": createdByUid,
      "createdByName": createdByName,
    };
    return await _transactionsCollection
        .doc(newTransaction["transactionId"])
        .set(newTransaction)
        .catchError((e) => debugPrint("Error adding document: $e"));
  }

  Future editTransactionById(String transactionId, String categoryId, double newTransactionAmount, String? newTransactionComment, DateTime newSelectedDate) async {
    try {
      final DocumentReference documentReference =
          _transactionsCollection.doc(transactionId);

      await documentReference.update({
        "dateTime": newSelectedDate,
        "transactionAmount": newTransactionAmount,
        "transactionComment": newTransactionComment,
        "categoryId": categoryId,
      });
    } catch (e) {
      debugPrint('Error updating transaction document: $e');
    }
  }

  Future removeTransactionById(String transactionId) async {
    try {
      await _transactionsCollection.doc(transactionId).delete();
    } catch (e) {
      debugPrint('Error deleting transaction document: $e');
    }
  }

  String generateTransactionId() {
    return uuid.v4(); // Generates a random UUID (Version 4)
  }
}

DocumentReference<Map<String, dynamic>> _householdDocRef(String householdId) =>
    FirebaseFirestore.instance.collection('households').doc(householdId);

Future<String> getHouseholdName(String householdId) async {
  final household = await _householdDocRef(householdId).get();
  return (household.data()?['name'] as String?) ?? 'Home';
}

Future<Map<String, Category>> getHouseholdCategoriesMap(
    String householdId) async {
  final household = await _householdDocRef(householdId).get();
  if (household.exists) {
    final Map<String, dynamic> categoriesData =
        Map<String, dynamic>.from(household.data()!['categories'] ?? {});

    final Map<String, Category> categoriesMap = {};
    categoriesData.forEach((categoryId, categoryData) {
      categoriesMap[categoryId] = Category(
          categoryId: categoryId,
          categoryName: categoryData["categoryName"],
          categoryIcon:
              Icon(stringToSupportedIconsMap[categoryData["categoryIcon"]]));
    });
    return categoriesMap;
  } else {
    throw Exception('Failed to get household categories map');
  }
}

Future<List<String>> getHouseholdSelectedCategoryIds(String householdId) async {
  final household = await _householdDocRef(householdId).get();
  if (household.exists) {
    return List<String>.from(household.data()!['selectedCategoryIds'] ?? []);
  } else {
    throw Exception('Failed to get household selected category ids');
  }
}

Future<void> updateHouseholdSelectedCategoryIds(
    String householdId, List<String> selectedCategoryIds) async {
  await _householdDocRef(householdId)
      .update({'selectedCategoryIds': selectedCategoryIds});
}

Future<void> updateHouseholdCategoryName(
    String householdId, String selectedCategoryId, String newCategoryName) async {
  await _householdDocRef(householdId).update({
    'categories.$selectedCategoryId.categoryName': newCategoryName,
  });
}
