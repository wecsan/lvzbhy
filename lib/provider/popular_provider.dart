import 'package:flutter/material.dart';
import 'package:ice_live_viewer/model/liveroom.dart';
import 'package:ice_live_viewer/utils/http/httpapi.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PopularProvider with ChangeNotifier {
  PopularProvider() {
    initRefresh();
  }

  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

  final List<String> platforms = [
    'bilibili',
    'douyu',
    'huya',
  ];
  String platform = 'bilibili';
  Map<String, List<RoomInfo>> roomsMap = {
    'bilibili': [],
    'douyu': [],
    'huya': [],
  };
  Map<String, int> pageMap = {
    'bilibili': 0,
    'douyu': 0,
    'huya': 0,
  };

  int get page => pageMap[platform] ?? 0;
  set page(int _page) => pageMap[platform] = _page;

  List<RoomInfo> get roomList => roomsMap[platform] ?? [];
  set roomList(List<RoomInfo> _rooms) => roomsMap[platform] = _rooms;

  void initRefresh() async {
    for (var plat in platforms) {
      roomsMap[plat] = await HttpApi.getRecommend(plat, page: 0);
    }
    notifyListeners();
  }

  void onRefresh() async {
    page = 0;
    roomList = await HttpApi.getRecommend(platform, page: page);
    if (roomList.isEmpty) {
      refreshController.refreshFailed();
    } else {
      refreshController.refreshCompleted();
    }
    notifyListeners();
  }

  void onLoading() async {
    page++;
    final items = await HttpApi.getRecommend(platform, page: page);
    if (items.isEmpty) {
      refreshController.loadFailed();
    } else {
      for (var item in items) {
        if (roomList.indexWhere((e) => e.roomId == item.roomId) != -1) continue;
        roomList.add(item);
      }
      refreshController.loadComplete();
    }
    notifyListeners();
  }

  void setPlatform(String name) {
    platform = name;
    notifyListeners();
  }
}
