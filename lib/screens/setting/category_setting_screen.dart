import 'package:flutter/material.dart';

class CategorySettingScreen extends StatefulWidget {
  const CategorySettingScreen({super.key});

  @override
  State<CategorySettingScreen> createState() => _CategorySettingScreenState();
}

class _CategorySettingScreenState extends State<CategorySettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Category Settings'),
        automaticallyImplyLeading: true, // Add a back button
      ),
    );
  }
}
