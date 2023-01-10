import 'package:flutter/material.dart';
import 'package:flutter_barrage/flutter_barrage.dart';
import 'package:ice_live_viewer/model/liveroom.dart';
import 'package:ice_live_viewer/pages/video_play_page/mychewie_controller.dart';
import 'package:ice_live_viewer/provider/favorite_provider.dart';
import 'package:ice_live_viewer/widgets/danmaku/bilibilianmaku.dart';
import 'package:ice_live_viewer/widgets/danmaku/huyadanmaku.dart';
import 'package:ice_live_viewer/widgets/danmaku/douyudanmaku.dart';
import 'package:chewie/chewie.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class MobilePlayer extends StatefulWidget {
  const MobilePlayer({Key? key, required this.room}) : super(key: key);

  final RoomInfo room;

  @override
  State<MobilePlayer> createState() => _MobilePlayerState();
}

class _MobilePlayerState extends State<MobilePlayer> {
  late VideoPlayerController _controller;
  late ChewieController chewieController;
  late BarrageWallController barrageController;

  late String title;
  late Map<dynamic, dynamic> cdnMultiLink;
  late String url;
  late int danmakuId;
  late String type;

  @override
  void initState() {
    super.initState();

    title = widget.room.title;
    cdnMultiLink = widget.room.cdnMultiLink;
    url = cdnMultiLink.values.toList()[0][0];
    danmakuId = int.parse(widget.room.roomId);
    type = widget.room.platform;

    _controller = VideoPlayerController.network(url)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    barrageController = BarrageWallController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    chewieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FavoriteProvider favoritePod = Provider.of<FavoriteProvider>(context);
    Wakelock.enable();

    final chewieController = ChewieController(
      videoPlayerController: _controller,
      customControls: MyChewieMaterialControls(
        barrageController: barrageController,
      ),
      autoPlay: true,
      isLive: true,
    );
    final nativeVideo = _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Chewie(controller: chewieController),
          )
        : AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
            ),
          );
    final danmakuListView = type == 'huya'
        ? HuyaDanmakuListView(
            danmakuId: danmakuId,
            barrageController: barrageController,
          )
        : (type == 'bilibili'
            ? BilibiliDanmakuListView(
                roomId: danmakuId,
                barrageController: barrageController,
              )
            : DouYuDanmakuListView(
                roomId: danmakuId,
                barrageController: barrageController,
              ));
    final resolutionBtns = [];
    cdnMultiLink.forEach(((key, value) {
      var urlList = value as List<dynamic>;
      resolutionBtns.add(
        PopupMenuButton(
          iconSize: 24,
          icon: Text(
            key,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          onSelected: (dynamic link) {
            _controller.dispose();
            _controller = VideoPlayerController.network(link)
              ..initialize().then((_) {
                // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                setState(() {});
              });
          },
          itemBuilder: (context) {
            final menuList = <PopupMenuItem>[];
            for (var i = 0; i < urlList.length; i++) {
              menuList.add(PopupMenuItem(
                child: Text("Line ${i + 1}",
                    style: const TextStyle(fontSize: 14.0)),
                value: urlList[i],
              ));
            }
            return menuList;
          },
        ),
      );
    }));

    return WillPopScope(
      onWillPop: () async {
        _controller.pause();
        Wakelock.disable();
        //Wakelock.enabled.then((value) => print('Wakelock:$value'));
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
              Wakelock.disable();
              //Wakelock.enabled.then((value) => print('Wakelock:$value'));
            },
          ),
          title: Text(title),
        ),
        body: Column(
          children: <Widget>[
            nativeVideo,
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Resolution",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  ...resolutionBtns,
                ],
              ),
            ),
            Expanded(
              child: danmakuListView,
            ),
            ListTile(
              leading: CircleAvatar(
                foregroundImage: (widget.room.avatar == '')
                    ? null
                    : NetworkImage(widget.room.avatar),
                radius: 18,
                backgroundColor: Theme.of(context).disabledColor,
              ),
              title: Text(
                widget.room.nick,
                maxLines: 1,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: favoritePod.isFavorite(widget.room.roomId)
                  ? ElevatedButton(
                      onPressed: () {
                        favoritePod.removeRoom(widget.room);
                      },
                      child: Text(
                        'Followed',
                        style: Theme.of(context)
                            .textTheme
                            .button
                            ?.copyWith(color: Theme.of(context).errorColor),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        favoritePod.addRoom(widget.room);
                      },
                      child: const Text('Follow'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
