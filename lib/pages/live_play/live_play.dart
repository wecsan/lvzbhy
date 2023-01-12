import 'package:flutter/material.dart';
import 'package:flutter_barrage/flutter_barrage.dart';
import 'package:hot_live/api/danmaku/danmaku_stream.dart';
import 'package:hot_live/model/liveroom.dart';
import 'package:hot_live/provider/favorite_provider.dart';
import 'package:hot_live/pages/live_play/danmaku_listview.dart';
import 'package:chewie/chewie.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import 'danmaku_chewie_controller.dart';

class LivePlayPage extends StatefulWidget {
  const LivePlayPage({Key? key, required this.room}) : super(key: key);

  final RoomInfo room;

  @override
  State<LivePlayPage> createState() => _LivePlayPageState();
}

class _LivePlayPageState extends State<LivePlayPage> {
  late VideoPlayerController videoController;
  late ChewieController chewieController;
  late DanmakuStream danmakuStream;
  late BarrageWallController barrageWallController;

  late String title;
  late Map<dynamic, dynamic> cdnMultiLink;

  @override
  void initState() {
    super.initState();

    title = widget.room.title;
    cdnMultiLink = widget.room.cdnMultiLink;

    // 设置弹幕监控流
    danmakuStream = DanmakuStream(room: widget.room);
    barrageWallController = BarrageWallController();
    _initVideoController(cdnMultiLink.values.toList()[0].values.toList()[0]);
  }

  void _initVideoController(String url, {bool swap = false}) {
    if (swap) videoController.dispose();
    videoController = VideoPlayerController.network(url)
      ..initialize().then(
        (_) {
          if (swap) chewieController.dispose();
          chewieController = ChewieController(
            videoPlayerController: videoController,
            customControls: DanmakuChewieControllers(
              danmakuContoller: barrageWallController,
            ),
            autoPlay: true,
            isLive: true,
          );
          setState(() {});
        },
      );
  }

  @override
  void dispose() {
    super.dispose();
    chewieController.dispose();
    videoController.dispose();
    barrageWallController.dispose();
    danmakuStream.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FavoriteProvider favoritePod = Provider.of<FavoriteProvider>(context);
    Wakelock.enable();

    final resolutionBtns = [];
    cdnMultiLink.forEach(((key, value) {
      resolutionBtns.add(
        PopupMenuButton(
          iconSize: 24,
          icon: Text(
            key,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          onSelected: (String link) => _initVideoController(link, swap: true),
          itemBuilder: (context) {
            final menuList = <PopupMenuItem<String>>[];
            value.forEach((k, v) {
              menuList.add(PopupMenuItem(
                child: Text(k, style: const TextStyle(fontSize: 14.0)),
                value: v,
              ));
            });
            return menuList;
          },
        ),
      );
    }));

    return WillPopScope(
      onWillPop: () async {
        videoController.pause();
        Wakelock.disable();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
              Wakelock.disable();
            },
          ),
          title: Text(title),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 16 / 9,
                child: videoController.value.isInitialized
                    ? Container(
                        child: Chewie(controller: chewieController),
                        color: Colors.black,
                      )
                    : Container(color: Colors.black),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  children: [
                    const Icon(Icons.video_library_rounded, size: 20),
                    const Spacer(),
                    ...resolutionBtns,
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: DanmakuListView(
                  room: widget.room,
                  danmakuStream: danmakuStream,
                  barrageWallController: barrageWallController,
                ),
              ),
              OwnerListTile(
                room: widget.room,
                favoritePod: favoritePod,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OwnerListTile extends StatelessWidget {
  const OwnerListTile({
    Key? key,
    required this.room,
    required this.favoritePod,
  }) : super(key: key);

  final RoomInfo room;
  final FavoriteProvider favoritePod;

  @override
  Widget build(BuildContext context) {
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
      trailing: favoritePod.isFavorite(room.roomId)
          ? ElevatedButton(
              onPressed: () {
                favoritePod.removeRoom(room);
              },
              child: Text('Followed', style: followedStyle),
            )
          : ElevatedButton(
              onPressed: () {
                favoritePod.addRoom(room);
              },
              child: const Text('Follow'),
            ),
    );
  }
}
