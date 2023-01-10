import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ice_live_viewer/model/liveroom.dart';
import 'package:ice_live_viewer/provider/popular_provider.dart';
import 'package:ice_live_viewer/utils/http/httpapi.dart';
import 'package:ice_live_viewer/utils/keepalivewrapper.dart';
import 'package:ice_live_viewer/widgets/room_card.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PopularPage extends StatefulWidget {
  const PopularPage({Key? key}) : super(key: key);

  @override
  State<PopularPage> createState() => _PopularPageState();
}

class _PopularPageState extends State<PopularPage> {
  late PopularProvider provider;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<PopularProvider>(context);
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "POPULAR",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                provider.platform.toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
        ],
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
        controller: provider.refreshController,
        onRefresh: provider.onRefresh,
        onLoading: provider.onLoading,
        child: provider.roomList.isNotEmpty
            ? MasonryGridView.count(
                padding: const EdgeInsets.all(5),
                controller: ScrollController(),
                crossAxisCount: screenWidth > 1280
                    ? 8
                    : (screenWidth > 960 ? 6 : (screenWidth > 640 ? 4 : 2)),
                itemCount: provider.roomList.length,
                // physics: (const BouncingScrollPhysics()),
                itemBuilder: (context, index) =>
                    RoomCard(room: provider.roomList[index], dense: true),
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
                  children: provider.platforms
                      .map<Widget>(
                        (e) => ListTile(
                          title: Text(e.toUpperCase()),
                          onTap: () {
                            provider.setPlatform(e);
                            Navigator.of(context).pop();
                          },
                        ),
                      )
                      .toList(),
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

class RoomGridView extends StatelessWidget {
  const RoomGridView({Key? key, required this.provider}) : super(key: key);

  final PopularProvider provider;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (provider.roomList.isNotEmpty) {
      return KeepAliveWrapper(
          child: MasonryGridView.count(
        padding: const EdgeInsets.all(5),
        controller: ScrollController(),
        crossAxisCount: screenWidth > 1280
            ? 8
            : (screenWidth > 960 ? 6 : (screenWidth > 640 ? 4 : 2)),
        itemCount: provider.roomList.length,
        // physics: (const BouncingScrollPhysics()),
        itemBuilder: (context, index) => RoomCard(
          room: provider.roomList[index],
          dense: true,
        ),
      ));
    }
    return const RoomEmptyView();
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
