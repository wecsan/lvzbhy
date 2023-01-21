import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hot_live/generated/l10n.dart';
import 'package:hot_live/model/liveroom.dart';
import 'package:hot_live/pages/live_play/live_play.dart';
import 'package:hot_live/provider/favorite_provider.dart';
import 'package:hot_live/api/liveapi.dart';
import 'package:hot_live/provider/settings_provider.dart';
import 'package:hot_live/widgets/empty_view.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController controller = TextEditingController();
  late FavoriteProvider favoritePod = Provider.of<FavoriteProvider>(context);

  final List<RoomInfo> _ownerList = [];
  final List<RoomInfo> _liveOwnerList = [];
  bool isLive = false;

  List<RoomInfo> get ownerList => isLive ? _liveOwnerList : _ownerList;

  final List<String> platforms = [
    'bilibili',
    'douyu',
    'huya',
  ];

  void _onSearch(String key) {
    setState(() {
      _ownerList.clear();
      _liveOwnerList.clear();
    });
    for (var plat in platforms) {
      LiveApi.search(plat, key).then((owners) {
        setState(() {
          _ownerList.addAll(owners);
          _liveOwnerList.addAll(
              owners.where((owner) => owner.liveStatus == LiveStatus.live));
        });
      });
    }
  }

  void _toggleIsLive() {
    setState(() => isLive = !isLive);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TextField(
          controller: controller,
          autofocus: true,
          onSubmitted: _onSearch,
          decoration: InputDecoration(
            hintText: S.of(context).search_input_hint,
            hintStyle: const TextStyle(fontSize: 13),
          ),
        ),
        actions: [
          IconButton(
            tooltip: S.of(context).only_living,
            onPressed: _toggleIsLive,
            icon: Icon(
              Icons.live_tv_rounded,
              color: isLive ? null : Theme.of(context).disabledColor,
            ),
          ),
        ],
      ),
      body: ownerList.isNotEmpty
          ? ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(8),
              itemCount: ownerList.length,
              itemBuilder: (context, index) {
                final room = ownerList[index];
                return OwnerCard(
                  room: room,
                  favoritePod: favoritePod,
                );
              })
          : EmptyView(
              icon: Icons.live_tv_rounded,
              title: S.of(context).empty_search_title,
              subtitle: S.of(context).empty_search_subtitle,
            ),
    );
  }
}

class OwnerCard extends StatelessWidget {
  const OwnerCard({
    Key? key,
    required this.room,
    required this.favoritePod,
  }) : super(key: key);

  final RoomInfo room;
  final FavoriteProvider favoritePod;

  void _onTap(BuildContext context) async {
    final fullRoom = await LiveApi.getRoomInfo(room);
    if (fullRoom.liveStatus == LiveStatus.live) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LivePlayPage(
            room: fullRoom,
            preferResolution:
                Provider.of<SettingsProvider>(context).preferResolution,
          ),
        ),
      );
    } else {
      final info = fullRoom.liveStatus == LiveStatus.offline
          ? S.of(context).info_is_offline(fullRoom.nick)
          : S.of(context).info_is_replay(fullRoom.nick);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(
              info,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final followedStyle = Theme.of(context)
        .textTheme
        .button
        ?.copyWith(color: Theme.of(context).errorColor);

    return Card(
      child: ListTile(
        onTap: () => _onTap(context),
        leading: CircleAvatar(
          foregroundImage: room.avatar.isNotEmpty
              ? CachedNetworkImageProvider(room.avatar)
              : null,
          radius: 20,
          backgroundColor: Theme.of(context).disabledColor,
        ),
        title: Text(
          room.nick,
          maxLines: 1,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          room.platform + " - " + room.area,
          maxLines: 1,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: favoritePod.isFavorite(room.roomId)
            ? ElevatedButton(
                onPressed: () => favoritePod.removeRoom(room),
                child: Text(S.of(context).followed, style: followedStyle),
              )
            : ElevatedButton(
                onPressed: () => favoritePod.addRoom(room),
                child: Text(S.of(context).follow),
              ),
      ),
    );
  }
}
