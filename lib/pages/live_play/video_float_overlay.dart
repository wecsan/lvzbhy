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
  bool showPlayer = false;

  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {
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
      setState(() => showPlayer = true);
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
            showPlayer
                ? BetterPlayer(controller: controller!)
                : const Center(child: CircularProgressIndicator()),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () async {
                  controller?.pause();
                  controller?.dispose();
                  controller = null;
                  setState(() => showPlayer = false);
                  await FlutterOverlayWindow.closeOverlay();
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
