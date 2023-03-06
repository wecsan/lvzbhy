import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:pure_live/common/index.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:pure_live/modules/area_rooms/area_rooms_controller.dart';

class AreasRoomPage extends GetView<AreaRoomsController> {
  const AreasRoomPage({Key? key}) : super(key: key);

  int get crossAxisCount {
    double screenWidth = Get.size.width;
    int crossAxisCount = screenWidth > 1280
        ? 5
        : (screenWidth > 960 ? 4 : (screenWidth > 640 ? 3 : 2));
    return crossAxisCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(controller.area.areaName)),
      body: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent &&
              event.scrollDelta.direction >= 0 &&
              event.scrollDelta.direction <= pi) {
            final pos = controller.scrollController.position;
            if (pos.maxScrollExtent - pos.pixels < 40) {
              controller.onLoading();
            }
          }
        },
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: const WaterDropHeader(),
          footer: const OnLoadingFooter(),
          controller: controller.refreshController,
          onRefresh: controller.onRefresh,
          onLoading: controller.onLoading,
          child: Obx(
            () => controller.list.isNotEmpty
                ? MasonryGridView.count(
                    padding: const EdgeInsets.all(5),
                    controller: controller.scrollController,
                    crossAxisCount: crossAxisCount,
                    itemCount: controller.list.length,
                    itemBuilder: (context, index) =>
                        RoomCard(room: controller.list[index], dense: true),
                  )
                : EmptyView(
                    icon: Icons.live_tv_rounded,
                    title: S.of(context).empty_areas_room_title,
                    subtitle: S.of(context).empty_areas_room_subtitle,
                  ),
          ),
        ),
      ),
    );
  }
}
