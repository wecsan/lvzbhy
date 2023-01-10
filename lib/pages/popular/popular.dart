import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ice_live_viewer/model/liveroom.dart';
import 'package:ice_live_viewer/utils/http/httpapi.dart';
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
  String platform = 'bilibili';

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  void _onRefresh() async {
    pageIndex = 0;
    final items = await HttpApi.getRecommend(platform, page: pageIndex);
    roomsList.clear();
    roomsList.addAll(items);
    _refreshController.refreshCompleted();
    setState(() {});
  }

  void _onLoading() async {
    pageIndex++;
    final items = await HttpApi.getRecommend(platform, page: pageIndex);
    if (items.isEmpty) {
      _refreshController.loadFailed();
    } else {
      roomsList.addAll(items);
      _refreshController.loadComplete();
    }
    setState(() {});
  }

  void _changePlatform(String name) async {
    platform = name;
    _onRefresh();
    setState(() {});
    Navigator.pop(context);
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
            return SizedBox(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('Bilibili'),
                      onTap: () => _changePlatform("bilibili"),
                    ),
                    ListTile(
                      title: const Text('Douyu'),
                      onTap: () => _changePlatform("douyu"),
                    ),
                    ListTile(
                      title: const Text('Huya'),
                      onTap: () => _changePlatform("huya"),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.video_collection_rounded),
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
                    text: "Click the button below\nto switch platform",
                    style: Theme.of(context).textTheme.headline3),
              ]),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
