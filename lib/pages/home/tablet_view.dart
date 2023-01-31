import 'package:hot_live/common/index.dart';
import 'package:hot_live/pages/index.dart';

class HomeTabletView extends StatelessWidget {
  const HomeTabletView({Key? key}) : super(key: key);
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

  Widget get body => [
        const FavoritePage(),
        const PopularPage(),
        const AreasPage(),
        const SettingsPage(),
        const SearchPage(),
      ][_selectedIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              groupAlignment: 0.95,
              labelType: NavigationRailLabelType.all,
              leading: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: 'search',
                    elevation: 0,
                    onPressed: () {
                      setState(() => _selectedIndex = 4);
                    },
                    child: const Icon(CustomIcons.search),
                  ),
                ],
              ),
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
                NavigationRailDestination(
                  icon: const Icon(Icons.settings_rounded),
                  label: Text(S.of(context).settings_title),
                ),
              ],
              selectedIndex: _selectedIndex > 3 ? 0 : _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() => _selectedIndex = index);
              },
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
