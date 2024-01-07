import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/shared/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart' as my_user_transaction;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {

  String? uid;
  final Uuid uuid = Uuid();
  late Map<String, Category> categoriesMap;
  DatabaseService({this.uid});

  final double DEFAULT_MONTHLY_BUDGET = 2000.0;

  // collection reference
  final transactionsCollection = FirebaseFirestore.instance.collection('transactions');
  final settingsCollection = FirebaseFirestore.instance.collection('settings');

  void setUserCategoriesMap(Map<String, Category> categoriesMapFromHome) {
    categoriesMap = categoriesMapFromHome;
  }


  // // this stream of categories may not be needed, since it's not constantly changing.
  // Stream<Map<String, Category>?>? get categoriesMap {
  //   return settingsCollection.doc(uid).snapshots().map((docSnapshot) {
  //     Map<String, Category> userCategoriesMap = {};
  //     final categoriesData = docSnapshot['categories'];
  //     categoriesData.forEach((categoryId, categoryData) {
  //       userCategoriesMap[categoryId] = Category(
  //           categoryId: categoryId,
  //           categoryName: categoryData["categoryName"],
  //           categoryIcon:
  //               Icon(stringToSupportedIconsMap[categoryData["categoryIcon"]]));
  //     });
  //     return userCategoriesMap;
  //   });
  // }

  Stream<List<my_user_transaction.Transaction>?>? get transactions {

    return transactionsCollection
        .doc(uid)
        .collection('userTransactions')
        .snapshots()
        .map((docSnapshot) {
      List<my_user_transaction.Transaction> userTransactions = [];
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in docSnapshot.docs) {
        userTransactions.add(my_user_transaction.Transaction(
          transactionId: doc["transactionId"],
          category: categoriesMap[doc["categoryId"]]!,
          transactionAmount: doc["transactionAmount"],
          transactionComment: doc["transactionComment"],
          dateTime: doc["dateTime"].toDate(),
        ));
      }
      return userTransactions;
    });
  }

  Future<void> addDefaultSetting(String name, String email) async {
    final settingsCollection =
        FirebaseFirestore.instance.collection('settings').doc(uid);
    final Map<String, Map<String, dynamic>> userCategories = {};

    defaultCategories.forEach((category) {
      userCategories[category.categoryId] = {
        'categoryName': category.categoryName,
        'categoryIcon': supportedIconsToStringMap[category.categoryIcon.icon],
      };
    });

    return await settingsCollection.set(
      {
        'categories': userCategories,
        'name': name,
        'email': email,
        'monthlyBudget': DEFAULT_MONTHLY_BUDGET,
      },
      SetOptions(merge: true),
    ).onError((e, _) => print("Error writing document: $e"));
  }

  Future addNewTransaction(String categoryId, double transactionAmount, String? transactionComment, DateTime selectedDate) async {
    // Create a new user with a first and last name
    var newTransaction = <String, dynamic>{
      "transactionId": generateTransactionId(),
      "dateTime": selectedDate,
      "categoryId": categoryId,
      "transactionAmount": transactionAmount,
      "transactionComment": transactionComment ?? "Shopping",
    };
    return await transactionsCollection
        .doc(uid)
        .collection('userTransactions')
        .doc(newTransaction["transactionId"])
        .set(newTransaction)
        .catchError((e) => print("Error adding document: $e"));
  }

  Future editTransactionById(String transactionId, String categoryId, double newTransactionAmount, String? newTransactionComment, DateTime newSelectedDate) async {
    try {
      final DocumentReference documentReference = transactionsCollection
          .doc(uid)
          .collection('userTransactions')
          .doc(transactionId);

      // Update the document with the new values
      await documentReference.update({
        "dateTime": newSelectedDate,
        "transactionAmount": newTransactionAmount,
        "transactionComment": newTransactionComment,
        "categoryId": categoryId,
      });
      print('Document with transaction ID $transactionId updated successfully');
    } catch (e) {
      print('Error updating transaction document: $e');
    }
  }

  Future removeTransactionById(String transactionId) async {
    try {
      // Reference to the Firestore collection and document with the given ID
      final DocumentReference documentReference = transactionsCollection
          .doc(uid)
          .collection('userTransactions')
          .doc(transactionId);

      // Delete the document
      await documentReference.delete();

      print('Document with transaction ID $transactionId deleted successfully');
    } catch (e) {
      print('Error deleting transaction document: $e');
    }
  }

  String generateTransactionId() {
    return uuid.v4(); // Generates a random UUID (Version 4)
  }
}

Future<Map<String, Category>> getUserCategoriesMap(String uid) async {
  final settingsCollection = FirebaseFirestore.instance.collection('settings').doc(uid);

  final userSetting = await settingsCollection.get();
  if (userSetting.exists) {
    final Map<String, dynamic> categoriesData =
    Map<String, dynamic>.from(userSetting.data()!['categories'] ?? {});

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
    // User document doesn't exist, return default categories as a map
    return defaultCategoriesMap;
  }
}
