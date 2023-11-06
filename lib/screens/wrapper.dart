
import 'package:aiko_ben_expense_app/screens/navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import 'authenticate/authenticate.dart';

class Wrapper extends StatelessWidget {
  const Wrapper ({super.key});

  @override
  Widget build(BuildContext context) {

    //check the userCredential stream
    final userCredential = Provider.of<User?>(context);

    //return either Home or Authenticate widget
    if (userCredential == null) {
      return Authenticate();
    } else {
      return Navigation();
    }
  }
}
