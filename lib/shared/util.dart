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

  // calculate the total transaction amount for the current day
  static double sumTotal(List<Transaction> transactions) {
    return transactions.fold(
        0.0, (double sum, transaction) => sum + transaction.transactionAmount);
  }

  // sort the transactions by date descendingly (newest first) and if the same date,
  // then sort by amount descendingly
  static List<Transaction> sortTransactionsByDateAndAmount(List<Transaction> transactions) {
    transactions.sort((a, b) {
      if (a.dateTime!.isAfter(b.dateTime!)) {
        return -1;
      } else if (a.dateTime!.isBefore(b.dateTime!)) {
        return 1;
      } else {
        if (a.transactionAmount > b.transactionAmount) {
          return -1;
        } else if (a.transactionAmount < b.transactionAmount) {
          return 1;
        } else {
          return 0;
        }
      }
    });
    return transactions;
  }


  List<Transaction> filterTransactionsByDate(
      List<Transaction> transactions, DateTime selectedDate) {
    return transactions.where((transaction) {
      final transactionDate = transaction.dateTime!;
      return transactionDate.year == selectedDate.year &&
          transactionDate.month == selectedDate.month &&
          transactionDate.day == selectedDate.day;
    }).toList();
  }

  List<Transaction> filterTransactionsByMonth(
      List<Transaction> transactions, DateTime selectedDate) {
    return transactions.where((transaction) {
      final transactionDate = transaction.dateTime!;
      return transactionDate.year == selectedDate.year &&
          transactionDate.month == selectedDate.month;
    }).toList();
  }
}