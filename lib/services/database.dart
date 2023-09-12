import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart' as my_user_transaction;
import 'package:flutter/material.dart';

class DatabaseService {

  String? uid;
  DatabaseService({ this.uid });

  // collection reference
  final transactionsCollection = FirebaseFirestore.instance.collection('transactions');

  // create another stream of brew to update the brew list
  Stream<List<my_user_transaction.Transaction>?>? get transactions {
    return transactionsCollection
        .doc(uid)
        .collection('userTransactions')
        .snapshots()
        .map((docSnapshot) {
      List<my_user_transaction.Transaction> userTransactions = [];

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc
          in docSnapshot.docs) {
        // Convert data from the document to transaction
        userTransactions.add(my_user_transaction.Transaction(
            category: Category(
                categoryId: doc["categoryId"],
                categoryName: "test category",
                categoryIcon: Icon(Icons.shopping_cart)),
            transactionAmount: doc["transactionAmount"],
            transactionComment: doc["transactionComment"],
            dateTime: DateTime.parse(doc["dateTime"])));
      }
      return userTransactions;
    });
  }

  Future addNewTransaction(String categoryId, double transactionAmount, String transactionComment) async {
    DateTime now = DateTime.now();
    // Create a new user with a first and last name
    var newTransaction = <String, dynamic>{
      "dateTime": DateTime(now.year, now.month, now.day),
      "categoryId": categoryId,
      "transactionAmount": transactionAmount,
      "transactionComment": transactionComment,
    };
    return await transactionsCollection
        .doc(uid).collection('userTransactions')
        .add(newTransaction)
        .catchError((e) => print("Error adding document: $e"));
  }
}