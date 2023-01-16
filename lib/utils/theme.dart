import 'package:flutter/material.dart';

class MyTheme {
  Color primaryColor;

  MyTheme(this.primaryColor);

  get lightThemeData => ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      );

  get darkThemeData => ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          error: const Color.fromARGB(255, 255, 99, 71),
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      );
}
