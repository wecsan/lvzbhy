import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hot_live/model/liveroom.dart';
import 'package:hot_live/pages/live_play/live_play.dart';
import 'package:hot_live/provider/favorite_provider.dart';
import 'package:hot_live/utils/http/httpapi.dart';
import 'package:hot_live/widgets/empty_view.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController controller;

  List<RoomInfo> ownerList = [];
  bool isLive = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  final List<String> platforms = [
    'bilibili',
    'douyu',
    'huya',
  ];

  void _onSearch(String key) async {
    ownerList.clear();
    for (var plat in platforms) {
      var items = await HttpApi.search(plat, key, isLive: isLive);
      ownerList.addAll(items);
    }
    setState(() {});
  }

  void _toggleIsLive() {
    setState(() {
      isLive = !isLive;
    });
  }

  @override
  Widget build(BuildContext context) {
    FavoriteProvider favoritePod = Provider.of<FavoriteProvider>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TextField(
          controller: controller,
          autofocus: true,
          onSubmitted: _onSearch,
          decoration: const InputDecoration(
            hintText: 'Input User Name or RoomId',
            hintStyle: TextStyle(fontSize: 13),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Only Living',
            onPressed: _toggleIsLive,
            icon: Icon(
              Icons.live_tv_rounded,
              color: isLive
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).disabledColor,
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
          : const EmptyView(
              icon: Icons.live_tv_rounded,
              title: 'No Live Found',
              subtitle: 'You can input other keyword',
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
    final fullRoom = await HttpApi.getRoomInfo(room);
    fullRoom.cdnMultiLink = await HttpApi.getRoomStreamLink(room);
    String info = '';
    if (room.liveStatus == LiveStatus.live) {
      if (room.cdnMultiLink.isEmpty) {
        info = 'Get live stream link failed';
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LivePlayPage(room: room)),
        );
      }
    } else {
      info = '${room.nick} is offline.';
    }

    if (info.isNotEmpty) {
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
          room.platform + " - " + room.areaName,
          maxLines: 1,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: favoritePod.isFavorite(room.roomId)
            ? ElevatedButton(
                onPressed: () => favoritePod.removeRoom(room),
                child: Text('Followed', style: followedStyle),
              )
            : ElevatedButton(
                onPressed: () => favoritePod.addRoom(room),
                child: const Text('Follow'),
              ),
      ),
    );
  }
}
