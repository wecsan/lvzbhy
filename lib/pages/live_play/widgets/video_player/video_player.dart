import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:hot_live/common/index.dart';
import 'package:hot_live/pages/live_play/widgets/video_player/video_controller.dart';
import 'package:hot_live/pages/live_play/widgets/video_player/video_controller_panel.dart';

class VideoPlayer extends StatefulWidget {
  final VideoController controller;
  final double? width;
  final double? height;

  const VideoPlayer({
    Key? key,
    required this.controller,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<VideoPlayer> createState() => VideoPlayerState();
}

class VideoPlayerState extends State<VideoPlayer> {
  final _playerKey = GlobalKey();
  final _danmakuNormal = GlobalKey();
  final _danmakuFullScreen = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows || Platform.isLinux) {
      widget.controller.setDesktopFullscreenBuilder(((context) {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => Scaffold(
              resizeToAvoidBottomInset: false,
              body: Container(
                alignment: Alignment.center,
                color: Colors.black,
                child: Hero(
                  tag: widget.controller.datasource,
                  child: Stack(children: [
                    videoFrame,
                    VideoControllerPanel(
                      key: _danmakuFullScreen,
                      playerKey: _playerKey,
                      controller: widget.controller,
                    ),
                  ]),
                ),
              ),
            ),
          ),
        );
      }));
    } else {
      widget.controller.setMobileFullscreenBuilder(
        (context, animation, second, controllerProvider) {
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
                    VideoControllerPanel(
                      key: _danmakuFullScreen,
                      playerKey: _playerKey,
                      controller: widget.controller,
                    ),
                  ]),
                ),
              );
            },
          );
        },
      );
    }
  }

  Widget get videoFrame {
    if (Platform.isWindows || Platform.isLinux) {
      return Video(
        player: widget.controller.desktopController,
        scale: 1.0, // default
        showControls: false, // default
      );
    } else {
      return BetterPlayer(
        key: _playerKey,
        controller: widget.controller.mobileController!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        videoFrame,
        VideoControllerPanel(
          key: _danmakuNormal,
          playerKey: _playerKey,
          controller: widget.controller,
          width: widget.width,
          height: widget.height,
        ),
      ],
    );
  }
}
