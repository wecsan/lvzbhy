import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:hot_live/common/index.dart';

import './danmaku_video_controller.dart';

class DesktopDanmakuVideoPlayer extends StatefulWidget {
  final DanmakuStream danmakuStream;
  final RoomInfo room;
  final String datasource;
  final bool fullScreenByDefault;
  final bool allowBackgroundPlay;
  final bool allowedScreenSleep;
  final double? width;

  const DesktopDanmakuVideoPlayer({
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
  State<DesktopDanmakuVideoPlayer> createState() =>
      DesktopDanmakuVideoPlayerState();
}

class DesktopDanmakuVideoPlayerState extends State<DesktopDanmakuVideoPlayer> {
  late MeeduPlayerController controller;
  final screenManager = const ScreenManager();
  final _playerKey = GlobalKey();
  final _danmakuNormal = GlobalKey();

  bool _hasError = false;

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
    controller = MeeduPlayerController(
      screenManager: screenManager,
      controlsEnabled: false,
    );
    controller.onVideoFitChange(BoxFit.contain);
    setDataSource(widget.datasource);
    controller.onDataStatusChanged.listen(((event) {
      setState(() => _hasError = event == DataStatus.error);
    }));
    setState(() {});
  }

  void setDataSource(String datasource) {
    controller.setDataSource(
      DataSource(type: DataSourceType.network, source: datasource),
      autoplay: true,
    );
  }

  Widget errorBuilder() {
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
    if (_hasError) {
      return errorBuilder();
    }

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: MeeduVideoPlayer(
            key: _playerKey,
            controller: controller,
          ),
        ),
        DanmakuVideoController(
          key: _danmakuNormal,
          controller: controller,
          danmakuStream: widget.danmakuStream,
          title: widget.room.title,
          width: widget.width,
        ),
      ],
    );
  }
}
