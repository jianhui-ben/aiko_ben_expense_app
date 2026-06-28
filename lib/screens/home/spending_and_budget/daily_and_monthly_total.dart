import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/shared/widgets/summary_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Unified spending summary card: daily + monthly totals and budget remaining.
/// Tapping the card lets either household member edit the shared monthly budget.
class SpendingSummary extends StatelessWidget {
  final DateTime selectedDate;

  const SpendingSummary({super.key, required this.selectedDate});

  double _monthlyTotal(List<Transaction> transactions) {
    return transactions
        .where((t) =>
            t.dateTime != null &&
            t.dateTime!.year == selectedDate.year &&
            t.dateTime!.month == selectedDate.month)
        .fold(0.0, (acc, t) => acc + t.transactionAmount);
  }

  double _dailyTotal(List<Transaction> transactions) {
    return transactions
        .where((t) =>
            t.dateTime != null &&
            t.dateTime!.year == selectedDate.year &&
            t.dateTime!.month == selectedDate.month &&
            t.dateTime!.day == selectedDate.day)
        .fold(0.0, (acc, t) => acc + t.transactionAmount);
  }

  @override
  Widget build(BuildContext context) {
    final transactions = Provider.of<List<Transaction>?>(context) ?? [];
    final householdId = Provider.of<User?>(context)?.householdId;

    final dailyTotal = _dailyTotal(transactions);
    final monthlyTotal = _monthlyTotal(transactions);

    final householdDoc =
        FirebaseFirestore.instance.collection('households').doc(householdId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: householdDoc.snapshots(),
      builder: (context, snapshot) {
        final budget =
            (snapshot.data?.data()?['monthlyBudget'] as num?)?.toDouble() ??
                2000.0;

        return GestureDetector(
          onTap: householdId == null
              ? null
              : () => _editBudget(context, householdDoc, budget),
          child: SummaryCard(
            dailyTotal: dailyTotal,
            monthlyTotal: monthlyTotal,
            monthlyBudget: budget,
          ),
        );
      },
    );
  }

  void _editBudget(
    BuildContext context,
    DocumentReference<Map<String, dynamic>> householdDoc,
    double currentBudget,
  ) {
    final controller =
        TextEditingController(text: currentBudget.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Monthly budget'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              prefixText: '\$ ',
              hintText: 'Enter monthly budget',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final value = double.tryParse(controller.text);
                if (value != null) {
                  await householdDoc.set(
                    {'monthlyBudget': value},
                    SetOptions(merge: true),
                  );
                }
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
