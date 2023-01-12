import 'dart:async';
import 'dart:math';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barrage/flutter_barrage.dart';
import 'package:ice_live_viewer/pages/live_play/danmaku_setting_view.dart';
import 'package:ice_live_viewer/provider/settings_provider.dart';
import 'package:ice_live_viewer/widgets/custom_icons.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class DanmakuChewieControllers extends StatefulWidget {
  const DanmakuChewieControllers({Key? key, required this.danmakuContoller})
      : super(key: key);

  final BarrageWallController danmakuContoller;

  @override
  State<StatefulWidget> createState() {
    return _DanmakuChewieControllersState();
  }
}

class _DanmakuChewieControllersState extends State<DanmakuChewieControllers>
    with SingleTickerProviderStateMixin {
  late VideoPlayerValue _latestValue;
  bool _hideStuff = true;
  bool _hideDanmaku = false;

  double? _latestVolume;
  Timer? _hideTimer;
  Timer? _initTimer;
  Timer? _showAfterExpandCollapseTimer;
  bool _dragging = false;
  bool _displayTapped = false;
  Timer? _bufferingDisplayTimer;
  bool _displayBufferingIndicator = false;

  final barHeight = 56.0;
  final marginSize = 5.0;

  late VideoPlayerController controller;
  ChewieController? _chewieController;

  // We know that _chewieController is set in didChangeDependencies
  ChewieController get chewieController => _chewieController!;

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    controller.removeListener(_updateState);
    _hideTimer?.cancel();
    _initTimer?.cancel();
    _showAfterExpandCollapseTimer?.cancel();
  }

  @override
  void didChangeDependencies() {
    final oldController = _chewieController;
    _chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;

    if (oldController != chewieController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  late SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    settings = Provider.of<SettingsProvider>(context);
    if (_latestValue.hasError) {
      return chewieController.errorBuilder?.call(
            context,
            chewieController.videoPlayerController.value.errorDescription!,
          ) ??
          const Center(
            child: Icon(
              Icons.error,
              color: Colors.white,
              size: 42,
            ),
          );
    }

    double danmukuHeight =
        MediaQuery.of(context).size.height * settings.danmakuArea;
    double danmakuOpacity = !_hideDanmaku ? 1 : 0.0;
    if (!chewieController.isFullScreen) {
      danmukuHeight =
          (MediaQuery.of(context).size.width / 16 * 9) * settings.danmakuArea;
    }

    return MouseRegion(
      onHover: (_) {
        _cancelAndRestartTimer();
      },
      child: GestureDetector(
        onTap: () => _cancelAndRestartTimer(),
        child: AbsorbPointer(
          absorbing: _hideStuff,
          child: Stack(
            children: [
              _displayBufferingIndicator
                  ? const Center(child: CircularProgressIndicator())
                  : _buildHitArea(),
              _buildActionBar(),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[_buildBottomBar()],
              ),
              Positioned(
                top: 0,
                width: MediaQuery.of(context).size.width,
                height: danmukuHeight,
                child: AnimatedOpacity(
                  opacity: danmakuOpacity,
                  duration: const Duration(milliseconds: 300),
                  child: BarrageWall(
                    width: MediaQuery.of(context).size.width,
                    height: danmukuHeight,
                    speed: settings.danmakuSpeed.toInt(),
                    controller: widget.danmakuContoller,
                    massiveMode: false,
                    safeBottomHeight: settings.danmakuFontSize.toInt(),
                    child: Container(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Contoller view components
  Widget _buildHitArea() {
    final bool showPlayButton = !_latestValue.isPlaying && !_dragging;

    return GestureDetector(
      onTap: () {
        if (_latestValue.isPlaying) {
          if (_displayTapped) {
            setState(() {
              _hideStuff = true;
            });
          } else {
            _cancelAndRestartTimer();
          }
        } else {
          _playPause();

          setState(() {
            _hideStuff = true;
          });
        }
      },
      onDoubleTap: _playPause,
      child: Container(
        color: Colors.transparent,
        child: Container(
          alignment: Alignment.center,
          child: AnimatedOpacity(
            opacity: showPlayButton ? 0.3 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: GestureDetector(
              onTap: _playPause,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10, right: 10),
                decoration: const BoxDecoration(
                  boxShadow: <BoxShadow>[
                    BoxShadow(color: Colors.black54, blurRadius: 20),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 50.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    return Positioned(
      top: 0,
      height: barHeight,
      width: MediaQuery.of(context).size.width,
      child: SafeArea(
        child: AnimatedOpacity(
          opacity: _hideStuff ? 0.0 : 1,
          duration: const Duration(milliseconds: 300),
          child: Container(
            height: barHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color.fromRGBO(0, 0, 0, 0.02), Colors.black]),
            ),
            child: chewieController.isFullScreen
                ? Row(
                    children: <Widget>[
                      _buildBackButton(),
                    ],
                  )
                : null,
          ),
        ),
      ),
    );
  }

  AnimatedOpacity _buildBottomBar() {
    return AnimatedOpacity(
      opacity: _hideStuff ? 0.0 : 1,
      duration: const Duration(milliseconds: 300),
      child: Container(
        height: barHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color.fromRGBO(0, 0, 0, 0.02), Colors.black]),
        ),
        child: Row(
          children: <Widget>[
            _buildPlayPauseButton(),
            _buildMuteButton(),
            _buildDanmakuHideButton(),
            if (chewieController.isFullScreen) _buildDanmakuSettingButton(),
            const Spacer(),
            if (chewieController.allowFullScreen) _buildExpandButton(),
          ],
        ),
      ),
    );
  }

  GestureDetector _buildDanmakuHideButton() {
    return GestureDetector(
      onTap: _onDanmakuHide,
      child: Container(
        height: barHeight,
        margin: const EdgeInsets.only(right: 12.0),
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Center(
          child: Icon(
            _hideDanmaku ? CustomIcons.danmaku_close : CustomIcons.danmaku_open,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  GestureDetector _buildDanmakuSettingButton() {
    return GestureDetector(
      onTap: _onDanmakuSetting,
      child: Container(
        height: barHeight,
        margin: const EdgeInsets.only(right: 12.0),
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: const Center(
          child: Icon(
            CustomIcons.danmaku_setting,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  GestureDetector _buildMuteButton() {
    return GestureDetector(
      onTap: () {
        _cancelAndRestartTimer();

        if (_latestValue.volume == 0) {
          controller.setVolume(_latestVolume ?? 0.5);
        } else {
          _latestVolume = controller.value.volume;
          controller.setVolume(0.0);
        }
      },
      child: Container(
        height: barHeight,
        margin: const EdgeInsets.only(right: 12.0),
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Icon(
          _latestValue.volume > 0 ? Icons.volume_up : Icons.volume_off,
          color: Colors.white,
        ),
      ),
    );
  }

  GestureDetector _buildExpandButton() {
    return GestureDetector(
      onTap: _onExpandCollapse,
      child: Container(
        height: barHeight,
        margin: const EdgeInsets.only(right: 12.0),
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Center(
          child: Icon(
            chewieController.isFullScreen
                ? Icons.fullscreen_exit_rounded
                : Icons.fullscreen_rounded,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  GestureDetector _buildBackButton() {
    return GestureDetector(
      onTap: _onExpandCollapse,
      child: Container(
        height: barHeight,
        margin: const EdgeInsets.only(right: 12.0),
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: const Center(
          child: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  GestureDetector _buildPlayPauseButton() {
    return GestureDetector(
      onTap: _playPause,
      child: Container(
        height: barHeight,
        margin: const EdgeInsets.only(right: 12.0),
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Center(
          child: Icon(
            controller.value.isPlaying
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Callback functions
  Future<void> _initialize() async {
    controller.addListener(_updateState);

    _updateState();

    if ((controller.value.isPlaying) || chewieController.autoPlay) {
      _startHideTimer();
    }

    if (chewieController.showControlsOnInitialize) {
      _initTimer = Timer(const Duration(milliseconds: 200), () {
        setState(() {
          _hideStuff = false;
        });
      });
    }
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();

    setState(() {
      _hideStuff = false;
      _displayTapped = true;
    });
  }

  void _onDanmakuHide() {
    setState(() {
      _hideDanmaku = !_hideDanmaku;
    });
  }

  void _onDanmakuSetting() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => const DanmakuSettingView(),
    );
  }

  void _onExpandCollapse() {
    setState(() {
      _hideStuff = true;

      chewieController.toggleFullScreen();
      _showAfterExpandCollapseTimer =
          Timer(const Duration(milliseconds: 300), () {
        setState(() {
          _cancelAndRestartTimer();
        });
      });
    });
  }

  void _playPause() {
    bool isFinished = _latestValue.position >= _latestValue.duration;

    setState(() {
      if (controller.value.isPlaying) {
        _hideStuff = false;
        _hideTimer?.cancel();
        controller.pause();
      } else {
        _cancelAndRestartTimer();

        if (!controller.value.isInitialized) {
          controller.initialize().then((_) {
            controller.play();
          });
        } else {
          if (isFinished) {
            controller.seekTo(Duration.zero);
          }
          controller.play();
        }
      }
    });
  }

  void _startHideTimer() {
    _hideTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _hideStuff = true;
      });
    });
  }

  void _bufferingTimerTimeout() {
    _displayBufferingIndicator = true;
    if (mounted) {
      setState(() {});
    }
  }

  void _updateState() {
    if (!mounted) return;

    // display the progress bar indicator only after the buffering delay if it has been set
    if (chewieController.progressIndicatorDelay != null) {
      if (controller.value.isBuffering) {
        _bufferingDisplayTimer ??= Timer(
          chewieController.progressIndicatorDelay!,
          _bufferingTimerTimeout,
        );
      } else {
        _bufferingDisplayTimer?.cancel();
        _bufferingDisplayTimer = null;
        _displayBufferingIndicator = false;
      }
    } else {
      _displayBufferingIndicator = controller.value.isBuffering;
    }

    setState(() {
      _latestValue = controller.value;
    });
  }
}
