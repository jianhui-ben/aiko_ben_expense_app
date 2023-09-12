
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionsList extends StatefulWidget {
  const TransactionsList({super.key});

  @override
  State<TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {

  @override
  Widget build(BuildContext context) {

    // check the transaction stream
    final transactionStream = Provider.of<List<Transaction>?>(context);

    if (transactionStream == null) {
      return Expanded(child:const Loading());
    }
    return Expanded(child: const Placeholder());
  }
}
