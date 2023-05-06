import 'package:flutter/material.dart';

import 'video_controller.dart';

///Widget which is used to inherit BetterPlayerController through widget tree.
class VideoPlayerProvider extends InheritedWidget {
  const VideoPlayerProvider({
    Key? key,
    required this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  final VideoController controller;

  @override
  bool updateShouldNotify(VideoPlayerProvider oldWidget) =>
      controller != oldWidget.controller;
}
