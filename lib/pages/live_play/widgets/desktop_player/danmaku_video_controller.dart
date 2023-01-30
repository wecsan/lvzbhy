import 'dart:async';
import 'dart:math';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_barrage/flutter_barrage.dart';
import 'package:hot_live/common/index.dart';

class DanmakuText extends StatelessWidget {
  const DanmakuText({Key? key, required this.message}) : super(key: key);

  final String message;
  static const Color borderColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    SettingsProvider settings = Provider.of<SettingsProvider>(context);

    Widget cur = Text(
      message,
      maxLines: 1,
      style: TextStyle(
        fontSize: settings.danmakuFontSize,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
    );

    // setting text border
    if (settings.danmakuFontBorder > 0) {
      cur = Stack(
        children: [
          Text(
            message,
            maxLines: 1,
            style: TextStyle(
              fontSize: settings.danmakuFontSize,
              fontWeight: FontWeight.w400,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = settings.danmakuFontBorder
                ..color = borderColor,
            ),
          ),
          cur,
        ],
      );
    }

    return cur;
  }
}

class DanmakuVideoController extends StatefulWidget {
  final Player controller;
  final DanmakuStream danmakuStream;
  final void Function(BuildContext context, bool isFullScreen)
      fullScreenBuilder;
  final double? width;
  final double? height;
  final String title;
  final bool isFullScreen;

  const DanmakuVideoController({
    Key? key,
    required this.controller,
    required this.danmakuStream,
    required this.fullScreenBuilder,
    this.width,
    this.height,
    this.title = '',
    this.isFullScreen = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DanmakuVideoControllerState();
  }
}

class DanmakuVideoControllerState extends State<DanmakuVideoController>
    with SingleTickerProviderStateMixin {
  late double videoWidth;
  late double videoHeight;
  final barHeight = 56.0;
  final marginSize = 5.0;

  // Hide ui control
  bool _hideStuff = false;
  Timer? _hideTimer;
  bool _lockStuff = false;
  bool _displaySetting = false;

  // Darg bv ui control
  bool _hideBVStuff = true;
  Timer? _hideBVTimer;
  late double _updateDargVarVal = controller.general.volume;

  late final SettingsProvider settings = Provider.of<SettingsProvider>(context);
  final BarrageWallController barrageWallController = BarrageWallController();

  // We know that controller is set in didChangeDependencies
  Player get controller => widget.controller;
  bool get _isPlaying => controller.playback.isPlaying;
  bool get _isFullScreen => widget.isFullScreen;

  @override
  void initState() {
    super.initState();
    controller.setVolume(1.0);
    widget.danmakuStream.listen((info) {
      try {
        barrageWallController
            .send([Bullet(child: DanmakuText(message: info.msg))]);
      } catch (e) {
        return;
      }
    });
    _cancelAndRestartHideTimer();
  }

  @override
  void dispose() {
    barrageWallController.dispose();
    _hideTimer?.cancel();
    _hideBVTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    videoWidth = widget.width ?? MediaQuery.of(context).size.width;
    videoHeight = widget.height ?? MediaQuery.of(context).size.height;

    List<Widget> ws = [];
    ws.add(_buildDanmakuView());
    if (_displaySetting) {
      ws.add(_buildSettingView());
    } else {
      ws.add(_buildHitArea());
      ws.add(_buidLockStateButton());
      if (!_lockStuff) {
        ws.add(_buildActionBar());
        ws.add(_buildBottomBar());
      }
    }
    return MouseRegion(
      onHover: (event) {
        _hideTimer?.cancel();
        setState(() => _hideStuff = false);
      },
      onExit: (event) {
        _hideTimer?.cancel();
        setState(() => _hideStuff = true);
      },
      child: Stack(children: ws),
    );
  }

  // Danmaku widget
  Widget _buildDanmakuView() {
    return Positioned(
      top: 0,
      width: videoWidth,
      height: videoHeight * settings.danmakuArea,
      child: AnimatedOpacity(
        opacity: !settings.hideDanmaku ? settings.danmakuOpacity : 0.0,
        duration: const Duration(milliseconds: 300),
        child: ClipRect(
          clipBehavior: Clip.hardEdge,
          child: BarrageWall(
            width: videoWidth,
            height: videoHeight * settings.danmakuArea,
            speed: settings.danmakuSpeed.toInt(),
            controller: barrageWallController,
            massiveMode: true,
            maxBulletHeight: settings.danmakuFontSize * 1.25,
            safeBottomHeight: settings.danmakuFontSize.toInt(),
            child: Container(),
          ),
        ),
      ),
    );
  }

  // Center hit and controller widgets
  Widget _buildHitArea() {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) _onVerticalScrollUpdate(event);
      },
      child: GestureDetector(
        onDoubleTap: _toggleFullScreen,
        child: Container(
          color: Colors.transparent,
          child: _buildVolumeController(),
        ),
      ),
    );
  }

  Widget _buildVolumeController() {
    final iconData = _updateDargVarVal <= 0
        ? Icons.volume_mute
        : _updateDargVarVal < 0.5
            ? Icons.volume_down
            : Icons.volume_up;

    return Container(
      alignment: Alignment.center,
      child: AnimatedOpacity(
        opacity: !_hideBVStuff ? 0.8 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Card(
          color: Colors.black,
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
                        value: _updateDargVarVal,
                        backgroundColor: Colors.white38,
                        valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).indicatorColor,
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

  Widget _buidLockStateButton() {
    return AnimatedOpacity(
      opacity: !_hideStuff ? 0.9 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(right: 20.0),
          child: IconButton(
            iconSize: 28,
            onPressed: () {
              _cancelAndRestartHideTimer();
              setState(() => _lockStuff = !_lockStuff);
            },
            icon:
                Icon(_lockStuff ? Icons.lock_rounded : Icons.lock_open_rounded),
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingView() {
    SettingsProvider settings = Provider.of<SettingsProvider>(context);
    final isSelected = [false, false, false];
    isSelected[settings.playerFitMode] = true;

    const TextStyle label = TextStyle(color: Colors.white);
    const TextStyle digit = TextStyle(color: Colors.white);

    return GestureDetector(
      onTap: () {
        _cancelAndRestartHideTimer();
        if (_displaySetting) {
          setState(() => _displaySetting = false);
        }
      },
      child: Container(
        color: Colors.transparent,
        child: Container(
          alignment: Alignment.centerRight,
          child: AnimatedOpacity(
            opacity: _displaySetting ? 0.8 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: GestureDetector(
                onTap: () {},
                child: Card(
                  color: Colors.black,
                  child: SizedBox(
                    width: 380,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            '弹幕设置',
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Text(
                            S.of(context).settings_danmaku_area,
                            style: label,
                          ),
                          title: Slider(
                            value: settings.danmakuArea,
                            min: 0.0,
                            max: 1.0,
                            onChanged: (val) => settings.danmakuArea = val,
                          ),
                          trailing: Text(
                            (settings.danmakuArea * 100).toInt().toString() +
                                '%',
                            style: digit,
                          ),
                        ),
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Text(
                            S.of(context).settings_danmaku_opacity,
                            style: label,
                          ),
                          title: Slider(
                            value: settings.danmakuOpacity,
                            min: 0.0,
                            max: 1.0,
                            onChanged: (val) => settings.danmakuOpacity = val,
                          ),
                          trailing: Text(
                            (settings.danmakuOpacity * 100).toInt().toString() +
                                '%',
                            style: digit,
                          ),
                        ),
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Text(
                            S.of(context).settings_danmaku_speed,
                            style: label,
                          ),
                          title: Slider(
                            value: settings.danmakuSpeed,
                            min: 1.0,
                            max: 20.0,
                            onChanged: (val) => settings.danmakuSpeed = val,
                          ),
                          trailing: Text(
                            settings.danmakuSpeed.toInt().toString(),
                            style: digit,
                          ),
                        ),
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Text(
                            S.of(context).settings_danmaku_fontsize,
                            style: label,
                          ),
                          title: Slider(
                            value: settings.danmakuFontSize,
                            min: 10.0,
                            max: 30.0,
                            onChanged: (val) => settings.danmakuFontSize = val,
                          ),
                          trailing: Text(
                            settings.danmakuFontSize.toInt().toString(),
                            style: digit,
                          ),
                        ),
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Text(
                            S.of(context).settings_danmaku_fontBorder,
                            style: label,
                          ),
                          title: Slider(
                            value: settings.danmakuFontBorder,
                            min: 0.0,
                            max: 2.5,
                            onChanged: (val) =>
                                settings.danmakuFontBorder = val,
                          ),
                          trailing: Text(
                            settings.danmakuFontBorder.toStringAsFixed(2),
                            style: digit,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Action bar widgets
  Widget _buildActionBar() {
    List<Widget> rows = [];
    if (_isFullScreen) {
      rows = [
        _buildBackButton(),
        Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const Spacer(),
        _buildBatteryInfo(),
        _buildTimeInfo()
      ];
    } else {
      rows = [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              widget.title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ];
    }

    return Positioned(
      top: 0,
      height: barHeight,
      width: widget.width ?? videoWidth,
      child: AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1,
        duration: const Duration(milliseconds: 300),
        child: Container(
          height: barHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.transparent, Colors.black45]),
          ),
          child: Row(children: rows),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: _toggleFullScreen,
      child: Container(
        height: barHeight,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(right: 12.0),
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTimeInfo() {
    // get system time and format
    final dateTime = DateTime.now();
    var hour = dateTime.hour.toString();
    if (hour.length < 2) hour = '0$hour';
    var minute = dateTime.minute.toString();
    if (minute.length < 2) minute = '0$minute';

    return Container(
      height: barHeight,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(right: 12.0),
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Text(
        '$hour:$minute',
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Widget _buildBatteryInfo() {
    final batteryLevel = settings.batteryLevel;
    return Container(
      height: barHeight,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(right: 4.0),
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(1),
            child: SizedBox(
              width: 30,
              height: 15,
              child: LinearProgressIndicator(
                value: batteryLevel / 100.0,
                backgroundColor: Colors.white38,
                valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).indicatorColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$batteryLevel%',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Bottom bar widgets
  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      height: barHeight,
      width: widget.width ?? videoWidth,
      child: AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1,
        duration: const Duration(milliseconds: 300),
        child: Container(
          height: barHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black45]),
          ),
          child: Row(
            children: <Widget>[
              _buildPlayPauseButton(),
              _buildDanmakuHideButton(),
              _buildSettingButton(),
              const Spacer(),
              _buildExpandButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return GestureDetector(
      onTap: _playPause,
      child: Container(
        height: barHeight,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(right: 12.0),
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Icon(
          _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDanmakuHideButton() {
    return GestureDetector(
      onTap: () {
        setState(() => settings.hideDanmaku = !settings.hideDanmaku);
      },
      child: Container(
        height: barHeight,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(right: 12.0),
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Icon(
          settings.hideDanmaku
              ? CustomIcons.danmaku_close
              : CustomIcons.danmaku_open,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSettingButton() {
    return Center(
      child: GestureDetector(
        onTap: () {
          setState(() => _displaySetting = !_displaySetting);
        },
        child: Container(
          height: barHeight,
          alignment: Alignment.center,
          margin: const EdgeInsets.only(right: 12.0),
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: const Icon(
            CustomIcons.danmaku_setting,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildExpandButton() {
    return GestureDetector(
      onTap: _toggleFullScreen,
      child: Container(
        height: barHeight,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(right: 12.0),
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Icon(
          _isFullScreen
              ? Icons.fullscreen_exit_rounded
              : Icons.fullscreen_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }

  // Callback functions
  void _cancelAndRestartHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 2), () {
      setState(() => _hideStuff = true);
    });
    setState(() => _hideStuff = false);
  }

  // Operations
  void _playPause() {
    if (_isPlaying) {
      _cancelAndRestartHideTimer();
      controller.pause();
    } else {
      _hideTimer?.cancel();
      controller.play();
      _hideStuff = true;
    }
    setState(() {});
  }

  void _toggleFullScreen() {
    setState(() {
      _hideStuff = true;
      _lockStuff = false;
    });
    widget.fullScreenBuilder(context, _isFullScreen);
  }

  // Gesture functions
  void _cancelAndRestartHideBVTimer() {
    _hideBVTimer?.cancel();
    _hideBVTimer = Timer(const Duration(seconds: 1), () {
      setState(() => _hideBVStuff = true);
    });
    setState(() => _hideBVStuff = false);
  }

  void _onVerticalScrollUpdate(PointerScrollEvent event) async {
    if (_lockStuff) return;

    if (_hideBVStuff) {
      _updateDargVarVal = controller.general.volume;
    }
    _cancelAndRestartHideBVTimer();
    double dragRange =
        (event.scrollDelta.direction >= 0 && event.scrollDelta.direction <= pi)
            ? _updateDargVarVal - 0.05
            : _updateDargVarVal + 0.05;
    // 是否溢出
    dragRange = min(dragRange, 1.0);
    dragRange = max(dragRange, 0.0);

    setState(() {
      _updateDargVarVal = dragRange;
      controller.setVolume(dragRange);
    });
  }
}
