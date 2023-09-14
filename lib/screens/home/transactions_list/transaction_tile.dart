

import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionTile extends StatefulWidget {

  final Transaction transaction;

  const TransactionTile({super.key, required this.transaction});


  @override
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile> {
  @override
  Widget build(BuildContext context) {
    return buildTransactonCard();
  }

  Padding buildTransactonCard() {

    final formatCurrency = new NumberFormat.simpleCurrency();


    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Card(
          margin: EdgeInsets.fromLTRB(0, 2, 0, 0),
          elevation: 4.0,
          child: ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text(widget.transaction!.transactionComment ??
                "default category name"),
            trailing: Text(formatCurrency
                .format(widget.transaction!.transactionAmount)),
          )),
    );
  }



}
