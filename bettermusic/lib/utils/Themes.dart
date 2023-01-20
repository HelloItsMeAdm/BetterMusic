import 'package:flutter/material.dart';

import 'CustomColors.dart';

class Themes {
  static ThemeData getDarkTheme() {
    return ThemeData(
      primaryColor: CustomColors.primaryColor,
      backgroundColor: CustomColors.darkGray,
      scaffoldBackgroundColor: CustomColors.darkGray,
      fontFamily: "Poppins",
      // Light 300
      // Medium 500
      // SemiBold 600
      textTheme: const TextTheme(
        subtitle1: TextStyle(
          color: CustomColors.primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        caption: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
      colorScheme:
          ColorScheme.fromSwatch().copyWith(secondary: CustomColors.primaryColor),
    );
  }
}
