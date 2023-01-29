import 'package:hot_live/common/index.dart';

class AreasProvider with ChangeNotifier {
  final BuildContext context;
  late SettingsProvider settings;

  AreasProvider(this.context) {
    settings = Provider.of<SettingsProvider>(context, listen: false);
    platform = settings.preferPlatform;
    onLoading();
  }

  final List<String> platforms = SettingsProvider.platforms;
  String platform = 'bilibili';
  Map<String, List<List<AreaInfo>>> areaMap = {
    'bilibili': [],
    'douyu': [],
    'huya': [],
  };
  Map<String, List<String>> labelMap = {
    'bilibili': [],
    'douyu': [],
    'huya': [],
  };

  List<String> get labelList => labelMap[platform] ?? [];
  List<List<AreaInfo>> get areaList => areaMap[platform] ?? [];

  void onLoading() async {
    for (var plat in platforms) {
      areaMap[plat] = await LiveApi.getAreaList(plat);
      for (var list in areaMap[plat]!) {
        labelMap[plat]!.add(list[0].typeName);
      }
    }
    notifyListeners();
  }

  void setPlatform(String name) {
    platform = name;
    notifyListeners();
  }
}
