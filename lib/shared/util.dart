import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:flutter/material.dart';

//put commonly used util functions here
class Util {

  static List<Transaction> filterTransactionListToDate(
      List<Transaction>? transactionStream, DateTime selectedDate) {
    return transactionStream!.where((transaction) {
      final transactionDate = transaction.dateTime!;
      return transactionDate.year == selectedDate.year &&
          transactionDate.month == selectedDate.month &&
          transactionDate.day == selectedDate.day;
    }).toList();
  }

  static List<Transaction> filterTransactionListToLastSevenDays(
      List<Transaction>? transactionStream, DateTime selectedDate) {
    DateTime startDate = selectedDate.subtract(const Duration(days: 6));
    return transactionStream!.where((transaction) {
      final transactionDate = transaction.dateTime;
      // Check if the transaction date is within the calculated week
      return transactionDate != null &&
          !transactionDate.isBefore(startDate) &&
          !transactionDate.isAfter(selectedDate);
    }).toList();
  }

  static List<Transaction> filterTransactionListToMonth(
      List<Transaction>? transactionStream, DateTime selectedDate) {
    return transactionStream!.where((transaction) {
      final transactionDate = transaction.dateTime!;
      return transactionDate.year == selectedDate.year &&
          transactionDate.month == selectedDate.month;
    }).toList();
  }

  static List<Transaction> filterTransactionListToYear(
      List<Transaction>? transactionStream, DateTime selectedDate) {
    return transactionStream!.where((transaction) {
      final transactionDate = transaction.dateTime!;
      return transactionDate.year == selectedDate.year;
    }).toList();
  }

}