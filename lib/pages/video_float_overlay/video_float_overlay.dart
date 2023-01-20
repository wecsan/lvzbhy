import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class VideoFloatOverlay extends StatefulWidget {
  const VideoFloatOverlay({Key? key}) : super(key: key);

  @override
  State<VideoFloatOverlay> createState() => VideoFloatOverlayState();
}

class VideoFloatOverlayState extends State<VideoFloatOverlay> {
  BetterPlayerController? controller;
  Widget? damakuVideoControls;

  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {
      controller?.pause();
      controller?.dispose();
      controller = null;

      String url = event['url'];
      controller = BetterPlayerController(
        const BetterPlayerConfiguration(
          autoPlay: true,
          fit: BoxFit.contain,
          allowedScreenSleep: true,
        ),
        betterPlayerDataSource: BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          url,
          liveStream: true,
        ),
      );
      controller?.setControlsEnabled(false);
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.pause();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(8),
        child: Stack(
          children: [
            controller != null
                ? BetterPlayer(controller: controller!)
                : const Center(child: CircularProgressIndicator()),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () async {
                  await FlutterOverlayWindow.closeOverlay();
                  controller?.pause();
                  controller?.dispose();
                  controller = null;
                },
                icon: Icon(
                  Icons.close_rounded,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
