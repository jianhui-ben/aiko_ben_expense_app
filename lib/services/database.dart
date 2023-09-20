import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart' as my_user_transaction;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {

  String? uid;
  DatabaseService({ this.uid });
  final Uuid uuid = Uuid();

  // collection reference
  final transactionsCollection = FirebaseFirestore.instance.collection('transactions');

  // create another stream of brew to update the brew list
  Stream<List<my_user_transaction.Transaction>?>? get transactions {

    // transactionsCollection.doc(uid).collection("userTransactions").get().then(
    //       (querySnapshot) {
    //     print("Successfully completed");
    //     for (var docSnapshot in querySnapshot.docs) {
    //       print('${docSnapshot.id}');
    //     }
    //   },
    //   onError: (e) => print("Error completing: $e"),
    // );

    return transactionsCollection
        .doc(uid)
        .collection('userTransactions')
        .snapshots()
        .map((docSnapshot) {
      List<my_user_transaction.Transaction> userTransactions = [];
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in docSnapshot.docs) {
        // Convert data from the document to transaction
        userTransactions.add(my_user_transaction.Transaction(
            transactionId: doc["transactionId"],
            category: Category(
                categoryId: doc["categoryId"],
                categoryName: "test category",
                categoryIcon: Icon(Icons.shopping_cart)),
            transactionAmount: doc["transactionAmount"],
            transactionComment: doc["transactionComment"],
            dateTime: doc["dateTime"].toDate()));
      }
      return userTransactions;
    });
  }

  Future addDefaultCategories() async {
    final settingsCollection = FirebaseFirestore.instance.collection('settings').doc(uid);
    final userCategories = defaultCategories.map((category) {
      return {
        'categoryId': category.categoryId,
        'categoryName': category.categoryName,
        'categoryIcon': category.categoryIcon,
      };
    }).toList();
    return await settingsCollection.set(
        {'categories': userCategories}, SetOptions(merge: true))
        .onError((e, _) => print("Error writing document: $e"));
  }

  Future<List<Category>> getUserCategories(String uid) async {
    final settingsCollection = FirebaseFirestore.instance.collection('settings').doc(uid);

    final userSetting = await settingsCollection.get();
    if (userSetting.exists) {
      final categories = List<Map<String, dynamic>>.from(userSetting.data()!['categories'] ?? []);
      return categories.map((categoryData) {
        return Category(
          categoryId: categoryData['categoryId'],
          categoryName: categoryData['categoryName'],
          categoryIcon: categoryData['categoryIcon'],
        );
      }).toList();
    } else {
      // User document doesn't exist, return default categories
      return defaultCategories;
    }
  }

  Future addNewTransaction(String categoryId, double transactionAmount, String? transactionComment) async {
    DateTime now = DateTime.now();
    // Create a new user with a first and last name
    var newTransaction = <String, dynamic>{
      "transactionId": generateTransactionId(),
      "dateTime": DateTime(now.year, now.month, now.day),
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