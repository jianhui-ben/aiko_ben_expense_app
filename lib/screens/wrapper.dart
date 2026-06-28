
import 'package:aiko_ben_expense_app/screens/household/household_setup_screen.dart';
import 'package:aiko_ben_expense_app/screens/navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import 'authenticate/authenticate.dart';

class Wrapper extends StatelessWidget {
  const Wrapper ({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user == null) {
      return Authenticate();
    }
    if (user.householdId == null) {
      return const HouseholdSetupScreen();
    }
    return Navigation(householdId: user.householdId!);
  }
}
