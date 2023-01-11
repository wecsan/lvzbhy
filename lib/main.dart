import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ice_live_viewer/pages/home.dart';
import 'package:ice_live_viewer/provider/areas_provider.dart';
import 'package:ice_live_viewer/provider/favorite_provider.dart';
import 'package:ice_live_viewer/provider/popular_provider.dart';
import 'package:ice_live_viewer/utils/prefs_helper.dart';
import 'package:ice_live_viewer/utils/theme.dart';
import 'package:ice_live_viewer/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PrefsHelper.prefs = await SharedPreferences.getInstance();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (_) => AppThemeProvider(),
      lazy: false,
    ),
    ChangeNotifierProvider(
      create: (_) => FavoriteProvider(),
      lazy: false,
    ),
    ChangeNotifierProvider(
      create: (_) => PopularProvider(),
      lazy: false,
    ),
    ChangeNotifierProvider(
      create: (_) => AreasProvider(),
      lazy: false,
    ),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HotLive',
      themeMode: Provider.of<AppThemeProvider>(context).themeMode,
      theme: MyTheme(Provider.of<AppThemeProvider>(context).themeColor)
          .lightThemeData,
      darkTheme: MyTheme(Provider.of<AppThemeProvider>(context).themeColor)
          .darkThemeData,
      home: const HomePage(),
    );
  }
}
