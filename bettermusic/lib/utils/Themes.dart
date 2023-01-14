import 'package:flutter/material.dart';

import 'CustomColors.dart';

class Themes {
  static ThemeData getDarkTheme({required bool offlineMode}) {
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
      ),
      colorScheme:
          ColorScheme.fromSwatch().copyWith(secondary: CustomColors.primaryColor),
    );
  }
}
