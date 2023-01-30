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

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      final pos = scrollController.position;
      if (pos.maxScrollExtent - pos.pixels < 100) {
        _onLoading();
      }
    });
  }

  void showSwitchPlatformDialog() {
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
                    trailing: provider.platform == e
                        ? const Icon(Icons.check_circle_rounded)
                        : const SizedBox(height: 0),
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
  }

  void _onRefresh() {
    provider.onRefresh().then(
          (value) => value
              ? refreshController.refreshCompleted()
              : refreshController.refreshFailed(),
        );
  }

  void _onLoading() {
    provider.onLoading().then(
          (value) => value
              ? refreshController.loadComplete()
              : refreshController.loadFailed(),
        );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1280
        ? 8
        : (screenWidth > 960 ? 6 : (screenWidth > 640 ? 4 : 2));

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: screenWidth > 640 ? 0 : null,
        title: Text(
          S.of(context).popular_title.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w600),
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
      floatingActionButton: FloatingActionButton(
        tooltip: S.of(context).switch_platform,
        onPressed: showSwitchPlatformDialog,
        child: const Icon(Icons.video_collection_rounded),
      ),
    );
  }
}
