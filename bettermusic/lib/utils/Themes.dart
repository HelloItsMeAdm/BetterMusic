import 'package:flutter/material.dart';

import 'CustomColors.dart';

class Themes {
  static ThemeData getDarkTheme() {
    return ThemeData(
      primaryColor: CustomColors.primaryColor,
      backgroundColor: CustomColors.darkGray,
      scaffoldBackgroundColor: CustomColors.darkGray,
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
        // appbar
        headline6: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      colorScheme:
          ColorScheme.fromSwatch().copyWith(secondary: CustomColors.primaryColor),
    );
  }
}
