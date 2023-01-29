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
        const AreasPage()
      ][_selectedIndex];

  @override
  Widget build(BuildContext context) {
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
