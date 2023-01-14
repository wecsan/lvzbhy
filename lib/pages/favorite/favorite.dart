import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hot_live/pages/search/search.dart';
import 'package:hot_live/pages/settings/settings.dart';

import 'package:hot_live/model/liveroom.dart';
import 'package:hot_live/provider/favorite_provider.dart';
import 'package:hot_live/widgets/custom_icons.dart';
import 'package:hot_live/widgets/empty_view.dart';
import 'package:hot_live/widgets/room_card.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late FavoriteProvider provider = Provider.of<FavoriteProvider>(context);
  late double screenWidth = MediaQuery.of(context).size.width;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "FAVORITES",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
            icon: const Icon(CustomIcons.search),
          ),
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
                subtitle: 'Please follow live rooms first',
              ),
      ),
      floatingActionButton: provider.isHideOffline
          ? FloatingActionButton(
              tooltip: 'Show Offline Rooms',
              onPressed: provider.showOfflineRooms,
              child: const Icon(Icons.add_circle_outline_rounded),
            )
          : FloatingActionButton(
              tooltip: 'Hide Offline Rooms',
              onPressed: provider.hideOfflineRooms,
              child: const Icon(Icons.remove_circle_outline_rounded),
            ),
    );
  }
}
