import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:hot_live/api/danmaku/danmaku_stream.dart';
import 'package:hot_live/pages/live_play/danmaku_video_controller.dart';
import 'package:video_player/video_player.dart';

class DanmakuVideoPlayer extends StatefulWidget {
  final String url;
  final String title;
  final bool allowBackgroundPlay;
  final DanmakuStream danmakuStream;

  const DanmakuVideoPlayer({
    Key? key,
    required this.url,
    required this.danmakuStream,
    this.title = '',
    this.allowBackgroundPlay = false,
  }) : super(key: key);

  @override
  State<DanmakuVideoPlayer> createState() => DanmakuVideoPlayerState();
}

class DanmakuVideoPlayerState extends State<DanmakuVideoPlayer> {
  VideoPlayerController? videoController;
  ChewieController? chewieController;
  DanmakuVideoController? danmakuChewieController;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    danmakuChewieController = DanmakuVideoController(
      danmakuStream: widget.danmakuStream,
      title: widget.title,
    );
    setDataSource(widget.url);
  }

  @override
  void dispose() {
    chewieController?.dispose();
    videoController?.dispose();
    super.dispose();
  }

  void setDataSource(String url) {
    setState(() => loading = true);
    videoController?.dispose();
    videoController = VideoPlayerController.network(url,
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: widget.allowBackgroundPlay,
        ))
      ..initialize().then((_) {
        chewieController?.dispose();
        chewieController = ChewieController(
          videoPlayerController: videoController!,
          customControls: danmakuChewieController!,
          aspectRatio: videoController!.value.aspectRatio,
          autoPlay: true,
          isLive: true,
        );
        videoController?.setVolume(1.0);
        setState(() => loading = false);
      });
  }

  void play() {
    videoController?.play();
  }

  void pause() {
    videoController?.pause();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : Chewie(controller: chewieController!);
  }
}
