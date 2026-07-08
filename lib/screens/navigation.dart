import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/screens/home/home.dart';
import 'package:aiko_ben_expense_app/screens/insights/insights.dart';
import 'package:aiko_ben_expense_app/screens/setting/settings.dart';
import 'package:aiko_ben_expense_app/services/database.dart';
import 'package:aiko_ben_expense_app/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction, Settings;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Navigation extends StatefulWidget {
  final String householdId;

  const Navigation({super.key, required this.householdId});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int currentPageIndex = 0;
  NavigationDestinationLabelBehavior labelBehavior =
      NavigationDestinationLabelBehavior.alwaysShow;

  final List<Widget> _pages = [
    Home(),
    Insights(),
    Settings(),
  ];

  late final DatabaseService _db;
  bool _migrationChecked = false;

  @override
  void initState() {
    super.initState();
    _db = DatabaseService(householdId: widget.householdId);
    _ensurePinnedMigration();
  }

  Future<void> _ensurePinnedMigration() async {
    await getHouseholdPinnedCategoryIds(widget.householdId);
    if (mounted) setState(() => _migrationChecked = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_migrationChecked) {
      return const Loading();
    }

    final householdDoc = FirebaseFirestore.instance
        .collection('households')
        .doc(widget.householdId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: householdDoc.snapshots(),
      builder: (context, householdSnapshot) {
        if (!householdSnapshot.hasData || !householdSnapshot.data!.exists) {
          return const Loading();
        }

        final householdData = householdSnapshot.data!.data();
        final categories =
            parseCategoriesFromHouseholdData(householdData);
        _db.setUserCategoriesMap(categories);

        return StreamProvider<List<Transaction>?>.value(
          value: _db.transactions,
          initialData: null,
          child: Scaffold(
            body: _pages[currentPageIndex],
            bottomNavigationBar: NavigationBar(
              labelBehavior: labelBehavior,
              selectedIndex: currentPageIndex,
              onDestinationSelected: (int index) {
                setState(() => currentPageIndex = index);
              },
              destinations: const <Widget>[
                NavigationDestination(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights),
                  label: 'Insights',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
