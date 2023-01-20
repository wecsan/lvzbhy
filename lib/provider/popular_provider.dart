import 'package:flutter/material.dart';
import 'package:hot_live/model/liveroom.dart';
import 'package:hot_live/api/liveapi.dart';
import 'package:hot_live/provider/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PopularProvider with ChangeNotifier {
  final BuildContext context;
  late SettingsProvider settings;

  PopularProvider(this.context) {
    settings = Provider.of<SettingsProvider>(context);
    platform = settings.preferPlatform;
    initRefresh();
  }

  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

  final List<String> platforms = SettingsProvider.platforms;
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
      roomsMap[plat] = await LiveApi.getRecommend(plat, page: 0);
    }
    notifyListeners();
  }

  void onRefresh() async {
    page = 0;
    roomList = await LiveApi.getRecommend(platform, page: page);
    if (roomList.isEmpty) {
      refreshController.refreshFailed();
    } else {
      refreshController.refreshCompleted();
    }
    notifyListeners();
  }

  void onLoading() async {
    page++;
    final items = await LiveApi.getRecommend(platform, page: page);
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
