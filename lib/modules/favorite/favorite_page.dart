import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:pure_live/common/index.dart';
import 'package:pure_live/modules/favorite/favorite_controller.dart';

class FavoritePage extends GetView<FavoriteController> {
  const FavoritePage({Key? key}) : super(key: key);

  bool get showAction => Get.size.width < 640;

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
          labelColor: Theme.of(context).colorScheme.onBackground,
          labelStyle:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          unselectedLabelColor: Theme.of(context).disabledColor,
          labelPadding: const EdgeInsets.symmetric(horizontal: 12),
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: [
            Tab(text: S.of(context).online_room_title),
            Tab(text: S.of(context).offline_room_title),
          ],
        ),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        physics: const BouncingScrollPhysics(),
        header: const WaterDropHeader(),
        controller: controller.refreshController,
        onRefresh: controller.onRefresh,
        child: TabBarView(controller: controller.tabController, children: [
          _RoomGridView(online: true),
          _RoomGridView(online: false),
        ]),
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

  final bool dense = Get.find<SettingsService>().enableDenseFavorites.value;

  int get crossAxisCount {
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rooms = online ? controller.onlineRooms : controller.offlineRooms;
      return rooms.isNotEmpty
          ? MasonryGridView.count(
              padding: const EdgeInsets.all(5),
              controller: ScrollController(),
              crossAxisCount: crossAxisCount,
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
            );
    });
  }
}
