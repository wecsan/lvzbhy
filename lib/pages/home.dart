import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ice_live_viewer/pages/areas/areas.dart';
import 'package:ice_live_viewer/pages/favorite/favorite.dart';
import 'package:ice_live_viewer/pages/popular/popular.dart';
import 'package:ice_live_viewer/widgets/custom_icons.dart';

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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.favorite_rounded),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(CustomIcons.popular),
            label: 'Popular',
          ),
          NavigationDestination(
            icon: Icon(Icons.area_chart_rounded),
            label: 'Areas',
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
