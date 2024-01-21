import 'package:aiko_ben_expense_app/models/all_categories.dart';
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

  Future<void> addDefaultSetting(String name) async {
    //only adding the user name for easy debugging, ideally there should be no user name
    // all the profile infor (user name, email, photourl) should be fetched from firebase auth directly, instead of the Setting collect
    final settingsCollection =
        FirebaseFirestore.instance.collection('settings').doc(uid);
    final Map<String, Map<String, dynamic>> userCategories = {};
    final List<String> defaultSelectedCategoryIds = ["1", "2", "3", "4", "5", "6", "7", "8"];

    for (var category in allCategories) {
      userCategories[category.categoryId] = {
        'categoryName': category.categoryName,
        'categoryIcon': supportedIconsToStringMap[category.categoryIcon.icon],
      };
    }

    return await settingsCollection.set(
      {
        'categories': userCategories, // here the categories define the actual categories that user want to show on the home page
        'name': name, // optional; here only for debugging purpose
        'monthlyBudget': DEFAULT_MONTHLY_BUDGET,
        'seletectedCategoryIds': defaultSelectedCategoryIds,
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
    throw Exception('Failed to get user categories map');
  }
}

Future<List<String>> getUserSelectedCategoryIds(String uid) async{
  final settingsCollection = FirebaseFirestore.instance.collection('settings').doc(uid);

  final userSetting = await settingsCollection.get();
  if (userSetting.exists) {
    final List<String> selectedCategoryIds = List<String>.from(userSetting.data()!['seletectedCategoryIds'] ?? []);
    return selectedCategoryIds;
  } else {
    throw Exception('Failed to get user selected category ids');
  }
}
