import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/services/category_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart' as my_user_transaction;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

export 'package:aiko_ben_expense_app/services/category_service.dart'
    show
        getHouseholdCategoriesMap,
        getHouseholdPinnedCategoryIds,
        getHouseholdSelectedCategoryIds,
        updateHouseholdPinnedCategoryIds,
        updateHouseholdSelectedCategoryIds,
        updateHouseholdCategoryName,
        updateHouseholdCategoryIcon,
        updateHouseholdCategoryHidden,
        createHouseholdCategory,
        updateHouseholdCategory,
        pinCategory,
        unpinCategory,
        deleteHouseholdCategory,
        countTransactionsForCategory,
        reassignTransactionsCategory,
        parseCategoriesFromHouseholdData,
        parsePinnedCategoryIdsFromHouseholdData;

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
        final categoryId = doc.data()['categoryId'] as String?;
        final category = categoryId != null ? categoriesMap[categoryId] : null;
        if (category == null) continue;
        userTransactions.add(my_user_transaction.Transaction(
          transactionId: doc["transactionId"],
          category: category,
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

Future<String> getHouseholdName(String householdId) async {
  final household = await householdDocRef(householdId).get();
  return (household.data()?['name'] as String?) ?? 'Home';
}
