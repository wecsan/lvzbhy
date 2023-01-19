import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:hot_live/api/danmaku/danmaku_stream.dart';
import 'package:hot_live/model/liveroom.dart';
import 'package:hot_live/pages/live_play/danmaku_video_controller.dart';

class DanmakuVideoPlayer extends StatefulWidget {
  final DanmakuStream danmakuStream;
  final RoomInfo room;
  final String url;
  final bool allowBackgroundPlay;
  final bool allowedScreenSleep;
  final bool allowedForceRetry;

  const DanmakuVideoPlayer({
    Key? key,
    required this.danmakuStream,
    required this.room,
    required this.url,
    this.allowBackgroundPlay = false,
    this.allowedScreenSleep = false,
    this.allowedForceRetry = false,
  }) : super(key: key);

  @override
  State<DanmakuVideoPlayer> createState() => DanmakuVideoPlayerState();
}

class DanmakuVideoPlayerState extends State<DanmakuVideoPlayer> {
  late BetterPlayerController controller;
  late Widget damakuVideoControls;

  @override
  void initState() {
    super.initState();
    controller = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        fit: BoxFit.contain,
        allowedScreenSleep: widget.allowedScreenSleep,
        autoDetectFullscreenDeviceOrientation: true,
        autoDetectFullscreenAspectRatio: true,
        routePageBuilder: fullScreenPageBuilder,
      ),
      betterPlayerDataSource: BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.url,
        liveStream: true,
        notificationConfiguration: widget.allowBackgroundPlay
            ? BetterPlayerNotificationConfiguration(
                showNotification: true,
                title: widget.room.title,
                author: widget.room.nick,
                imageUrl: widget.room.cover,
                activityName: "MainActivity",
              )
            : null,
      ),
    );
    controller.setControlsEnabled(false);
    damakuVideoControls = DanmakuVideoController(
      controller: controller,
      danmakuStream: widget.danmakuStream,
      title: widget.room.title,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget fullScreenPageBuilder(
      BuildContext context,
      Animation<double> animation,
      Animation<double> second,
      BetterPlayerControllerProvider controllerProvider) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          alignment: Alignment.center,
          color: Colors.black,
          child: Stack(children: [
            controllerProvider,
            damakuVideoControls,
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BetterPlayer(controller: controller),
        damakuVideoControls,
      ],
    );
  }
}
