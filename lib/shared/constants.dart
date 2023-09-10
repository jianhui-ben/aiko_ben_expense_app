
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const textInputDecoration = InputDecoration(
  border: OutlineInputBorder(borderSide: BorderSide(width: 100)),
  errorStyle: TextStyle(fontSize: 10), // Adjust the font size
);

ThemeData getCustomDarkTheme() {
  return ThemeData(
      useMaterial3: true,
      // Define the default brightness and colors.
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      // Define the default `TextTheme`. Use this to specify the default
      // text styling for headlines, titles, bodies of text, and more.
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        // ···
        titleLarge: GoogleFonts.oswald(
          fontSize: 30,
          fontStyle: FontStyle.italic,
        ),
        bodyMedium: GoogleFonts.merriweather(),
        displaySmall: GoogleFonts.pacifico(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: BorderSide(width: 5.0),
        ),
        errorStyle: TextStyle(
          fontSize: 16.0, // Customize error text font size
          color: Colors.red, // Customize error text color
        ),
        // You can customize other InputDecoration properties here
      ),

      buttonTheme: ButtonThemeData(
        buttonColor: Colors.white, //  <-- dark color
        textTheme: ButtonTextTheme.primary, //  <-- this auto selects the right color
      ));
}