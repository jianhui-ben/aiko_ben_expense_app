import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionTile extends StatelessWidget {

  final Icon transactionIcon;
  final String transactionComment;
  final double transactionAmount;

  const TransactionTile({super.key, required this.transactionIcon, required this.transactionComment, required this.transactionAmount});

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
            leading: transactionIcon,
            title: Text(transactionComment),
            trailing: Text(formatCurrency
                .format(transactionAmount)),
          )),
    );
  }
}

