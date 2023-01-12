import 'package:flutter/material.dart';
import 'package:hot_live/model/livearea.dart';
import 'package:hot_live/utils/http/httpapi.dart';

class AreasProvider with ChangeNotifier {
  AreasProvider() {
    onLoading();
  }

  final List<String> platforms = [
    'bilibili',
    'douyu',
    'huya',
  ];
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
      areaMap[plat] = await HttpApi.getAreaList(plat);
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
