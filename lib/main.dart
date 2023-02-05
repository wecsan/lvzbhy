import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pure_live/common/index.dart';
import 'package:pure_live/pages/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  JsEngine.init();
  PrefUtil.prefs = await SharedPreferences.getInstance();
  if (Platform.isWindows) {
    await DartVLC.initialize();
    await windowManager.ensureInitialized();
  }

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      lazy: false,
    ),
    ChangeNotifierProvider(
      create: (context) => FavoriteProvider(context),
      lazy: false,
    ),
    ChangeNotifierProvider(
      create: (context) => PopularProvider(context),
      lazy: false,
    ),
    ChangeNotifierProvider(
      create: (context) => AreasProvider(context),
      lazy: false,
    ),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        // 主题颜色设定/Monet取色
        final settings = Provider.of<SettingsProvider>(context);
        var lightTheme =
            MyTheme(primaryColor: settings.themeColor).lightThemeData;
        var darkTheme =
            MyTheme(primaryColor: settings.themeColor).darkThemeData;
        if (settings.enableDynamicTheme) {
          lightTheme = MyTheme(colorScheme: lightDynamic).lightThemeData;
          darkTheme = MyTheme(colorScheme: darkDynamic).darkThemeData;
        }

        return MaterialApp(
          title: 'PureLive',
          themeMode: settings.themeMode,
          theme: lightTheme,
          darkTheme: darkTheme,
          locale: settings.language,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: const HomePage(),
        );
      },
    );
  }
}
