
import 'package:aiko_ben_expense_app/models/category.dart';

class Transaction{

  final DateTime? dateTime;
  final Category category;
  final double transactionAmount;
  final String? transactionComment;

  Transaction({required this.category, required this.transactionAmount, this.transactionComment, this.dateTime});

}