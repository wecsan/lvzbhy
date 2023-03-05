import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:pure_live/common/index.dart';
import 'package:pure_live/modules/live_play/widgets/video_player/video_controller.dart';
import 'package:pure_live/modules/live_play/widgets/video_player/video_controller_panel.dart';

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
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  final _playerKey = GlobalKey();
  final _danmakuNormal = GlobalKey();

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
          controller: widget.controller,
          width: widget.width,
          height: widget.height,
        ),
      ],
    );
  }
}
