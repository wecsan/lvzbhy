import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ice_live_viewer/provider/popular_provider.dart';
import 'package:ice_live_viewer/utils/keepalivewrapper.dart';
import 'package:ice_live_viewer/widgets/empty_view.dart';
import 'package:ice_live_viewer/widgets/onloading_footer.dart';
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
        footer: const OnLoadingFooter(),
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
                itemBuilder: (context, index) =>
                    RoomCard(room: provider.roomList[index], dense: true),
              )
            : const EmptyView(
                icon: Icons.live_tv_rounded,
                title: 'No Live Found',
                subtitle: 'Click the button below\nto switch platform',
              ),
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
        },
        child: const Icon(Icons.video_collection_rounded),
      ),
    );
  }
}
