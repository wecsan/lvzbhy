import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_meedu_videoplayer/init_meedu_player.dart';
import 'package:hot_live/common/index.dart';
import 'package:hot_live/pages/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PrefUtil.prefs = await SharedPreferences.getInstance();
  initMeeduPlayer();

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
    final settings = Provider.of<SettingsProvider>(context);
    return MaterialApp(
      title: 'HotLive',
      themeMode: settings.themeMode,
      theme: MyTheme(settings.themeColor).lightThemeData,
      darkTheme: MyTheme(settings.themeColor).darkThemeData,
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
  }
}
