import 'dart:async';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:hot_live/common/index.dart';
import 'package:window_manager/window_manager.dart';

import './danmaku_video_controller.dart';

class DesktopDanmakuVideoPlayer extends StatefulWidget {
  final DanmakuStream danmakuStream;
  final RoomInfo room;
  final String datasource;
  final bool fullScreenByDefault;
  final bool allowBackgroundPlay;
  final bool allowedScreenSleep;
  final double? width;
  final double? height;

  const DesktopDanmakuVideoPlayer({
    Key? key,
    required this.danmakuStream,
    required this.room,
    required this.datasource,
    this.fullScreenByDefault = false,
    this.allowBackgroundPlay = false,
    this.allowedScreenSleep = false,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<DesktopDanmakuVideoPlayer> createState() =>
      DesktopDanmakuVideoPlayerState();
}

class DesktopDanmakuVideoPlayerState extends State<DesktopDanmakuVideoPlayer> {
  final Player controller = Player(id: 0, registerTexture: true);
  final _playerKey = GlobalKey();
  final _danmakuNormal = GlobalKey();

  @override
  void initState() {
    super.initState();
    resumePlayer();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void resumePlayer() {
    setDataSource(widget.datasource);
    setState(() {});
  }

  void setDataSource(String datasource) {
    controller.pause();
    controller.open(
      Media.directShow(rawUrl: widget.datasource),
      autoStart: true,
    );
  }

  void fullScreenBuilder(BuildContext context, bool isFullScreen) {
    if (!isFullScreen) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(
              alignment: Alignment.center,
              color: Colors.black,
              child: Hero(
                tag: widget.datasource,
                child: Stack(children: [
                  Video(
                    player: controller,
                    scale: 1.0, // default
                    showControls: false, // default
                  ),
                  DanmakuVideoController(
                    controller: controller,
                    danmakuStream: widget.danmakuStream,
                    fullScreenBuilder: fullScreenBuilder,
                    title: widget.room.title,
                    isFullScreen: true,
                  ),
                ]),
              ),
            ),
          ),
        ),
      );
      Timer(const Duration(seconds: 1), () {
        WindowManager.instance.setFullScreen(true);
      });
    } else {
      WindowManager.instance.setFullScreen(false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.datasource,
      child: Stack(
        children: [
          Video(
            key: _playerKey,
            player: controller,
            scale: 1.0, // default
            showControls: false, // default
          ),
          DanmakuVideoController(
            key: _danmakuNormal,
            controller: controller,
            danmakuStream: widget.danmakuStream,
            fullScreenBuilder: fullScreenBuilder,
            title: widget.room.title,
            width: widget.width,
            height: widget.height,
          ),
        ],
      ),
    );
  }
}
