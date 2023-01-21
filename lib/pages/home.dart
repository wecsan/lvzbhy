import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hot_live/generated/l10n.dart';

import 'package:hot_live/pages/areas/areas.dart';
import 'package:hot_live/pages/favorite/favorite.dart';
import 'package:hot_live/pages/popular/popular.dart';
import 'package:hot_live/pages/settings/check_update.dart';
import 'package:hot_live/provider/settings_provider.dart';
import 'package:hot_live/utils/version_util.dart';
import 'package:hot_live/widgets/custom_icons.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);
  //homepage
  @override
  Widget build(BuildContext context) {
    return const HomePageRouter();
  }
}

class HomePageRouter extends StatefulWidget {
  const HomePageRouter({Key? key}) : super(key: key);

  @override
  State<HomePageRouter> createState() => _HomePageRouterState();
}

class _HomePageRouterState extends State<HomePageRouter> {
  int _selectedIndex = 0;
  late SettingsProvider settings =
      Provider.of<SettingsProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
    // check update overlay ui
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        await VersionUtil.checkUpdate();
        if (settings.enableAutoCheckUpdate && VersionUtil.hasNewVersion()) {
          late OverlayEntry entry;
          entry = OverlayEntry(
            builder: (context) => Container(
              alignment: Alignment.center,
              color: Colors.black54,
              child: NewVersionDialog(entry: entry),
            ),
          );
          Overlay.of(context)?.insert(entry);
        }

        // 新年祝福页
        DateTime now = DateTime.now();
        if (now.year == 2023 && now.month == 1 && now.day == 22) {
          final newyearEntry = OverlayEntry(
            builder: (context) => Container(
              alignment: Alignment.center,
              color: Colors.black54,
              child: const AlertDialog(
                title: Text("兔年快乐🎉🎉"),
                content: Text('祝大家新年快乐，兔年吉祥安康~'),
              ),
            ),
          );
          Overlay.of(context)?.insert(newyearEntry);
          Timer(const Duration(seconds: 3), () {
            newyearEntry.remove();
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Android statusbar and navigationbar
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor:
            Theme.of(context).navigationBarTheme.backgroundColor,
      ));
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.favorite_rounded),
            label: S.of(context).favorites_title,
          ),
          NavigationDestination(
            icon: const Icon(CustomIcons.popular),
            label: S.of(context).popular_title,
          ),
          NavigationDestination(
            icon: const Icon(Icons.area_chart_rounded),
            label: S.of(context).areas_title,
          ),
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: [
        // Favorites
        const FavoritePage(),
        // Popular
        const PopularPage(),
        // Areas
        const AreasPage(),
      ][_selectedIndex],
    );
  }
}
