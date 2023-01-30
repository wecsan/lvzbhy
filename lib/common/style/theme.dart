import 'dart:io';

import 'package:flutter/material.dart';

class MyTheme {
  Color primaryColor;

  MyTheme(this.primaryColor);

  get lightThemeData {
    if (Platform.isWindows) {
      return ThemeData(
        useMaterial3: true,
        colorSchemeSeed: primaryColor,
        brightness: Brightness.light,
        fontFamily: 'PingFang',
      );
    }

    return ThemeData.from(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        brightness: Brightness.light,
      ),
    );
  }

  get darkThemeData {
    if (Platform.isWindows) {
      return ThemeData(
        useMaterial3: true,
        colorSchemeSeed: primaryColor,
        brightness: Brightness.dark,
        errorColor: const Color.fromARGB(255, 255, 99, 71),
        fontFamily: 'PingFang',
      );
    }

    return ThemeData.from(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        error: const Color.fromARGB(255, 255, 99, 71),
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
      ),
    );
  }
}
