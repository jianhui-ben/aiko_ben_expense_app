
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const textInputDecoration = InputDecoration(
  border: OutlineInputBorder(borderSide: BorderSide(width: 100)),
  errorStyle: TextStyle(fontSize: 10), // Adjust the font size
);

const appNameTextStyle = TextStyle(
  color: Color(0xFF23036A),
  fontSize: 30,
  fontFamily: 'RockSalt',
  fontWeight: FontWeight.w400,
  height: 0.80,
  letterSpacing: 0.18,
);


ThemeData getCustomTheme() {
  return ThemeData(
      useMaterial3: true,
      // Define the default brightness and colors.
      // brightness: Brightness.dark,
      // scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      // Define the default `TextTheme`. Use this to specify the default
      // text styling for headlines, titles, bodies of text, and more.
      textTheme: TextTheme(
        labelLarge: TextStyle( // Customize the text style for buttons
          fontSize: 12, // Text size
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: BorderSide(width: 1, color: Color(0xFF23036A)),
          borderRadius: BorderRadius.circular(10),
        ),
        errorStyle: TextStyle(
          fontSize: 12.0, // Customize error text font size
          color: Colors.red, // Customize error text color
        ),
        // You can customize other InputDecoration properties here
      ),

      // buttonTheme: ButtonThemeData(
      //   buttonColor: Colors.white,
      //   textTheme: ButtonTextTheme.primary, //  <-- this auto selects the right color
      // )
  );
}