import 'dart:async';

import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:pure_live/common/index.dart';

class FavoriteController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final SettingsService settings = Get.find<SettingsService>();
  late TabController tabController;
  int index = 0;

  late RefreshController refreshController = RefreshController();

  FavoriteController() {
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void onInit() {
    super.onInit();
    // 初始化关注页
    onlineRooms.addAll(settings.favoriteRooms
        .where((room) => room.liveStatus == LiveStatus.live));
    offlineRooms.addAll(settings.favoriteRooms
        .where((room) => room.liveStatus != LiveStatus.live));

    // 刷新数据
    onRefresh();
    // 定时自动刷新
    Timer.periodic(Duration(minutes: settings.autoRefreshTime.value), (timer) {
      onRefresh();
    });

    // 监听settings rooms变化
    settings.favoriteRooms.listen((rooms) {
      onlineRooms.clear();
      onlineRooms.addAll(settings.favoriteRooms
          .where((room) => room.liveStatus == LiveStatus.live));

      offlineRooms.clear();
      offlineRooms.addAll(settings.favoriteRooms
          .where((room) => room.liveStatus != LiveStatus.live));
    });
  }

  final onlineRooms = [].obs;
  final offlineRooms = [].obs;

  Future onRefresh() async {
    for (final room in settings.favoriteRooms) {
      try {
        var newRoom = await Sites.of(room.platform).liveSite.getRoomInfo(room);
        settings.updateRoom(newRoom);
      } catch (e) {
        refreshController.refreshFailed();
      }
    }

    onlineRooms.clear();
    onlineRooms.addAll(settings.favoriteRooms
        .where((room) => room.liveStatus == LiveStatus.live));

    offlineRooms.clear();
    offlineRooms.addAll(settings.favoriteRooms
        .where((room) => room.liveStatus != LiveStatus.live));

    refreshController.refreshCompleted();
  }
}
