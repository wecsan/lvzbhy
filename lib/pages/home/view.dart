import 'package:hot_live/common/index.dart';
import 'package:hot_live/pages/home/mobile_view.dart';
import 'package:hot_live/pages/home/tablet_view.dart';
import 'package:hot_live/pages/settings/widgets/check_update.dart';
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
  late final settings = Provider.of<SettingsProvider>(context, listen: false);

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

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => OrientationLayoutBuilder(
        portrait: (context) => const HomeMobileView(),
        landscape: (context) => const HomeTabletView(),
      ),
      tablet: (context) => OrientationLayoutBuilder(
        portrait: (context) => const HomeMobileView(),
        landscape: (context) => const HomeTabletView(),
      ),
      desktop: (context) => const HomeTabletView(),
    );
  }
}
