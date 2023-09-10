
import 'dart:ffi';

import 'package:aiko_ben_expense_app/models/category.dart';

class Transaction{

  late DateTime dateTime;
  final Category category;
  final double transactionAmount;
  final String? transactionComment;

  Transaction(this.category, this.transactionAmount, this.transactionComment);


}