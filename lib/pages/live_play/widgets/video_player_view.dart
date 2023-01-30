import 'dart:io';

import 'package:hot_live/common/index.dart';
import 'package:hot_live/pages/live_play/widgets/desktop_player/danmaku_video_player.dart';
import 'package:hot_live/pages/live_play/widgets/mobile_player/danmaku_video_player.dart';

class VideoPlayerView extends StatefulWidget {
  final DanmakuStream danmakuStream;
  final RoomInfo room;
  final String datasource;
  final bool fullScreenByDefault;
  final bool allowBackgroundPlay;
  final bool allowedScreenSleep;
  final double? width;

  const VideoPlayerView({
    Key? key,
    required this.danmakuStream,
    required this.room,
    required this.datasource,
    required this.fullScreenByDefault,
    required this.allowBackgroundPlay,
    required this.allowedScreenSleep,
    this.width,
  }) : super(key: key);

  @override
  State<VideoPlayerView> createState() => VideoPlayerViewState();
}

class VideoPlayerViewState extends State<VideoPlayerView> {
  final GlobalKey<DesktopDanmakuVideoPlayerState> _desktopKey = GlobalKey();
  final GlobalKey<MobileDanmakuVideoPlayerState> _mobileKey = GlobalKey();

  void setDataSource(String datasouce) {
    if (Platform.isWindows || Platform.isLinux) {
      _desktopKey.currentState?.setDataSource(datasouce);
    } else if (Platform.isAndroid || Platform.isIOS) {
      _mobileKey.currentState?.setDataSource(datasouce);
    }
    throw UnimplementedError('Unspported Platform');
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows || Platform.isLinux) {
      return DesktopDanmakuVideoPlayer(
        key: _desktopKey,
        danmakuStream: widget.danmakuStream,
        room: widget.room,
        datasource: widget.datasource,
        fullScreenByDefault: widget.fullScreenByDefault,
        allowBackgroundPlay: widget.allowBackgroundPlay,
        allowedScreenSleep: widget.allowedScreenSleep,
        width: widget.width,
      );
    } else if (Platform.isAndroid || Platform.isIOS) {
      return MobileDanmakuVideoPlayer(
        key: _mobileKey,
        danmakuStream: widget.danmakuStream,
        room: widget.room,
        datasource: widget.datasource,
        fullScreenByDefault: widget.fullScreenByDefault,
        allowBackgroundPlay: widget.allowBackgroundPlay,
        allowedScreenSleep: widget.allowedScreenSleep,
        width: widget.width,
      );
    }
    throw UnimplementedError('Unspported Platform');
  }
}
