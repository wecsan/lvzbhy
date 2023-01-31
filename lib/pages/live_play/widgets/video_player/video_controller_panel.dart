import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:hot_live/common/index.dart';
import 'package:hot_live/pages/live_play/widgets/video_player/video_controller.dart';

class VideoControllerPanel extends StatefulWidget {
  final GlobalKey playerKey;
  final VideoController controller;
  final double? width;
  final double? height;

  const VideoControllerPanel({
    Key? key,
    required this.playerKey,
    required this.controller,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VideoControllerPanelState();
}

class _VideoControllerPanelState extends State<VideoControllerPanel>
    with SingleTickerProviderStateMixin {
  late double videoWidth;
  late double videoHeight;
  static const barHeight = 56.0;

  Timer? _hideStuffTimer;
  bool _hideStuff = false;
  bool _lockStuff = false;
  bool _settingStuff = false;

  // Darg bv ui control
  Timer? _hideBVTimer;
  bool _isDargLeft = true;
  bool _hideBVStuff = true;
  double _updateDargVarVal = 1;

  // Video controllers
  VideoController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _cancelAndRestartHideTimer();
  }

  @override
  void dispose() {
    _hideBVTimer?.cancel();
    _hideStuffTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    videoWidth = widget.width ?? MediaQuery.of(context).size.width;
    videoHeight = widget.height ?? MediaQuery.of(context).size.height;

    if (controller.hasError.value) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '无法播放直播',
              style: TextStyle(color: Colors.white),
            ),
            TextButton(
              onPressed: () => controller.retryDataSource(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    } else if (controller.isPipMode.value) {
      return Container();
    }

    List<Widget> ws = [];
    if (!controller.hideDanmaku.value) {
      ws.add(_buildDanmakuView());
    }
    if (_settingStuff) {
      ws.add(_buildSettingView());
    } else {
      ws.add(_buildHitArea());
      if (controller.isFullscreen.value) ws.add(_buidLockButton());
      if (!_lockStuff) {
        ws.add(_buildActionBar());
        ws.add(_buildBottomBar());
      }
    }
    return MouseRegion(
      onHover: (event) => _cancelAndRestartHideTimer(),
      onExit: (event) {
        _hideStuffTimer?.cancel();
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
      height: videoHeight * controller.danmakuArea.value,
      child: Obx(() => AnimatedOpacity(
            opacity: !controller.hideDanmaku.value
                ? controller.danmakuOpacity.value
                : 0.0,
            duration: const Duration(milliseconds: 300),
            child: ClipRect(
              clipBehavior: Clip.hardEdge,
              child: BarrageWall(
                width: videoWidth,
                height: videoHeight * controller.danmakuArea.value,
                speed: controller.danmakuSpeed.value.toInt(),
                controller: controller.barrageWallController,
                massiveMode: true,
                maxBulletHeight: controller.danmakuFontSize.value * 1.25,
                safeBottomHeight: controller.danmakuFontSize.value.toInt(),
                child: Container(),
              ),
            ),
          )),
    );
  }

  // Center hit and controller widgets
  Widget _buildHitArea() {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          _onVerticalDragUpdate(event.localPosition, event.scrollDelta);
        }
      },
      child: GestureDetector(
        onTap: () {
          if (controller.isPlaying.value) {
            _cancelAndRestartHideTimer();
          } else {
            _togglePlayPause();
          }
        },
        onDoubleTap: _toggleFullScreen,
        onVerticalDragUpdate: (details) =>
            _onVerticalDragUpdate(details.localPosition, details.delta),
        child: Container(
          color: Colors.transparent,
          child: _buildBVBar(),
        ),
      ),
    );
  }

  Widget _buildBVBar() {
    IconData iconData = Icons.volume_up;
    if (!_hideBVStuff) {
      if (_isDargLeft) {
        iconData = _updateDargVarVal <= 0
            ? Icons.brightness_low
            : _updateDargVarVal < 0.5
                ? Icons.brightness_medium
                : Icons.brightness_high;
      } else {
        iconData = _updateDargVarVal <= 0
            ? Icons.volume_mute
            : _updateDargVarVal < 0.5
                ? Icons.volume_down
                : Icons.volume_up;
      }
    }

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

  Widget _buidLockButton() {
    return AnimatedOpacity(
      opacity: !_hideStuff ? 0.9 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(right: 20.0),
          child: IconButton(
            onPressed: () => setState(() => _lockStuff = !_lockStuff),
            icon: Icon(
              _lockStuff ? Icons.lock_rounded : Icons.lock_open_rounded,
              size: 28,
            ),
            color: Colors.white,
            style: IconButton.styleFrom(
              backgroundColor: Colors.black38,
              shape: const StadiumBorder(),
              minimumSize: const Size(50, 50),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingView() {
    const TextStyle label = TextStyle(color: Colors.white);
    const TextStyle digit = TextStyle(color: Colors.white);
    final Color color = Theme.of(context).colorScheme.primary.withOpacity(0.8);

    return GestureDetector(
      onTap: () => setState(() => _settingStuff = !_settingStuff),
      child: Container(
        color: Colors.transparent,
        child: Obx(() {
          final isSelected = [false, false, false];
          isSelected[controller.fitModeIndex.value] = true;

          return Container(
            alignment: Alignment.centerRight,
            child: AnimatedOpacity(
              opacity: _settingStuff ? 0.8 : 0.0,
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
                              '比例设置',
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                          ToggleButtons(
                            borderRadius: BorderRadius.circular(10),
                            selectedBorderColor: color,
                            borderColor: color,
                            fillColor: color,
                            children: VideoController.fitModes.keys
                                .map<Widget>((e) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Text(e, style: label),
                                    ))
                                .toList(),
                            isSelected: isSelected,
                            onPressed: controller.setVideoFit,
                          ),
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
                              divisions: 5,
                              value: controller.danmakuArea.value,
                              min: 0.0,
                              max: 1.0,
                              onChanged: (val) =>
                                  controller.danmakuArea.value = val,
                            ),
                            trailing: Text(
                              (controller.danmakuArea.value * 100)
                                      .toInt()
                                      .toString() +
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
                              divisions: 10,
                              value: controller.danmakuOpacity.value,
                              min: 0.0,
                              max: 1.0,
                              onChanged: (val) =>
                                  controller.danmakuOpacity.value = val,
                            ),
                            trailing: Text(
                              (controller.danmakuOpacity.value * 100)
                                      .toInt()
                                      .toString() +
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
                              divisions: 15,
                              value: controller.danmakuSpeed.value,
                              min: 5.0,
                              max: 20.0,
                              onChanged: (val) =>
                                  controller.danmakuSpeed.value = val,
                            ),
                            trailing: Text(
                              controller.danmakuSpeed.value.toInt().toString(),
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
                              divisions: 20,
                              value: controller.danmakuFontSize.value,
                              min: 10.0,
                              max: 30.0,
                              onChanged: (val) =>
                                  controller.danmakuFontSize.value = val,
                            ),
                            trailing: Text(
                              controller.danmakuFontSize.value
                                  .toInt()
                                  .toString(),
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
                              value: controller.danmakuFontBorder.value,
                              min: 0.0,
                              max: 2.5,
                              onChanged: (val) =>
                                  controller.danmakuFontBorder.value = val,
                            ),
                            trailing: Text(
                              controller.danmakuFontBorder.value
                                  .toStringAsFixed(2),
                              style: digit,
                            ),
                          ),
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Text(
                              S.of(context).settings_danmaku_amount,
                              style: label,
                            ),
                            title: Slider(
                              divisions: 90,
                              value: controller.danmakuAmount.value.toDouble(),
                              min: 10,
                              max: 100,
                              onChanged: (val) =>
                                  controller.danmakuAmount.value = val.toInt(),
                            ),
                            trailing: Text(
                              controller.danmakuAmount.value.toString(),
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
          );
        }),
      ),
    );
  }

  // Action bar widgets
  Widget _buildActionBar() {
    List<Widget> rows = [];
    if (controller.isFullscreen.value) {
      rows = [
        _buildBackButton(),
        Text(
          controller.room.title,
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
              controller.room.title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
        if (controller.supportPip) _buildPIPButton(),
      ];
    }

    return Positioned(
      top: 0,
      height: barHeight,
      width: videoWidth,
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
    final batteryLevel = controller.batteryLevel.value;
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
              width: 28,
              height: 14,
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

  Widget _buildPIPButton() {
    return GestureDetector(
      onTap: () =>
          controller.enterPipMode(context, playerKey: widget.playerKey),
      child: Container(
        height: barHeight,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(right: 12.0),
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: const Icon(
          CustomIcons.float_window,
          color: Colors.white,
        ),
      ),
    );
  }

  // Bottom bar widgets
  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      height: barHeight,
      width: videoWidth,
      child: AnimatedOpacity(
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
              _buildRefreshButton(),
              _buildDanmakuHideButton(),
              if (videoWidth > 640 || controller.isFullscreen.value)
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
      onTap: _togglePlayPause,
      child: Container(
        height: barHeight,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(right: 12.0),
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Icon(
          controller.isPlaying.value
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRefreshButton() {
    return GestureDetector(
      onTap: () => controller.retryDataSource(),
      child: Container(
        height: barHeight,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(right: 12.0),
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: const Icon(
          Icons.refresh_rounded,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDanmakuHideButton() {
    return GestureDetector(
      onTap: () => controller.hideDanmaku.value = !controller.hideDanmaku.value,
      child: Obx(() => Container(
            height: barHeight,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(right: 12.0),
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Icon(
              controller.hideDanmaku.value
                  ? CustomIcons.danmaku_close
                  : CustomIcons.danmaku_open,
              color: Colors.white,
            ),
          )),
    );
  }

  Widget _buildSettingButton() {
    return Center(
      child: GestureDetector(
        onTap: () => setState(() => _settingStuff = !_settingStuff),
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
          controller.isFullscreen.value
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
    _hideStuffTimer?.cancel();
    _hideStuffTimer = Timer(const Duration(seconds: 2), () {
      setState(() => _hideStuff = true);
    });
    setState(() => _hideStuff = false);
  }

  void _togglePlayPause() {
    if (controller.isPlaying.value) {
      _cancelAndRestartHideTimer();
    } else {
      _hideStuffTimer?.cancel();
      setState(() => _hideStuff = true);
    }
    controller.togglePlayPause();
  }

  void _toggleFullScreen() {
    setState(() {
      _hideStuff = true;
      _lockStuff = false;
    });
    controller.toggleFullScreen(context);
  }

  // Gesture functions
  void _cancelAndRestartHideBVTimer() {
    _hideBVTimer?.cancel();
    _hideBVTimer = Timer(const Duration(seconds: 1), () {
      setState(() => _hideBVStuff = true);
    });
    setState(() => _hideBVStuff = false);
  }

  void _onVerticalDragUpdate(Offset postion, Offset delta) async {
    if (_lockStuff) return;

    if (_hideBVStuff) {
      _isDargLeft = (postion.dx > (videoWidth / 2)) ? false : true;
      // disable windows brightness
      if (Platform.isWindows && _isDargLeft) return;

      if (_isDargLeft) {
        await controller.brightness().then((double v) {
          setState(() => _updateDargVarVal = v);
        });
      } else {
        await controller.volumn().then((double v) {
          setState(() => _updateDargVarVal = v);
        });
      }
    }
    _cancelAndRestartHideBVTimer();

    double dragRange = (delta.direction < 0 || delta.direction > pi)
        ? _updateDargVarVal + 0.01
        : _updateDargVarVal - 0.01;
    // 是否溢出
    dragRange = min(dragRange, 1.0);
    dragRange = max(dragRange, 0.0);
    // 亮度 & 音量
    if (_isDargLeft) {
      controller.setBrightness(dragRange);
    } else {
      controller.setVolumn(dragRange);
    }
    setState(() => _updateDargVarVal = dragRange);
  }
}
