import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hot_live/generated/l10n.dart';
import 'package:hot_live/pages/search/search.dart';
import 'package:hot_live/pages/settings/settings.dart';

import 'package:hot_live/model/liveroom.dart';
import 'package:hot_live/provider/favorite_provider.dart';
import 'package:hot_live/provider/settings_provider.dart';
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
  late FavoriteProvider favorite = Provider.of<FavoriteProvider>(context);
  late SettingsProvider settings = Provider.of<SettingsProvider>(context);

  List<RoomInfo> get roomList =>
      settings.hideOfflineRoom ? favorite.onlineRoomList : favorite.roomsList;

  void onLongPress(BuildContext context, RoomInfo room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(room.title),
        content: Text(
          S.of(context).room_info_content(
                room.roomId,
                room.platform,
                room.nick,
                room.title,
                room.liveStatus.name,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              favorite.removeRoom(room);
              Navigator.of(context).pop();
            },
            child: Text(S.of(context).remove),
          ),
          TextButton(
            onPressed: () {
              favorite.moveToTop(room);
              Navigator.of(context).pop();
            },
            child: Text(S.of(context).move_to_top),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1280
        ? 4
        : (screenWidth > 960 ? 3 : (screenWidth > 640 ? 2 : 1));
    if (settings.enableDenseFavorites) {
      crossAxisCount = screenWidth > 1280
          ? 8
          : (screenWidth > 960 ? 6 : (screenWidth > 640 ? 4 : 2));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).favorites_title.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w600),
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
        controller: favorite.refreshController,
        onRefresh: favorite.onRefresh,
        child: roomList.isNotEmpty
            ? MasonryGridView.count(
                padding: const EdgeInsets.all(5),
                controller: ScrollController(),
                crossAxisCount: crossAxisCount,
                itemCount: roomList.length,
                itemBuilder: (context, index) => RoomCard(
                  room: roomList[index],
                  dense: settings.enableDenseFavorites,
                  onLongPress: () => onLongPress(context, roomList[index]),
                ),
              )
            : EmptyView(
                icon: Icons.favorite_rounded,
                title: S.of(context).empty_favorite_title,
                subtitle: S.of(context).empty_favorite_subtitle,
              ),
      ),
      floatingActionButton: settings.hideOfflineRoom
          ? FloatingActionButton(
              tooltip: S.of(context).show_offline_rooms,
              onPressed: () => settings.hideOfflineRoom = false,
              child: const Icon(Icons.add_circle_outline_rounded),
            )
          : FloatingActionButton(
              tooltip: S.of(context).hide_offline_rooms,
              onPressed: () => settings.hideOfflineRoom = true,
              child: const Icon(Icons.remove_circle_outline_rounded),
            ),
    );
  }
}
