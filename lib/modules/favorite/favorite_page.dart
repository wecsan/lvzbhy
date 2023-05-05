import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:pure_live/common/index.dart';
import 'package:pure_live/modules/favorite/favorite_controller.dart';

class FavoritePage extends GetView<FavoriteController> {
  const FavoritePage({Key? key}) : super(key: key);

  bool get showAction => Get.size.width <= 480;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        scrolledUnderElevation: 0,
        leading: showAction ? const MenuButton() : null,
        actions: showAction ? [const SearchButton()] : null,
        title: TabBar(
          controller: controller.tabController,
          isScrollable: true,
          labelStyle:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          labelPadding: const EdgeInsets.symmetric(horizontal: 12),
          indicatorSize: TabBarIndicatorSize.label,
          tabs: [
            Tab(text: S.of(context).online_room_title),
            Tab(text: S.of(context).offline_room_title),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          _RoomGridView(online: true),
          _RoomGridView(online: false),
        ],
      ),
    );
  }
}

class _RoomGridView extends GetWidget<FavoriteController> {
  final bool online;

  _RoomGridView({
    Key? key,
    required this.online,
  }) : super(key: key);

  int crossAxisCount(bool dense) {
    double screenWidth = Get.size.width;
    int crossAxisCount = screenWidth > 1280
        ? 4
        : (screenWidth > 960 ? 3 : (screenWidth > 640 ? 2 : 1));
    if (dense) {
      crossAxisCount = screenWidth > 1280
          ? 5
          : (screenWidth > 960 ? 4 : (screenWidth > 640 ? 3 : 2));
    }
    return crossAxisCount;
  }

  final refreshController = RefreshController();

  Future onRefresh() async {
    bool result = await controller.onRefresh();
    if (result) {
      refreshController.refreshCompleted();
    } else {
      refreshController.refreshFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dense = Get.find<SettingsService>().enableDenseFavorites.value;
      final rooms = online ? controller.onlineRooms : controller.offlineRooms;

      return SmartRefresher(
        enablePullDown: true,
        physics: const BouncingScrollPhysics(),
        header: const WaterDropHeader(),
        controller: refreshController,
        onRefresh: onRefresh,
        child: rooms.isNotEmpty
            ? MasonryGridView.count(
                padding: const EdgeInsets.all(5),
                controller: ScrollController(),
                crossAxisCount: crossAxisCount(dense),
                itemCount: rooms.length,
                itemBuilder: (context, index) =>
                    RoomCard(room: rooms[index], dense: dense),
              )
            : EmptyView(
                icon: Icons.favorite_rounded,
                title: online
                    ? S.of(context).empty_favorite_online_title
                    : S.of(context).empty_favorite_offline_title,
                subtitle: online
                    ? S.of(context).empty_favorite_online_subtitle
                    : S.of(context).empty_favorite_offline_subtitle,
              ),
      );
    });
  }
}
