import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barrage/flutter_barrage.dart';
import 'package:flutter_screen_wake/flutter_screen_wake.dart';
import 'package:hot_live/api/danmaku/danmaku_stream.dart';
import 'package:hot_live/model/danmaku.dart';
import 'package:hot_live/provider/settings_provider.dart';
import 'package:hot_live/widgets/custom_icons.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class DanmakuText extends StatelessWidget {
  const DanmakuText({Key? key, required this.message}) : super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    SettingsProvider settings = Provider.of<SettingsProvider>(context);

    return Text(
      message,
      style: TextStyle(
        fontSize: settings.danmakuFontSize,
        fontWeight: FontWeight.w400,
        color: Colors.white.withOpacity(settings.danmakuOpcity),
      ),
    );
  }
}

class DanmakuChewieController extends StatefulWidget {
  const DanmakuChewieController({Key? key, required this.danmakuStream})
      : super(key: key);

  final DanmakuStream danmakuStream;

  @override
  State<StatefulWidget> createState() {
    return _DanmakuChewieControllerState();
  }
}

class _DanmakuChewieControllerState extends State<DanmakuChewieController>
    with SingleTickerProviderStateMixin {
  late VideoPlayerValue _latestValue;

  final barHeight = 56.0;
  final marginSize = 5.0;

  double? _latestVolume;

  // ignore: prefer_final_fields
  bool _hideStuff = true;
  bool _hideDanmaku = false;
  bool _displayTapped = false;
  bool _displayDanmakuSetting = false;
  bool _displayBufferingIndicator = false;

  Timer? _hideTimer;
  Timer? _initTimer;
  Timer? _showAfterExpandCollapseTimer;
  Timer? _bufferingDisplayTimer;

  // 滑动调节控制
  bool _dragging = false;
  double? updatePrevDx;
  double? updatePrevDy;
  int? updatePosX;
  bool? isDargVerLeft;
  double? updateDargVarVal;

  late VideoPlayerController controller;
  ChewieController? _chewieController;
  BarrageWallController barrageWallController = BarrageWallController();
  late SettingsProvider settings = Provider.of<SettingsProvider>(context);

  // We know that _chewieController is set in didChangeDependencies
  ChewieController get chewieController => _chewieController!;

  @override
  void initState() {
    widget.danmakuStream.listen(sendDanmaku);
    super.initState();
  }

  void sendDanmaku(DanmakuInfo info) {
    barrageWallController.send([Bullet(child: DanmakuText(message: info.msg))]);
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
              _buildDanmakuView(),
              _displayBufferingIndicator
                  ? const Center(child: CircularProgressIndicator())
                  : _buildHitArea(),
              _buildActionBar(),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[_buildBottomBar()],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDanmakuView() {
    double danmukuHeight =
        MediaQuery.of(context).size.height * settings.danmakuArea;
    double danmakuOpacity = !_hideDanmaku ? 1 : 0.0;
    if (!chewieController.isFullScreen) {
      danmukuHeight =
          (MediaQuery.of(context).size.width / 16 * 9) * settings.danmakuArea;
    }

    return Positioned(
      top: 4,
      width: MediaQuery.of(context).size.width,
      height: danmukuHeight,
      child: AnimatedOpacity(
        opacity: danmakuOpacity,
        duration: const Duration(milliseconds: 300),
        child: BarrageWall(
          width: MediaQuery.of(context).size.width,
          height: danmukuHeight,
          speed: settings.danmakuSpeed.toInt(),
          controller: barrageWallController,
          massiveMode: false,
          safeBottomHeight: settings.danmakuFontSize.toInt(),
          child: Container(),
        ),
      ),
    );
  }

  // Contoller view components
  Widget _buildHitArea() {
    Widget centerArea;
    if (_displayDanmakuSetting) {
      centerArea = _buildDanmakuSettingView();
    } else if (_dragging) {
      centerArea = _buildDargVolumeAndBrightness();
    } else {
      centerArea = _buildCenterPlayButton();
    }

    return GestureDetector(
      onTap: () {
        if (_displayDanmakuSetting) {
          setState(() {
            _displayDanmakuSetting = false;
          });
        } else if (_latestValue.isPlaying) {
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
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      child: Container(
        color: Colors.transparent,
        child: centerArea,
      ),
    );
  }

  Widget _buildCenterPlayButton() {
    return Container(
      alignment: Alignment.center,
      child: AnimatedOpacity(
        opacity: !_latestValue.isPlaying && !_dragging ? 0.3 : 0.0,
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
    );
  }

  Widget _buildDargVolumeAndBrightness() {
    IconData iconData = Icons.volume_up;

    if (_dragging) {
      if (updateDargVarVal! <= 0) {
        iconData = !isDargVerLeft! ? Icons.volume_mute : Icons.brightness_low;
      } else if (updateDargVarVal! < 0.5) {
        iconData =
            !isDargVerLeft! ? Icons.volume_down : Icons.brightness_medium;
      } else {
        iconData = !isDargVerLeft! ? Icons.volume_up : Icons.brightness_high;
      }
    }

    return Container(
      alignment: Alignment.center,
      child: AnimatedOpacity(
        opacity: _dragging ? 0.8 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Card(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(iconData, color: Colors.white),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 100,
                      height: 20,
                      child: LinearProgressIndicator(
                        value: updateDargVarVal,
                        backgroundColor: Colors.white38,
                        valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).progressIndicatorTheme.color,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDanmakuSettingView() {
    const double opacity = 0.8;
    SettingsProvider settings = Provider.of<SettingsProvider>(context);

    final Color fontColor = Colors.white.withOpacity(opacity);
    final TextStyle labelStyle =
        Theme.of(context).textTheme.labelMedium?.copyWith(color: fontColor) ??
            TextStyle(color: fontColor);
    final TextStyle digitStyle =
        Theme.of(context).textTheme.caption?.copyWith(color: fontColor) ??
            TextStyle(color: fontColor);

    return Container(
      alignment: Alignment.center,
      child: AnimatedOpacity(
        opacity: _displayDanmakuSetting ? 0.8 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Card(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  leading: Text('显示区域', style: labelStyle),
                  title: Slider(
                    value: settings.danmakuArea,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (val) => settings.danmakuArea = val,
                  ),
                  trailing: Text(
                    (settings.danmakuArea * 100).toInt().toString() + '%',
                    style: digitStyle,
                  ),
                ),
                ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  leading: Text('不透明度', style: labelStyle),
                  title: Slider(
                    value: settings.danmakuOpcity,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (val) => settings.danmakuOpcity = val,
                  ),
                  trailing: Text(
                    (settings.danmakuOpcity * 100).toInt().toString() + '%',
                    style: digitStyle,
                  ),
                ),
                ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  leading: Text('弹幕速度', style: labelStyle),
                  title: Slider(
                    value: settings.danmakuSpeed,
                    min: 1.0,
                    max: 20.0,
                    onChanged: (val) => settings.danmakuSpeed = val,
                  ),
                  trailing: Text(
                    settings.danmakuSpeed.toInt().toString(),
                    style: digitStyle,
                  ),
                ),
                ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  leading: Text('弹幕字号', style: labelStyle),
                  title: Slider(
                    value: settings.danmakuFontSize,
                    min: 10.0,
                    max: 30.0,
                    onChanged: (val) => settings.danmakuFontSize = val,
                  ),
                  trailing: Text(
                    settings.danmakuFontSize.toInt().toString(),
                    style: digitStyle,
                  ),
                ),
              ],
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

  Widget _buildBackButton() {
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

  Widget _buildBottomBar() {
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

  Widget _buildPlayPauseButton() {
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

  Widget _buildMuteButton() {
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

  Widget _buildDanmakuHideButton() {
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

  Widget _buildDanmakuSettingButton() {
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

  Widget _buildExpandButton() {
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

  void _onVerticalDragStart(detills) async {
    double clientW = MediaQuery.of(context).size.width;
    double curTouchPosX = detills.globalPosition.dx;

    setState(() {
      // 更新位置
      updatePrevDy = detills.globalPosition.dy;
      // 是否左边
      isDargVerLeft = (curTouchPosX > (clientW / 2)) ? false : true;
    });
    // 大于 右边 音量 ， 小于 左边 亮度
    if (!isDargVerLeft!) {
      // 音量
      _dragging = true;
      setState(() {
        updateDargVarVal = controller.value.volume;
      });
    } else {
      // 亮度
      await FlutterScreenWake.brightness.then((double v) {
        _dragging = true;
        setState(() {
          updateDargVarVal = v;
        });
      });
    }
  }

  void _onVerticalDragUpdate(detills) {
    if (!_dragging) return;
    double curDragDy = detills.globalPosition.dy;
    // 确定当前是前进或者后退
    int cdy = curDragDy.toInt();
    int pdy = updatePrevDy!.toInt();
    bool isBefore = cdy < pdy;
    // + -, 不满足, 上下滑动合法滑动值，> 3
    if (isBefore && pdy - cdy < 3 || !isBefore && cdy - pdy < 3) return;
    // 区间
    double dragRange =
        isBefore ? updateDargVarVal! + 0.03 : updateDargVarVal! - 0.03;
    // 是否溢出
    if (dragRange > 1) {
      dragRange = 1.0;
    }
    if (dragRange < 0) {
      dragRange = 0.0;
    }
    setState(() {
      updatePrevDy = curDragDy;
      _dragging = true;
      updateDargVarVal = dragRange;
      // 音量
      if (!isDargVerLeft!) {
        controller.setVolume(dragRange);
      } else {
        FlutterScreenWake.setBrightness(dragRange);
      }
    });
  }

  void _onVerticalDragEnd(detills) {
    setState(() {
      _dragging = false;
    });
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
    setState(() {
      _displayDanmakuSetting = !_displayDanmakuSetting;
    });
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
