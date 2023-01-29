import 'package:hot_live/common/index.dart';
import 'package:hot_live/pages/index.dart';

class HomeMobileView extends StatelessWidget {
  const HomeMobileView({Key? key}) : super(key: key);
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
}
