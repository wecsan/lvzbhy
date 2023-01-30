import 'package:better_player/better_player.dart';
import 'package:hot_live/common/index.dart';

import './danmaku_video_controller.dart';

class MobileDanmakuVideoPlayer extends StatefulWidget {
  final DanmakuStream danmakuStream;
  final RoomInfo room;
  final String datasource;
  final bool fullScreenByDefault;
  final bool allowBackgroundPlay;
  final bool allowedScreenSleep;
  final double? width;

  const MobileDanmakuVideoPlayer({
    Key? key,
    required this.danmakuStream,
    required this.room,
    required this.datasource,
    this.fullScreenByDefault = false,
    this.allowBackgroundPlay = false,
    this.allowedScreenSleep = false,
    this.width,
  }) : super(key: key);

  @override
  State<MobileDanmakuVideoPlayer> createState() =>
      MobileDanmakuVideoPlayerState();
}

class MobileDanmakuVideoPlayerState extends State<MobileDanmakuVideoPlayer> {
  BetterPlayerController? controller;
  final _betterPlayerKey = GlobalKey();
  final _danmakuNormal = GlobalKey();
  final _danmakuFullScreen = GlobalKey();

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
        eventListener: pipModeListener,
      ),
    );
    controller?.setControlsEnabled(false);
    setDataSource(widget.datasource);
    setState(() {});
  }

  void setDataSource(String url) {
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

  void pipModeListener(BetterPlayerEvent event) {
    if (event.betterPlayerEventType == BetterPlayerEventType.pipStart) {
      _isPipMode = true;
    } else if (event.betterPlayerEventType == BetterPlayerEventType.pipStop) {
      _isPipMode = false;
    }
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

  Widget routePageBuilder(
      BuildContext context,
      Animation<double> animation,
      Animation<double> second,
      BetterPlayerControllerProvider controllerProvider) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        if (_isPipMode) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(
              alignment: Alignment.center,
              color: Colors.black,
              child: controllerProvider,
            ),
          );
        }

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            alignment: Alignment.center,
            color: Colors.black,
            child: Stack(children: [
              controllerProvider,
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

  @override
  Widget build(BuildContext context) {
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
