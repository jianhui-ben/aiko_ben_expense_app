
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';


// for easy Icondata storing in firebase
final Map<String, IconData> stringToSupportedIconsMap = {
  'shopping_cart': Icons.shopping_cart,
  'house': Icons.house,
  'travel': Icons.flight,
  'restaurant': Icons.local_dining,
  'laundry': Icons.checkroom,
  'medical': Icons.medical_information,
  'utility': Icons.electrical_services,
  'commute': Icons.commute,
  'education': Icons.school,
  'investments': Icons.trending_up,
  'entertainment': Icons.gamepad,
  'clothing': Icons.shopping_bag,
  'home_repairs': Icons.build,
  'subscription': Icons.subscriptions,
  'fitness': Icons.fitness_center,
  'tech_gadgets': Icons.devices,
  'pet_expenses': Icons.pets,
  'home_decor': Icons.home,
  'grocery_organic': Icons.eco,
  'car_maintenance': Icons.local_car_wash,
  'books_learning': Icons.menu_book,
  'coffee_shops': Icons.local_cafe,
  'outdoor_activities': Icons.directions_bike,
  'diy_projects': Icons.build_circle,
  'gifts_celebrations': Icons.card_giftcard,
  'restaurant_fast_food': Icons.fastfood,
  'restaurant_fine_dining': Icons.local_dining,
  'restaurant_coffee_shops': Icons.local_cafe,
  'grocery_fresh_produce': Icons.local_grocery_store,
  'grocery_snacks': Icons.fastfood,
  'medical_prescription': Icons.medical_services,
  'fitness_gym_membership': Icons.fitness_center,
  'home_repairs_plumbing': Icons.plumbing,
  'entertainment_concerts': Icons.music_note,
  'car_maintenance_oil_change': Icons.local_car_wash,
  'tech_gadgets_accessories': Icons.devices_other,
  'pet_expenses_veterinary_care': Icons.local_hospital,
  'home_decor_furniture': Icons.weekend,
  'grocery_beverages': Icons.local_drink,
  'car_maintenance_tire_replacement': Icons.electric_rickshaw,
  'books_learning_online_courses': Icons.book_online,
  'coffee_shops_desserts': Icons.icecream,
  'outdoor_activities_camping_gear': Icons.local_fire_department_sharp,
  'diy_projects_tools': Icons.build,
  'gifts_celebrations_decorations': Icons.cake,
  'travel_hotel_stays': Icons.hotel,
  'clothing_shoes': Icons.shopping_bag,
  'home_repairs_electrical_work': Icons.electrical_services,
  'entertainment_streaming_services': Icons.tv,
  'fitness_yoga_classes': Icons.self_improvement,
};

Map<IconData, String> reverseIconsToStringMap(Map<String, IconData> inputMap) {
  final reversedMap = <IconData, String>{};
  inputMap.forEach((key, value) {
    reversedMap[value] = key;
  });
  return reversedMap;
}

final supportedIconsToStringMap = reverseIconsToStringMap(stringToSupportedIconsMap);

const transactionAmountInputTextStyle = TextStyle(
  color: Color(0xFF6750A4),
  fontSize: 57,
  fontFamily: 'Montserrat',
  fontWeight: FontWeight.w400,
  letterSpacing: -0.25,
);

const inputBoxHintTextStyle = TextStyle(
  color: Color(0xFFCAC4D0),
  fontSize: 14,
  fontFamily: 'Montserrat',
  fontWeight: FontWeight.w400,
  height: 0.10,
  letterSpacing: 0.25,
);


//insights page always consider today's date as selectedDate
final DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);


const textInputDecoration = InputDecoration(
  border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
  errorStyle: TextStyle(fontSize: 10), // Adjust the font size
);

const appNameTextStyle = TextStyle(
  color: Color(0xFF23036A),
  fontSize: 28,
  fontFamily: 'RockSalt',
  fontWeight: FontWeight.w400,
  height: 0.80,
  letterSpacing: 0.18,
);

const topDateOnHomeTextStyle = TextStyle(
color: Color(0xFF3A4857),
fontSize: 24,
fontFamily: 'Montserrat',
fontWeight: FontWeight.w400,
height: 0.06,
);


//colors in setting page
const categoryIconColor = Color(0xFF42474E);
const categoryNameTextColor = Color(0xFF42474E);

ThemeData getCustomTheme() {
  return ThemeData(
      useMaterial3: true,
      // Define the default background color
      scaffoldBackgroundColor: Color(0xFFF3EDF7),
      buttonTheme: ButtonThemeData(
        buttonColor: Color(0xFFB69DF8),
        // textTheme: ButtonTextTheme.primary,
      ),
    // Define the default IconTheme. Use this to specify the default
    // color and size for icons in your application.
    iconTheme: IconThemeData(
      color: Color(0xFFB69DF8), // Sets the color for icons
    ),

      // Define the default brightness and colors.
      // brightness: Brightness.dark,
      // scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      // Define the default `TextTheme`. Use this to specify the default
      // text styling for headlines, titles, bodies of text, and more.
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF6200EE)),
        bodyMedium: TextStyle(color: Color(0xFF42474E)),
        bodySmall: TextStyle(color: Color(0xFF9CA0A7)),
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