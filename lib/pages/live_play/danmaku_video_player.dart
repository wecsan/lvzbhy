import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:hot_live/api/danmaku/danmaku_stream.dart';
import 'package:hot_live/model/liveroom.dart';
import 'package:hot_live/pages/live_play/danmaku_video_controller.dart';

class DanmakuVideoPlayer extends StatefulWidget {
  final DanmakuStream danmakuStream;
  final RoomInfo room;
  final String url;
  final bool fullScreenByDefault;
  final bool allowBackgroundPlay;
  final bool allowedScreenSleep;

  const DanmakuVideoPlayer({
    Key? key,
    required this.danmakuStream,
    required this.room,
    required this.url,
    this.fullScreenByDefault = false,
    this.allowBackgroundPlay = false,
    this.allowedScreenSleep = false,
  }) : super(key: key);

  @override
  State<DanmakuVideoPlayer> createState() => DanmakuVideoPlayerState();
}

class DanmakuVideoPlayerState extends State<DanmakuVideoPlayer> {
  BetterPlayerController? controller;
  Widget? damakuVideoControls;
  final GlobalKey<DanmakuVideoControllerState> _contollerViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    resumePlayer();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void resumePlayer() {
    controller = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        fit: BoxFit.contain,
        fullScreenByDefault: widget.fullScreenByDefault,
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
    controller?.setControlsEnabled(false);
    damakuVideoControls = DanmakuVideoController(
      key: _contollerViewKey,
      controller: controller!,
      danmakuStream: widget.danmakuStream,
      title: widget.room.title,
    );
    setState(() {});
  }

  void stopPlayer() {
    controller?.dispose();
    controller = null;
    _contollerViewKey.currentState?.dispose();
    setState(() {});
  }

  void setResolution(String url) {
    if (controller == null) {
      resumePlayer();
    }
    controller?.setupDataSource(BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
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
    ));
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
            damakuVideoControls!,
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || damakuVideoControls == null) {
      return Center(
        child: IconButton(
          onPressed: resumePlayer,
          icon: const Icon(Icons.refresh_rounded),
          iconSize: 30,
        ),
      );
    }

    return Stack(
      children: [
        BetterPlayer(controller: controller!),
        damakuVideoControls!,
      ],
    );
  }
}
