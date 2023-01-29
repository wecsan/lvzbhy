import 'package:flutter/material.dart';

class MyTheme {
  Color primaryColor;

  MyTheme(this.primaryColor);

  get lightThemeData => ThemeData.from(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          brightness: Brightness.light,
        ),
      );

  get darkThemeData => ThemeData.from(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          error: const Color.fromARGB(255, 255, 99, 71),
          seedColor: primaryColor,
          brightness: Brightness.dark,
          primary: primaryColor,
        ),
      );
}
