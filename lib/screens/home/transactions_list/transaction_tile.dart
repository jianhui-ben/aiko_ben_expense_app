import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/screens/single_transaction/add_or_edit_single_transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionTile extends StatelessWidget {

  final DateTime selectedDate;
  final Category transactionCategory;
  final String transactionComment;
  final double transactionAmount;
  final String transactionId;

  const TransactionTile(
      {super.key, required this.selectedDate, required this.transactionCategory, required this.transactionComment, required this.transactionAmount, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: AddOrEditSingleTransaction(
                    category: transactionCategory,
                    transactionComment: transactionComment,
                    transactionAmount: transactionAmount,
                    selectedDate: selectedDate,
                    transactionId: transactionId,
                  ),
                ),
              );
            },
          );
        },
      );},
      child: buildTransactonCard(),
    );
  }

  Padding buildTransactonCard() {

    final formatCurrency = new NumberFormat.simpleCurrency();

    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Card(
          color: Colors.white,
          margin: EdgeInsets.fromLTRB(0, 2, 0, 0),
          // elevation: 4.0,
          child: ListTile(
            leading: IconTheme(
              data: IconThemeData(color: Color(0xFFB69DF8)),
              child: transactionCategory.categoryIcon,
            ),
            title: Text(transactionComment),
            trailing: Text(formatCurrency
                .format(transactionAmount)),
          )),
    );
  }
}

