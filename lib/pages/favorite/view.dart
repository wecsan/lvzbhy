import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hot_live/common/index.dart';
import 'package:hot_live/pages/index.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage>
    with TickerProviderStateMixin {
  late final favorite = Provider.of<FavoriteProvider>(context);
  late final settings = Provider.of<SettingsProvider>(context);
  late final tabController = TabController(length: 2, vsync: this);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1280
        ? 4
        : (screenWidth > 960 ? 3 : (screenWidth > 640 ? 2 : 1));
    if (settings.enableDenseFavorites) {
      crossAxisCount = screenWidth > 1280
          ? 5
          : (screenWidth > 960 ? 4 : (screenWidth > 640 ? 3 : 2));
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        scrolledUnderElevation: 0,
        title: TabBar(
          controller: tabController,
          isScrollable: true,
          labelColor: Theme.of(context).colorScheme.onBackground,
          labelStyle:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          unselectedLabelColor: Theme.of(context).disabledColor,
          labelPadding: const EdgeInsets.symmetric(horizontal: 12),
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: '已开播'),
            Tab(text: '未开播'),
          ],
        ),
        leading: screenWidth > 640
            ? null
            : IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchPage()),
                  );
                },
                icon: const Icon(CustomIcons.search),
              ),
        actions: screenWidth > 640
            ? null
            : [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()),
                    );
                  },
                  icon: const Icon(Icons.settings),
                ),
                const SizedBox(width: 4),
              ],
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          RoomGridView(
            favorite: favorite,
            rooms: favorite.onlineRoomList,
            crossAxisCount: crossAxisCount,
            online: true,
          ),
          RoomGridView(
            favorite: favorite,
            rooms: favorite.offlineRoomList,
            crossAxisCount: crossAxisCount,
            online: false,
          ),
        ],
      ),
    );
  }
}

class RoomGridView extends StatelessWidget {
  final FavoriteProvider favorite;
  final List<RoomInfo> rooms;
  final int crossAxisCount;
  final bool online;

  const RoomGridView({
    Key? key,
    required this.favorite,
    required this.rooms,
    required this.crossAxisCount,
    required this.online,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final refreshController = RefreshController();
    return SmartRefresher(
      enablePullDown: true,
      header: const WaterDropHeader(),
      controller: refreshController,
      onRefresh: () => favorite.onRefresh().then((value) {
        refreshController.refreshCompleted();
      }),
      child: rooms.isNotEmpty
          ? MasonryGridView.count(
              padding: const EdgeInsets.all(5),
              controller: ScrollController(),
              crossAxisCount: crossAxisCount,
              itemCount: rooms.length,
              itemBuilder: (context, index) => RoomCard(
                room: rooms[index],
                dense: settings.enableDenseFavorites,
                onLongPress: () => onLongPress(context, rooms[index]),
              ),
            )
          : EmptyView(
              icon: Icons.favorite_rounded,
              title: online
                  ? S.of(context).empty_favorite_online_title
                  : S.of(context).empty_favorite_offline_title,
              subtitle: online
                  ? S.of(context).empty_favorite_online_subtitle
                  : S.of(context).empty_favorite_offline_subtitle,
            ),
    );
  }

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
        ],
      ),
    );
  }
}
