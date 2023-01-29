import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hot_live/common/index.dart';
import 'package:hot_live/pages/index.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'widgets/room_card.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late FavoriteProvider favorite = Provider.of<FavoriteProvider>(context);
  late SettingsProvider settings = Provider.of<SettingsProvider>(context);
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

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
        scrolledUnderElevation: screenWidth > 640 ? 0 : null,
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
        controller: refreshController,
        onRefresh: () => favorite.onRefresh().then((value) {
          refreshController.refreshCompleted();
        }),
        child: favorite.roomList.isNotEmpty
            ? MasonryGridView.count(
                padding: const EdgeInsets.all(5),
                controller: ScrollController(),
                crossAxisCount: crossAxisCount,
                itemCount: favorite.roomList.length,
                itemBuilder: (context, index) => RoomCard(
                  room: favorite.roomList[index],
                  dense: settings.enableDenseFavorites,
                  onLongPress: () =>
                      onLongPress(context, favorite.roomList[index]),
                ),
              )
            : EmptyView(
                icon: Icons.favorite_rounded,
                title: favorite.hideOffline
                    ? S.of(context).empty_favorite_online_title
                    : S.of(context).empty_favorite_title,
                subtitle: favorite.hideOffline
                    ? S.of(context).empty_favorite_online_subtitle
                    : S.of(context).empty_favorite_subtitle,
              ),
      ),
      floatingActionButton: favorite.hideOffline
          ? FloatingActionButton(
              tooltip: S.of(context).show_offline_rooms,
              onPressed: favorite.toggleHideOffline,
              child: const Icon(Icons.add_circle_outline_rounded),
            )
          : FloatingActionButton(
              tooltip: S.of(context).hide_offline_rooms,
              onPressed: favorite.toggleHideOffline,
              child: const Icon(Icons.remove_circle_outline_rounded),
            ),
    );
  }
}
