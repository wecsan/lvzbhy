import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pure_live/common/index.dart';
import 'package:pure_live/modules/areas/areas_page.dart';
import 'package:pure_live/modules/favorite/favorite_page.dart';
import 'package:pure_live/modules/home/mobile_view.dart';
import 'package:pure_live/modules/home/tablet_view.dart';
import 'package:pure_live/modules/about/widgets/version_dialog.dart';
import 'package:pure_live/modules/popular/popular_page.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../search/search_page.dart';

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

class _HomePageRouterState extends State<HomePageRouter>
    with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;
  final bodys = const [
    FavoritePage(),
    PopularPage(),
    AreasPage(),
    SearchPage(),
  ];

  @override
  void initState() {
    super.initState();
    // check update overlay ui
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        // Android statusbar and navigationbar
        if (Platform.isAndroid) {
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor:
                Theme.of(context).navigationBarTheme.backgroundColor,
          ));
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        }

        await VersionUtil.checkUpdate();
        if (Get.find<SettingsService>().enableAutoCheckUpdate.value &&
            VersionUtil.hasNewVersion()) {
          late OverlayEntry entry;
          entry = OverlayEntry(
            builder: (context) => Container(
              alignment: Alignment.center,
              color: Colors.black54,
              child: NewVersionDialog(entry: entry),
            ),
          );
          Overlay.of(Get.context!).insert(entry);
        }
      },
    );
  }

  void onDestinationSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget get homeMobile => HomeMobileView(
        body: bodys[_selectedIndex],
        index: _selectedIndex,
        onDestinationSelected: onDestinationSelected,
      );

  Widget get homeTablet => HomeTabletView(
        body: bodys[_selectedIndex],
        index: _selectedIndex,
        onDestinationSelected: onDestinationSelected,
      );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ScreenTypeLayout.builder(
      mobile: (context) => homeMobile,
      tablet: (context) => homeTablet,
      desktop: (context) => homeTablet,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
