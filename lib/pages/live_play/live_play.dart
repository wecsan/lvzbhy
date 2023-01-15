import 'package:flutter/material.dart';
import 'package:hot_live/api/danmaku/danmaku_stream.dart';
import 'package:hot_live/api/liveapi.dart';
import 'package:hot_live/model/liveroom.dart';
import 'package:hot_live/pages/live_play/danmaku_video_player.dart';
import 'package:hot_live/provider/favorite_provider.dart';
import 'package:hot_live/pages/live_play/danmaku_list_view.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';

class LivePlayPage extends StatefulWidget {
  const LivePlayPage({Key? key, required this.room}) : super(key: key);

  final RoomInfo room;

  @override
  State<LivePlayPage> createState() => _LivePlayPageState();
}

class _LivePlayPageState extends State<LivePlayPage> {
  late DanmakuStream danmakuStream = DanmakuStream(room: widget.room);
  Map<String, Map<String, String>> streamList = {};
  String datasource = '';
  bool datasourceError = false;

  final GlobalKey<DanmakuVideoPlayerState> _globalKey = GlobalKey();
  DanmakuVideoPlayerState get videoPlayer => _globalKey.currentState!;

  @override
  void initState() {
    super.initState();
    LiveApi.getRoomStreamLink(widget.room).then((value) {
      streamList = value;
      setState(() {
        if (streamList.isNotEmpty && streamList.values.first.isNotEmpty) {
          datasource = streamList.values.first.values.first;
        } else {
          datasourceError = true;
        }
      });
    });
  }

  @override
  void dispose() {
    ScreenBrightness().resetScreenBrightness();
    danmakuStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolutionBtns = [];
    streamList.forEach((resolution, cdns) {
      final btn = PopupMenuButton(
        iconSize: 24,
        icon: Text(
          resolution.substring(resolution.length - 2, resolution.length),
          style: Theme.of(context).textTheme.labelSmall,
        ),
        onSelected: (String link) => videoPlayer.setDataSource(link),
        itemBuilder: (context) {
          final menuList = <PopupMenuItem<String>>[];
          cdns.forEach((cdn, url) {
            final menuItem = PopupMenuItem<String>(
              child: Text(cdn, style: const TextStyle(fontSize: 14.0)),
              value: url,
            );
            menuList.add(menuItem);
          });
          return menuList;
        },
      );
      resolutionBtns.add(btn);
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.room.title),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                child: datasource.isNotEmpty
                    ? DanmakuVideoPlayer(
                        key: _globalKey,
                        url: datasource,
                        danmakuStream: danmakuStream,
                      )
                    : Center(
                        child: datasourceError
                            ? const Icon(
                                Icons.error_outline_rounded,
                                size: 42,
                                color: Colors.white70,
                              )
                            : const CircularProgressIndicator(),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: [
                  const Icon(Icons.video_library_rounded, size: 20),
                  const Spacer(),
                  const IconButton(onPressed: null, icon: Text('')),
                  ...resolutionBtns,
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: DanmakuListView(
                room: widget.room,
                danmakuStream: danmakuStream,
              ),
            ),
            OwnerListTile(room: widget.room),
          ],
        ),
      ),
    );
  }
}

class OwnerListTile extends StatelessWidget {
  const OwnerListTile({Key? key, required this.room}) : super(key: key);

  final RoomInfo room;

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final followedStyle = Theme.of(context)
        .textTheme
        .button
        ?.copyWith(color: Theme.of(context).errorColor);

    return ListTile(
      leading: CircleAvatar(
        foregroundImage: (room.avatar == '') ? null : NetworkImage(room.avatar),
        radius: 18,
        backgroundColor: Theme.of(context).disabledColor,
      ),
      title: Text(
        room.nick,
        maxLines: 1,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: favoriteProvider.isFavorite(room.roomId)
          ? ElevatedButton(
              onPressed: () => favoriteProvider.removeRoom(room),
              child: Text('Followed', style: followedStyle),
            )
          : ElevatedButton(
              onPressed: () => favoriteProvider.addRoom(room),
              child: const Text('Follow'),
            ),
    );
  }
}
