import 'package:flutter/material.dart';
import 'package:ice_live_viewer/model/livearea.dart';
import 'package:ice_live_viewer/utils/http/httpapi.dart';

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
  Map<String, int> indexMap = {
    'bilibili': 0,
    'douyu': 0,
    'huya': 0,
  };

  int get index => indexMap[platform] ?? 0;
  List<String> get labelList => labelMap[platform] ?? [];
  List<AreaInfo> get areaList =>
      areaMap[platform]!.isNotEmpty ? areaMap[platform]![index] : [];

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

  void setIndex(int idx) {
    indexMap[platform] = idx;
    notifyListeners();
  }
}
