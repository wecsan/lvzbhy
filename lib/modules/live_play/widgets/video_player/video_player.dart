import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:get/get.dart';
import 'package:pure_live/common/index.dart';
import 'package:pure_live/modules/live_play/widgets/video_player/video_controller.dart';
import 'package:pure_live/modules/live_play/widgets/video_player/video_controller_panel.dart';

import 'video_player_provider.dart';

class VideoPlayer extends StatefulWidget {
  final VideoController controller;

  const VideoPlayer({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  @override
  void initState() {
    super.initState();
    widget.controller.controllerProvider = VideoPlayerProvider(
      controller: widget.controller,
      child: _buildPlayer(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Widget _buildVideoFrame() {
    if (Platform.isWindows || Platform.isLinux) {
      return Obx(() => Video(
            key: Key("${widget.controller.hashCode}_video"),
            player: widget.controller.desktopController,
            scale: 1.0, // default
            showControls: false, // default
            fit: widget.controller.videoFit.value,
          ));
    } else {
      return BetterPlayer(
        key: Key("${widget.controller.hashCode}_video"),
        controller: widget.controller.mobileController!,
      );
    }
  }

  Widget _buildVideoPanel() {
    return VideoControllerPanel(
      key: Key("${widget.controller.hashCode}_danmaku"),
      controller: widget.controller,
    );
  }

  Widget _buildPlayer() {
    return Stack(
      children: [
        _buildVideoFrame(),
        _buildVideoPanel(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildPlayer();
  }
}
