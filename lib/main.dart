import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:pure_live/common/index.dart';
import 'package:pure_live/modules/areas/areas_controller.dart';
import 'package:pure_live/modules/favorite/favorite_controller.dart';
import 'package:pure_live/modules/popular/popular_controller.dart';
import 'package:pure_live/routes/app_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  JsEngine.init();
  PrefUtil.prefs = await SharedPreferences.getInstance();
  if (Platform.isWindows) {
    DartVLC.initialize();
    await windowManager.ensureInitialized();
  }
  initService();

  runApp(const MyApp());
}

void initService() {
  Get.put(SettingsService());
  Get.put(FavoriteController());
  Get.put(PopularController());
  Get.put(AreasController());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsService>(
      id: 'myapp',
      builder: (settings) {
        return DynamicColorBuilder(
          builder: (lightDynamic, darkDynamic) {
            // 主题颜色设定/Monet取色
            var lightTheme =
                MyTheme(primaryColor: settings.themeColor).lightThemeData;
            var darkTheme =
                MyTheme(primaryColor: settings.themeColor).darkThemeData;
            if (settings.enableDynamicTheme.value) {
              lightTheme = MyTheme(colorScheme: lightDynamic).lightThemeData;
              darkTheme = MyTheme(colorScheme: darkDynamic).darkThemeData;
            }

            return GetMaterialApp(
              title: 'PureLive',
              themeMode: Get.find<SettingsService>().themeMode,
              theme: lightTheme,
              darkTheme: darkTheme,
              locale: Get.find<SettingsService>().language,
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              initialRoute: AppPages.initial,
              getPages: AppPages.routes,
            );
          },
        );
      },
    );
  }
}
