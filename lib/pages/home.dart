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
import 'package:responsive_builder/responsive_builder.dart';

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
      },
    );
  }

  Widget get body => [
        const FavoritePage(),
        const PopularPage(),
        const AreasPage()
      ][_selectedIndex];

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

    return ScreenTypeLayout.builder(
      mobile: (context) => OrientationLayoutBuilder(
        portrait: (context) => _buildMobileView(),
        landscape: (context) => _buildTabletView(),
      ),
      tablet: (context) => _buildTabletView(),
    );
  }

  Scaffold _buildMobileView() {
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
      body: body,
    );
  }

  Scaffold _buildTabletView() {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              groupAlignment: -0.9,
              labelType: NavigationRailLabelType.all,
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.favorite_rounded),
                  label: Text(S.of(context).favorites_title),
                ),
                NavigationRailDestination(
                  icon: const Icon(CustomIcons.popular),
                  label: Text(S.of(context).popular_title),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.area_chart_rounded),
                  label: Text(S.of(context).areas_title),
                ),
              ],
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
