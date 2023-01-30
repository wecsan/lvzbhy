import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hot_live/pages/index.dart';
import 'package:hot_live/common/index.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PopularPage extends StatefulWidget {
  const PopularPage({Key? key}) : super(key: key);

  @override
  State<PopularPage> createState() => _PopularPageState();
}

class _PopularPageState extends State<PopularPage> {
  late final provider = Provider.of<PopularProvider>(context);
  final refreshController = RefreshController(initialRefresh: false);
  final scrollController = ScrollController();

  bool loading = false;

  static const Map<String, String> names = {
    'bilibili': '哔哩',
    'douyu': '斗鱼',
    'huya': '虎牙',
  };

  void _onRefresh() {
    provider.onRefresh().then(
          (value) => value
              ? refreshController.refreshCompleted()
              : refreshController.refreshFailed(),
        );
  }

  void _onLoading() {
    if (loading) return;

    loading = true;
    provider.onLoading().then((value) {
      loading = false;
      value ? refreshController.loadComplete() : refreshController.loadFailed();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1280
        ? 5
        : (screenWidth > 960 ? 4 : (screenWidth > 640 ? 3 : 2));

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: screenWidth > 640 ? 0 : null,
        title: DropdownButton(
          underline: Container(),
          borderRadius: BorderRadius.circular(15),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: Theme.of(context)
              .textTheme
              .headline6
              ?.copyWith(fontWeight: FontWeight.w600),
          value: provider.platform,
          items: provider.platforms
              .map((e) => DropdownMenuItem(value: e, child: Text(names[e]!)))
              .toList(),
          onChanged: (String? value) {
            provider.setPlatform(value ?? 'bilibili');
          },
        ),
      ),
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
          child: provider.roomList.isNotEmpty
              ? MasonryGridView.count(
                  padding: const EdgeInsets.all(5),
                  controller: scrollController,
                  crossAxisCount: crossAxisCount,
                  itemCount: provider.roomList.length,
                  itemBuilder: (context, index) =>
                      RoomCard(room: provider.roomList[index], dense: true),
                )
              : EmptyView(
                  icon: Icons.live_tv_rounded,
                  title: S.of(context).empty_live_title,
                  subtitle: S.of(context).empty_live_subtitle,
                ),
        ),
      ),
    );
  }
}
