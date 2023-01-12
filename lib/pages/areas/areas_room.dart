import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hot_live/model/livearea.dart';
import 'package:hot_live/model/liveroom.dart';
import 'package:hot_live/utils/http/httpapi.dart';
import 'package:hot_live/widgets/onloading_footer.dart';
import 'package:hot_live/widgets/room_card.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AreasRoomPage extends StatefulWidget {
  const AreasRoomPage({Key? key, required this.area}) : super(key: key);

  final AreaInfo area;

  @override
  State<AreasRoomPage> createState() => _AreasRoomPageState();
}

class _AreasRoomPageState extends State<AreasRoomPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<RoomInfo> roomsList = [];
  int pageIndex = 1;

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  void _onRefresh() async {
    pageIndex = 0;
    final items = await HttpApi.getAreaRooms(widget.area, page: pageIndex);
    if (items.isEmpty) {
      _refreshController.refreshFailed();
    } else {
      roomsList.clear();
      roomsList.addAll(items);
      _refreshController.refreshCompleted();
    }
    setState(() {});
  }

  void _onLoading() async {
    pageIndex++;
    final items = await HttpApi.getAreaRooms(widget.area, page: pageIndex);
    if (items.isEmpty) {
      _refreshController.loadFailed();
    } else {
      for (var item in items) {
        if (roomsList.indexWhere((e) => e.roomId == item.roomId) != -1) {
          continue;
        }
        roomsList.add(item);
      }
      _refreshController.loadComplete();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text(widget.area.areaName)),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: const WaterDropHeader(),
        footer: const OnLoadingFooter(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: roomsList.isNotEmpty
            ? MasonryGridView.count(
                padding: const EdgeInsets.all(5),
                controller: ScrollController(),
                crossAxisCount: screenWidth > 1280
                    ? 8
                    : (screenWidth > 960 ? 6 : (screenWidth > 640 ? 4 : 2)),
                itemCount: roomsList.length,
                // physics: (const BouncingScrollPhysics()),
                itemBuilder: (context, index) =>
                    RoomCard(room: roomsList[index], dense: true),
              )
            : const RoomEmptyView(),
      ),
    );
  }
}

class RoomEmptyView extends StatelessWidget {
  const RoomEmptyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.live_tv_rounded,
            size: 144,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 32),
          Text.rich(
              TextSpan(children: [
                TextSpan(
                    text: "No Live Found\n\n",
                    style: Theme.of(context).textTheme.headlineLarge),
                TextSpan(
                    text: "Drag page to refresh data",
                    style: Theme.of(context).textTheme.headline3),
              ]),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
