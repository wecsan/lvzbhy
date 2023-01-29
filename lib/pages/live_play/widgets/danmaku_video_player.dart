import 'package:better_player/better_player.dart';
import 'package:hot_live/common/index.dart';

import './danmaku_video_controller.dart';

class DanmakuVideoPlayer extends StatefulWidget {
  final DanmakuStream danmakuStream;
  final RoomInfo room;
  final String url;
  final bool fullScreenByDefault;
  final bool allowBackgroundPlay;
  final bool allowedScreenSleep;
  final double? width;

  const DanmakuVideoPlayer({
    Key? key,
    required this.danmakuStream,
    required this.room,
    required this.url,
    this.fullScreenByDefault = false,
    this.allowBackgroundPlay = false,
    this.allowedScreenSleep = false,
    this.width,
  }) : super(key: key);

  @override
  State<DanmakuVideoPlayer> createState() => DanmakuVideoPlayerState();
}

class DanmakuVideoPlayerState extends State<DanmakuVideoPlayer> {
  BetterPlayerController? controller;
  final GlobalKey _betterPlayerKey = GlobalKey();
  final GlobalKey<DanmakuVideoControllerState> _danmakuNormal = GlobalKey();
  final GlobalKey<DanmakuVideoControllerState> _danmakuFullScreen = GlobalKey();

  bool _isPipMode = false;

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
          errorBuilder: errorBuilder,
          routePageBuilder: routePageBuilder,
          eventListener: ((p0) {
            if (p0.betterPlayerEventType == BetterPlayerEventType.pipStart) {
              setState(() => _isPipMode = true);
            } else if (p0.betterPlayerEventType ==
                BetterPlayerEventType.pipStop) {
              setState(() => _isPipMode = false);
            }
          })),
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
    setState(() {});
  }

  void setResolution(String url) {
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

  Widget routePageBuilder(
      BuildContext context,
      Animation<double> animation,
      Animation<double> second,
      BetterPlayerControllerProvider controllerProvider) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            alignment: Alignment.center,
            color: Colors.black,
            child: Stack(children: [
              controllerProvider,
              if (!_isPipMode)
                DanmakuVideoController(
                  key: _danmakuFullScreen,
                  playerKey: _betterPlayerKey,
                  controller: controller!,
                  danmakuStream: widget.danmakuStream,
                  title: widget.room.title,
                ),
            ]),
          ),
        );
      },
    );
  }

  Widget errorBuilder(BuildContext context, String? errorMessage) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '无法播放直播',
            style: TextStyle(color: Colors.white),
          ),
          TextButton(
            onPressed: resumePlayer,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null) {
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
        BetterPlayer(
          key: _betterPlayerKey,
          controller: controller!,
        ),
        DanmakuVideoController(
          key: _danmakuNormal,
          playerKey: _betterPlayerKey,
          controller: controller!,
          danmakuStream: widget.danmakuStream,
          title: widget.room.title,
          width: widget.width,
        ),
      ],
    );
  }
}
