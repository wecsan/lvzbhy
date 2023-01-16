import 'package:flutter/material.dart';
import 'package:hot_live/pages/home.dart';
import 'package:hot_live/provider/areas_provider.dart';
import 'package:hot_live/provider/favorite_provider.dart';
import 'package:hot_live/provider/popular_provider.dart';
import 'package:hot_live/provider/settings_provider.dart';
import 'package:hot_live/utils/pref_util.dart';
import 'package:hot_live/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PrefUtil.prefs = await SharedPreferences.getInstance();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
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
    final settings = Provider.of<SettingsProvider>(context);
    return MaterialApp(
      title: 'HotLive',
      themeMode: settings.themeMode,
      theme: MyTheme(settings.themeColor).lightThemeData,
      darkTheme: MyTheme(settings.themeColor).darkThemeData,
      home: const HomePage(),
    );
  }
}
