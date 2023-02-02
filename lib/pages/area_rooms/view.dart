import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pure_live/common/index.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AreasRoomPage extends StatefulWidget {
  const AreasRoomPage({Key? key, required this.area}) : super(key: key);

  final AreaInfo area;

  @override
  State<AreasRoomPage> createState() => _AreasRoomPageState();
}

class _AreasRoomPageState extends State<AreasRoomPage> {
  final refreshController = RefreshController(initialRefresh: false);
  final scrollController = ScrollController();
  List<RoomInfo> roomsList = [];
  int pageIndex = 1;

  int get crossAxisCount {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1280
        ? 5
        : (screenWidth > 960 ? 4 : (screenWidth > 640 ? 3 : 2));
    return crossAxisCount;
  }

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _onRefresh();
    scrollController.addListener(() {
      final pos = scrollController.position;
      if (pos.maxScrollExtent - pos.pixels < 100) {
        _onLoading();
      }
    });
  }

  void _onRefresh() async {
    pageIndex = 0;
    final items = await LiveApi.getAreaRooms(widget.area, page: pageIndex);
    if (items.isEmpty) {
      refreshController.refreshFailed();
    } else {
      roomsList.clear();
      roomsList.addAll(items);
      refreshController.refreshCompleted();
    }
    setState(() {});
  }

  void _onLoading() async {
    if (loading) return;

    loading = true;
    pageIndex++;
    final items = await LiveApi.getAreaRooms(widget.area, page: pageIndex);
    if (items.isEmpty) {
      refreshController.loadFailed();
    } else {
      for (var item in items) {
        if (roomsList.indexWhere((e) => e.roomId == item.roomId) != -1) {
          continue;
        }
        roomsList.add(item);
      }
      refreshController.loadComplete();
    }
    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.area.areaName)),
      body: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent &&
              event.scrollDelta.direction >= 0 &&
              event.scrollDelta.direction <= pi) {
            final pos = scrollController.position;
            if (pos.maxScrollExtent - pos.pixels < 40) {
              _onLoading();
            }
          }
        },
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: const WaterDropHeader(),
          footer: const OnLoadingFooter(),
          controller: refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: roomsList.isNotEmpty
              ? MasonryGridView.count(
                  padding: const EdgeInsets.all(5),
                  controller: scrollController,
                  crossAxisCount: crossAxisCount,
                  itemCount: roomsList.length,
                  itemBuilder: (context, index) =>
                      RoomCard(room: roomsList[index], dense: true),
                )
              : EmptyView(
                  icon: Icons.live_tv_rounded,
                  title: S.of(context).empty_areas_room_title,
                  subtitle: S.of(context).empty_areas_room_subtitle,
                ),
        ),
      ),
    );
  }
}
