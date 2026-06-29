import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Streams the household's monthly budget and hands it to [builder]. Centralizes
/// the budget lookup so every overview module reads it the same way (and shares
/// the same default when none is set).
class HouseholdBudgetBuilder extends StatelessWidget {
  static const double defaultMonthlyBudget = 2000.0;

  final Widget Function(BuildContext context, double monthlyBudget) builder;

  const HouseholdBudgetBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final householdId = Provider.of<User?>(context)?.householdId;

    if (householdId == null) {
      return builder(context, defaultMonthlyBudget);
    }

    final householdDoc =
        FirebaseFirestore.instance.collection('households').doc(householdId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: householdDoc.snapshots(),
      builder: (context, snapshot) {
        final budget =
            (snapshot.data?.data()?['monthlyBudget'] as num?)?.toDouble() ??
                defaultMonthlyBudget;
        return builder(context, budget);
      },
    );
  }
}
