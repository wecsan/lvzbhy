import 'package:hot_live/common/index.dart';

class PlatformAreas {
  String tag = 'bilibili';
  String name = '哔哩';
  List<String> labels = [];
  List<List<AreaInfo>> areas = [];

  PlatformAreas({
    this.tag = '',
    this.name = '',
  });
}

class AreasProvider with ChangeNotifier {
  final BuildContext context;
  late SettingsProvider settings;

  AreasProvider(this.context) {
    platform = Provider.of<SettingsProvider>(
      context,
      listen: false,
    ).preferPlatform;
    onLoading();
  }

  int get platformIndex =>
      platformAreas.keys.toList().indexWhere((e) => e == platform);
  String platform = 'bilibili';
  Map<String, PlatformAreas> platformAreas = {
    'bilibili': PlatformAreas(tag: 'bilibili', name: '哔哩'),
    'douyu': PlatformAreas(tag: 'douyu', name: '斗鱼'),
    'huya': PlatformAreas(tag: 'huya', name: '虎牙'),
  };

  List<String> get labels => platformAreas[platform]?.labels ?? [];
  List<List<AreaInfo>> get areas => platformAreas[platform]?.areas ?? [];

  void onLoading() async {
    for (final plat in platformAreas.keys) {
      platformAreas[plat]?.areas = await LiveApi.getAreaList(plat);
      platformAreas[plat]?.labels.addAll(
          platformAreas[plat]?.areas.map<String>((e) => e.first.typeName) ??
              []);
    }
    notifyListeners();
  }

  void changePlatform(String name) {
    platform = name;
    notifyListeners();
  }
}
