import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  String? uid;
  DatabaseService({ this.uid });

  // collection reference
  final transactionsCollection = FirebaseFirestore.instance.collection('transactions');


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
        .doc(uid)
        .set(newTransaction)
        .onError((e, _) => print("Error writing document: $e"));
  }
}