import 'package:aiko_ben_expense_app/models/transaction.dart';

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

  /// Transactions whose date falls within [startInclusive] .. [endInclusive],
  /// compared at day granularity (time of day is ignored).
  static List<Transaction> filterTransactionListToDateRange(
      List<Transaction>? transactionStream,
      DateTime startInclusive,
      DateTime endInclusive) {
    final start =
        DateTime(startInclusive.year, startInclusive.month, startInclusive.day);
    final end = DateTime(endInclusive.year, endInclusive.month, endInclusive.day);
    return (transactionStream ?? []).where((transaction) {
      final d = transaction.dateTime;
      if (d == null) return false;
      final day = DateTime(d.year, d.month, d.day);
      return !day.isBefore(start) && !day.isAfter(end);
    }).toList();
  }

  // calculate the total transaction amount for the current day
  static double sumTotal(List<Transaction> transactions) {
    return transactions.fold(
        0.0, (double sum, transaction) => sum + transaction.transactionAmount);
  }

  /// All transactions that fall in the same year + month as [month].
  static List<Transaction> filterTransactionListToMonthOf(
      List<Transaction>? transactionStream, DateTime month) {
    return (transactionStream ?? []).where((transaction) {
      final transactionDate = transaction.dateTime;
      return transactionDate != null &&
          transactionDate.year == month.year &&
          transactionDate.month == month.month;
    }).toList();
  }

  /// Transactions in [month] up to and including [cutoffDay]. Used to compare
  /// spend-so-far this month against the same point last month.
  static List<Transaction> filterTransactionListToMonthToDate(
      List<Transaction>? transactionStream, DateTime month, int cutoffDay) {
    return (transactionStream ?? []).where((transaction) {
      final transactionDate = transaction.dateTime;
      return transactionDate != null &&
          transactionDate.year == month.year &&
          transactionDate.month == month.month &&
          transactionDate.day <= cutoffDay;
    }).toList();
  }

  /// Number of days in the month that [month] belongs to.
  static int daysInMonth(DateTime month) {
    return DateTime(month.year, month.month + 1, 0).day;
  }

  /// Running cumulative spend per day for [month], from day 1 to [upToDay]
  /// (inclusive). Index i corresponds to day (i + 1). Days with no spend carry
  /// the previous running total forward.
  static List<double> cumulativeDailyTotals(
      List<Transaction> transactions, DateTime month, int upToDay) {
    if (upToDay <= 0) return const [];
    final daily = List<double>.filled(upToDay, 0.0);
    for (final transaction in transactions) {
      final date = transaction.dateTime;
      if (date == null) continue;
      if (date.year == month.year &&
          date.month == month.month &&
          date.day >= 1 &&
          date.day <= upToDay) {
        daily[date.day - 1] += transaction.transactionAmount;
      }
    }
    final cumulative = <double>[];
    double running = 0.0;
    for (var i = 0; i < upToDay; i++) {
      running += daily[i];
      cumulative.add(running);
    }
    return cumulative;
  }

  /// Percentage change from [previous] to [current]. Returns null when there is
  /// no meaningful baseline (previous is zero).
  static double? percentChange(double current, double previous) {
    if (previous <= 0) return null;
    return ((current - previous) / previous) * 100;
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