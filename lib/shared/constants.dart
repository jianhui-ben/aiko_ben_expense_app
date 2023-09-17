
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const textInputDecoration = InputDecoration(
  border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
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
          borderSide: BorderSide(width: 5, color: Color(0xFF23036A)),
          borderRadius: BorderRadius.circular(10),
        ),
        errorStyle: TextStyle(
          fontSize: 12.0, // Customize error text font size
          color: Colors.red, // Customize error text color
        ),
        labelStyle: TextStyle(fontWeight: FontWeight.bold, // Make the font bold
            color: Color(0xFF6200EE)), // Adjust the font size
        // You can customize other InputDecoration properties here
      ),

      buttonTheme: ButtonThemeData(
        buttonColor: Colors.white,
        textTheme: ButtonTextTheme.primary, //  <-- this auto selects the right color
      )
  );
}

class DateTextFormatter extends TextInputFormatter {
  static const _maxChars = 8;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String separator = '/';
    var text = _format(
      newValue.text,
      oldValue.text,
      separator,
    );

    return newValue.copyWith(
      text: text,
      selection: updateCursorPosition(
        oldValue,
        text,
      ),
    );
  }

  String _format(
      String value,
      String oldValue,
      String separator,
      ) {
    var isErasing = value.length < oldValue.length;
    var isComplete = value.length > _maxChars + 2;

    if (!isErasing && isComplete) {
      return oldValue;
    }

    value = value.replaceAll(separator, '');
    final result = <String>[];

    for (int i = 0; i < min(value.length, _maxChars); i++) {
      result.add(value[i]);
      if ((i == 1 || i == 3) && i != value.length - 1) {
        result.add(separator);
      }
    }

    return result.join();
  }

  TextSelection updateCursorPosition(
      TextEditingValue oldValue,
      String text,
      ) {
    var endOffset = max(
      oldValue.text.length - oldValue.selection.end,
      0,
    );

    var selectionEnd = text.length - endOffset;

    return TextSelection.fromPosition(TextPosition(offset: selectionEnd));
  }
}