import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ice_live_viewer/pages/settings.dart';

import 'package:ice_live_viewer/model/liveroom.dart';
import 'package:ice_live_viewer/provider/favorite_provider.dart';
import 'package:ice_live_viewer/widgets/empty_view.dart';
import 'package:ice_live_viewer/widgets/onloading_footer.dart';
import 'package:ice_live_viewer/widgets/room_card.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late FavoriteProvider provider;

  void onLongPress(BuildContext context, RoomInfo room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(room.title),
        content: Text(
          'RoomId: ' +
              room.roomId +
              '\nPlatform: ' +
              room.platform +
              '\nNickName: ' +
              room.nick +
              '\nTitle: ' +
              room.title +
              '\nLiveStatus: ' +
              room.liveStatus.name,
        ),
        actions: [
          TextButton(
            onPressed: () {
              provider.removeRoom(room);
              return Navigator.pop(context);
            },
            child: const Text("Remove"),
          ),
          TextButton(
            onPressed: () {
              provider.moveToTop(room);
              return Navigator.pop(context);
            },
            child: const Text("Move To Top"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<FavoriteProvider>(context);
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "FAVORITES",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          provider.isHideOffline == false
              ? IconButton(
                  onPressed: () => provider.hideOfflineRooms(),
                  tooltip: 'Hide Offline Rooms',
                  icon: const Icon(Icons.remove_circle_outline_rounded))
              : IconButton(
                  onPressed: () => provider.showOfflineRooms(),
                  tooltip: 'Show Offline Rooms',
                  icon: const Icon(Icons.add_circle_outline_rounded)),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SmartRefresher(
        enablePullDown: true,
        header: const WaterDropHeader(),
        controller: provider.refreshController,
        onRefresh: provider.onRefresh,
        child: provider.roomsList.isNotEmpty
            ? MasonryGridView.count(
                padding: const EdgeInsets.all(5),
                controller: ScrollController(),
                crossAxisCount: screenWidth > 1280
                    ? 4
                    : (screenWidth > 960 ? 3 : (screenWidth > 640 ? 2 : 1)),
                itemCount: provider.roomsList.length,
                // physics: (const BouncingScrollPhysics()),
                itemBuilder: (context, index) {
                  RoomInfo room = provider.roomsList[index];
                  return RoomCard(
                    room: room,
                    onLongPress: () => onLongPress(context, room),
                  );
                },
              )
            : const EmptyView(
                icon: Icons.favorite_rounded,
                title: 'No Favorites',
                subtitle: 'Click the button below\nto add live link',
              ),
      ),
      floatingActionButton: FavoriteAddButton(provider: provider),
    );
  }
}

class FavoriteAddButton extends StatelessWidget {
  const FavoriteAddButton({
    Key? key,
    required this.provider,
  }) : super(key: key);

  final FavoriteProvider provider;

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Add live link"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Directly input live link to add room\nsee more info in help page.",
                    style: Theme.of(context).textTheme.caption,
                  ),
                  TextField(controller: controller),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      provider.addRoomLink(controller.text);
                      Navigator.pop(context);
                    },
                    child: const Text("Add")),
              ],
            );
          },
        );
      },
      child: const Icon(Icons.add),
    );
  }
}
