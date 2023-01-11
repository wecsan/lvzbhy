import 'dart:async';

import 'package:chewie/chewie.dart';
// ignore: implementation_imports
import 'package:chewie/src/material/material_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barrage/flutter_barrage.dart';
import 'package:video_player/video_player.dart';

class MyChewieMaterialControls extends StatefulWidget {
  const MyChewieMaterialControls({Key? key, required this.barrageController})
      : super(key: key);

  final BarrageWallController barrageController;

  @override
  State<StatefulWidget> createState() {
    return _MyChewieMaterialControlsState();
  }
}

class _MyChewieMaterialControlsState extends State<MyChewieMaterialControls>
    with SingleTickerProviderStateMixin {
  late VideoPlayerValue _latestValue;
  bool _hideStuff = true;
  double? _latestVolume;
  Timer? _hideTimer;
  Timer? _initTimer;
  Timer? _showAfterExpandCollapseTimer;
  bool _dragging = false;
  bool _displayTapped = false;

  final barHeight = 48.0;
  final marginSize = 5.0;

  late VideoPlayerController controller;
  ChewieController? _chewieController;

  // We know that _chewieController is set in didChangeDependencies
  ChewieController get chewieController => _chewieController!;

  @override
  Widget build(BuildContext context) {
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

    double danmukuHeight = MediaQuery.of(context).size.width *
        MediaQuery.of(context).size.aspectRatio /
        5.0 *
        4.0;
    if (chewieController.isFullScreen) {
      danmukuHeight = MediaQuery.of(context).size.height / 3.0;
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
              Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      !_latestValue.isPlaying && _latestValue.isBuffering
                          ? const Expanded(
                              child: Center(
                              child: CircularProgressIndicator(),
                            ))
                          : _buildHitArea(),
                      _buildBottomBar(context),
                    ],
                  ),
                  Positioned(
                    top: 4,
                    width: MediaQuery.of(context).size.width,
                    height: danmukuHeight,
                    child: BarrageWall(
                      controller: widget.barrageController,
                      massiveMode: false,
                      child: Container(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  AnimatedOpacity _buildBottomBar(BuildContext context) {
    final iconColor = Theme.of(context).textTheme.button?.color ?? Colors.grey;
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
            _buildPlayPause(controller),
            chewieController.isLive ? const SizedBox() : _buildProgressBar(),
            chewieController.isLive
                ? const Expanded(
                    child: Text('Live', style: TextStyle(color: Colors.white)),
                  )
                : _buildPosition(iconColor),
            _buildMuteButton(controller),
            chewieController.allowFullScreen
                ? _buildExpandButton()
                : Container(),
          ],
        ),
      ),
    );
  }

  GestureDetector _buildExpandButton() {
    return GestureDetector(
      onTap: _onExpandCollapse,
      child: AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          height: barHeight,
          margin: const EdgeInsets.only(right: 12.0),
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
          ),
          child: Center(
            child: Icon(
              chewieController.isFullScreen
                  ? Icons.fullscreen_exit
                  : Icons.fullscreen,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Expanded _buildHitArea() {
    return Expanded(
      child: GestureDetector(
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
            setState(() {
              _hideStuff = true;
            });
          }
        },
        onDoubleTap: () {
          _playPause();
        },
        child: Container(
          color: Colors.transparent,
          child: Container(
            alignment: Alignment.bottomRight,
            child: AnimatedOpacity(
              opacity: !_latestValue.isPlaying && !_dragging ? 0.8 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: GestureDetector(
                  onTap: () {
                    _playPause();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10, right: 10),
                    decoration: const BoxDecoration(
                      boxShadow: <BoxShadow>[
                        BoxShadow(color: Colors.black54, blurRadius: 20),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      size: 40.0,
                      color: Colors.white,
                    ),
                  )),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildMuteButton(VideoPlayerController controller) {
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
      child: AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: ClipRect(
          child: Container(
            height: barHeight,
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Icon(
              (_latestValue.volume > 0) ? Icons.volume_up : Icons.volume_off,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildPlayPause(VideoPlayerController controller) {
    return GestureDetector(
      onTap: _playPause,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        margin: const EdgeInsets.only(left: 8.0, right: 4.0),
        padding: const EdgeInsets.only(
          left: 12.0,
          right: 12.0,
        ),
        child: Icon(
          controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
        ),
      ),
    );
  }

  String _formatDuration(Duration dur) {
    return '${dur.inHours}:${dur.inMinutes}:${dur.inSeconds}';
  }

  Widget _buildPosition(Color iconColor) {
    final position = _latestValue.position;
    final duration = _latestValue.duration;

    return Padding(
      padding: const EdgeInsets.only(right: 24.0),
      child: Text(
        '${_formatDuration(position)} / ${_formatDuration(duration)} ',
        style: const TextStyle(fontSize: 14.0, color: Colors.white),
      ),
    );
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();

    setState(() {
      _hideStuff = false;
      _displayTapped = true;
    });
  }

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
            controller.seekTo(const Duration(seconds: 0));
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

  void _updateState() {
    setState(() {
      _latestValue = controller.value;
    });
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: MaterialVideoProgressBar(controller, onDragStart: () {
          setState(() {
            _dragging = true;
          });

          _hideTimer?.cancel();
        }, onDragEnd: () {
          setState(() {
            _dragging = false;
          });

          _startHideTimer();
        },
            colors: ChewieProgressColors(
              playedColor: Theme.of(context).primaryColor,
              handleColor: Colors.white,
              bufferedColor: Colors.white70,
              backgroundColor: Colors.white30,
            )),
      ),
    );
  }
}
