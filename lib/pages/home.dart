import 'package:flutter/material.dart';

import 'package:ice_live_viewer/pages/areas_page/areas_page.dart';
import 'package:ice_live_viewer/pages/favorite_page/favorite_page.dart';
import 'package:ice_live_viewer/pages/recommend_page/recommend_page.dart';

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
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.star_rate_rounded),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_rounded),
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
        const RecommendPage(),
        // Areas
        const AreasPage(),
      ][_selectedIndex],
    );
  }
}
