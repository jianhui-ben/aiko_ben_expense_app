import 'dart:math';

import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:aiko_ben_expense_app/core/theme/app_theme.dart';
import 'package:aiko_ben_expense_app/shared/category_icon_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Backward-compatible aliases for Firestore icon serialization.
final Map<String, IconData> stringToSupportedIconsMap = categoryIconKeyToIconData;
final supportedIconsToStringMap = categoryIconDataToKey;

const transactionAmountInputTextStyle = TextStyle(
  color: AppColors.primary,
  fontSize: 48,
  fontWeight: FontWeight.w600,
  letterSpacing: -0.5,
);

const inputBoxHintTextStyle = TextStyle(
  color: AppColors.textTertiary,
  fontSize: 14,
  fontWeight: FontWeight.w400,
);

//insights page always consider today's date as selectedDate
final DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);


const textInputDecoration = InputDecoration(
  border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
  errorStyle: TextStyle(fontSize: 10), // Adjust the font size
);

const appNameTextStyle = TextStyle(
  color: AppColors.textPrimary,
  fontSize: 28,
  fontWeight: FontWeight.w600,
);

const topDateOnHomeTextStyle = TextStyle(
  color: AppColors.textSecondary,
  fontSize: 14,
  fontWeight: FontWeight.w500,
);

//colors in setting page
const categoryIconColor = AppColors.categoryAccent;
const categoryNameTextColor = AppColors.textPrimary;

ThemeData getCustomTheme() => AppTheme.light;

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