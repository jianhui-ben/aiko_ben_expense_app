
import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  border: OutlineInputBorder(),
  errorStyle: TextStyle(fontSize: 10), // Adjust the font size
);

ThemeData getCustomDarkTheme() {
  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
    // Add other customizations as needed
  );
}