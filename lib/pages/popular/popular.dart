import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ice_live_viewer/model/liveroom.dart';
import 'package:ice_live_viewer/utils/http/bilibili.dart';
import 'package:ice_live_viewer/widgets/room_card.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PopularPage extends StatefulWidget {
  const PopularPage({Key? key}) : super(key: key);

  @override
  State<PopularPage> createState() => _PopularPageState();
}

class _PopularPageState extends State<PopularPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<RoomInfo> roomsList = [];
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  void _onRefresh() async {
    pageIndex = 0;
    var items = await BilibiliApi.getRecommend(pageIndex, 20);
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
    var items = await BilibiliApi.getRecommend(pageIndex, 20);
    if (items.isEmpty) {
      _refreshController.loadFailed();
    } else {
      roomsList.addAll(items);
      _refreshController.loadComplete();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "POPULAR",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: const WaterDropHeader(),
        footer: CustomFooter(
          builder: (context, mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = const Text("pull up load");
            } else if (mode == LoadStatus.loading) {
              body = const CupertinoActivityIndicator();
            } else if (mode == LoadStatus.failed) {
              body = const Text("Load Failed!Click retry!");
            } else if (mode == LoadStatus.canLoading) {
              body = const Text("release to load more");
            } else {
              body = const Text("No more Data");
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: MasonryGridView.count(
          padding: const EdgeInsets.all(5),
          controller: ScrollController(),
          crossAxisCount: screenWidth > 1280
              ? 8
              : (screenWidth > 960 ? 6 : (screenWidth > 640 ? 4 : 2)),
          itemCount: roomsList.length,
          // physics: (const BouncingScrollPhysics()),
          itemBuilder: (context, index) =>
              RoomCard(room: roomsList[index], dense: true),
        ),
      ),
    );
  }
}
