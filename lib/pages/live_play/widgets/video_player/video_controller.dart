import 'dart:async';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:better_player/better_player.dart';
import 'package:bordered_text/bordered_text.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:hot_live/common/index.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:wakelock/wakelock.dart';
import 'package:window_manager/window_manager.dart';

class VideoController with ChangeNotifier {
  final RoomInfo room;
  final DanmakuStream danmakuStream;
  final String datasourceType;
  String datasource;
  final bool allowBackgroundPlay;
  final bool allowScreenKeepOn;
  final bool allowFullScreen;
  final bool fullScreenByDefault;
  final bool autoPlay;

  final fitModeIndex = 0.obs;
  BoxFit fitMode;
  static const fitModes = {
    '默认比例': BoxFit.contain,
    '填充屏幕': BoxFit.fill,
    '居中裁剪': BoxFit.fitWidth,
  };

  // Video player
  Player? desktopController;
  BetterPlayerController? mobileController;
  VolumeController volumeController = VolumeController()..showSystemUI = false;
  ScreenBrightness brightnessController = ScreenBrightness();

  final hasError = false.obs;
  final isPlaying = false.obs;
  final isBuffering = false.obs;
  final isFullscreen = false.obs;
  final isPipMode = false.obs;
  bool get supportPip => Platform.isAndroid;

  // 电量状态监听
  final Battery _battery = Battery();
  final batteryLevel = 100.obs;
  void initBattery() {
    _battery.batteryLevel.then((value) => batteryLevel.value = value);
    _battery.onBatteryStateChanged.listen((state) async {
      batteryLevel.value = await _battery.batteryLevel;
    });
  }

  // Danmaku player
  BarrageWallController barrageWallController = BarrageWallController();
  final Rx<bool> hideDanmaku = false.obs;
  final danmakuArea = 0.5.obs;
  final danmakuSpeed = 8.0.obs;
  final danmakuFontSize = 16.0.obs;
  final danmakuFontBorder = 0.5.obs;
  final danmakuOpacity = 1.0.obs;
  final danmakuAmount = 100.obs;

  VideoController({
    required this.room,
    required this.danmakuStream,
    required this.datasourceType,
    required this.datasource,
    this.allowBackgroundPlay = false,
    this.allowScreenKeepOn = false,
    this.allowFullScreen = true,
    this.fullScreenByDefault = false,
    this.autoPlay = true,
    this.fitMode = BoxFit.contain,
  }) {
    if (allowScreenKeepOn) {
      Wakelock.enable();
    }
    initController();
    initStatusListener();
    initDanmaku();
  }

  @override
  void dispose() {
    super.dispose();
    Wakelock.disable();
    brightnessController.resetScreenBrightness();
    mobileController?.removeEventsListener((p0) {
      hasError.value =
          mobileController?.videoPlayerController?.value.hasError ?? false;
      isPlaying.value =
          mobileController?.videoPlayerController?.value.isPlaying ?? false;
      isBuffering.value =
          mobileController?.videoPlayerController?.value.isBuffering ?? false;
      isPipMode.value =
          mobileController?.videoPlayerController?.value.isPip ?? false;
    });
    barrageWallController.dispose();
    desktopController?.dispose();
    mobileController?.dispose();
  }

  void initController() {
    if (Platform.isWindows || Platform.isLinux) {
      desktopController = Player(id: 0, registerTexture: true);
      setDataSource(datasource);
    } else if (Platform.isAndroid || Platform.isIOS) {
      mobileController = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: true,
          fit: fitMode,
          fullScreenByDefault: fullScreenByDefault,
          allowedScreenSleep: !allowScreenKeepOn,
          autoDetectFullscreenDeviceOrientation: true,
          autoDetectFullscreenAspectRatio: true,
          routePageBuilder: mobileFullscreenBuilder,
        ),
      );
      mobileController?.setControlsEnabled(false);
      setDataSource(datasource);
    } else {
      throw UnimplementedError('Unsupported Platform');
    }
  }

  void initStatusListener() {
    if (Platform.isWindows || Platform.isLinux) {
      desktopController?.playbackStream.listen((event) {
        hasError.value = desktopController?.playback.isCompleted ?? false;
        isPlaying.value = desktopController?.playback.isPlaying ?? false;
        isBuffering.value = (desktopController?.bufferingProgress ?? 1.0) < 1.0;
      });
    } else if (Platform.isAndroid || Platform.isIOS) {
      mobileController?.addEventsListener((p0) {
        hasError.value =
            mobileController?.videoPlayerController?.value.hasError ?? false;
        isPlaying.value = mobileController?.isPlaying() ?? false;
        isBuffering.value = mobileController?.isBuffering() ?? false;
        isPipMode.value =
            mobileController?.videoPlayerController?.value.isPip ?? false;
        isFullscreen.value = mobileController?.isFullScreen ?? false;
      });
    } else {
      throw UnimplementedError('Unsupported Platform');
    }
  }

  void initDanmaku() {
    hideDanmaku.value = PrefUtil.getBool('hideDanmaku') ?? false;
    hideDanmaku.listen((data) {
      PrefUtil.setBool('hideDanmaku', data);
    });
    danmakuArea.value = PrefUtil.getDouble('danmakuArea') ?? 0.5;
    danmakuArea.listen((data) {
      PrefUtil.setDouble('danmakuArea', data);
    });
    danmakuSpeed.value = PrefUtil.getDouble('danmakuSpeed') ?? 8;
    danmakuSpeed.listen((data) {
      PrefUtil.setDouble('danmakuSpeed', data);
    });
    danmakuFontSize.value = PrefUtil.getDouble('danmakuFontSize') ?? 16;
    danmakuFontSize.listen((data) {
      PrefUtil.setDouble('danmakuFontSize', data);
    });
    danmakuFontBorder.value = PrefUtil.getDouble('danmakuFontBorder') ?? 0.5;
    danmakuFontBorder.listen((data) {
      PrefUtil.setDouble('danmakuFontBorder', data);
    });
    danmakuOpacity.value = PrefUtil.getDouble('danmakuOpacity') ?? 1.0;
    danmakuOpacity.listen((data) {
      PrefUtil.setDouble('danmakuOpacity', data);
    });
    danmakuAmount.value = PrefUtil.getInt('danmakuAmount') ?? 100;
    barrageWallController.setMaxBarrageSize(danmakuAmount.value);
    danmakuAmount.listen((data) {
      barrageWallController.setMaxBarrageSize(data);
      PrefUtil.setInt('danmakuAmount', data);
    });
    danmakuStream.listen((info) {
      barrageWallController.send([
        Bullet(
          child: DanmakuText(
            message: info.msg,
            danmakuFontSize: danmakuFontSize,
            danmakuFontBorder: danmakuFontBorder,
          ),
        ),
      ]);
    });
  }

  void retryDataSource() {
    if (Platform.isWindows || Platform.isLinux) {
      setDataSource(datasource);
    } else if (Platform.isAndroid || Platform.isIOS) {
      mobileController?.retryDataSource();
    }
  }

  void setDataSource(String url) {
    datasource = url;
    if (Platform.isWindows || Platform.isLinux) {
      desktopController?.pause();
      desktopController?.open(
        Media.directShow(rawUrl: datasource),
        autoStart: true,
      );
    } else if (Platform.isAndroid || Platform.isIOS) {
      mobileController?.setupDataSource(BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url,
        liveStream: true,
        notificationConfiguration: allowBackgroundPlay
            ? BetterPlayerNotificationConfiguration(
                showNotification: true,
                title: room.title,
                author: room.nick,
                imageUrl: room.cover,
                activityName: "MainActivity",
              )
            : null,
      ));
    } else {
      throw UnimplementedError('Unsupported Platform');
    }
  }

  void setVideoFit(int index) {
    fitModeIndex.value = index;
    fitMode = fitModes.values.toList()[index];
    if (Platform.isWindows || Platform.isLinux) {
    } else if (Platform.isAndroid || Platform.isIOS) {
      mobileController?.setOverriddenFit(fitMode);
    } else {
      throw UnimplementedError('Unsupported Platform');
    }
  }

  void togglePlayPause() {
    if (Platform.isWindows || Platform.isLinux) {
      if (isPlaying.value) {
        desktopController!.pause();
      } else {
        desktopController!.play();
      }
    } else if (Platform.isAndroid || Platform.isIOS) {
      if (isPlaying.value) {
        mobileController!.pause();
      } else {
        mobileController!.play();
      }
    } else {
      throw UnimplementedError('Unsupported Platform');
    }
  }

  void Function(BuildContext context)? desktopFullScreenBuilder;

  Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> second,
    BetterPlayerControllerProvider controllerProvider,
  )? mobileFullscreenBuilder;

  void setDesktopFullscreenBuilder(
      void Function(BuildContext context)? builder) {
    desktopFullScreenBuilder = builder;
  }

  void setMobileFullscreenBuilder(
      Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> second,
    BetterPlayerControllerProvider controllerProvider,
  )?
          builder) {
    mobileFullscreenBuilder = builder;
    mobileController?.dispose();
    initController();
    initStatusListener();
  }

  void toggleFullScreen(BuildContext context) {
    if (Platform.isWindows || Platform.isLinux) {
      if (desktopFullScreenBuilder == null) return;
      if (!isFullscreen.value) {
        WindowManager.instance.setFullScreen(true);
        Timer(
          const Duration(milliseconds: 500),
          () => desktopFullScreenBuilder!(context),
        );
      } else {
        Navigator.pop(context);
        Timer(const Duration(milliseconds: 500), () {
          WindowManager.instance.setFullScreen(false);
        });
      }
      isFullscreen.toggle();
    } else if (Platform.isAndroid || Platform.isIOS) {
      if (mobileFullscreenBuilder == null) return;
      mobileController?.toggleFullScreen();
      isFullscreen.toggle();
    } else {
      throw UnimplementedError('Unsupported Platform');
    }
  }

  void enterPipMode(BuildContext context, {GlobalKey? playerKey}) async {
    if ((Platform.isAndroid || Platform.isIOS) && playerKey != null) {
      if (await mobileController?.isPictureInPictureSupported() ?? false) {
        mobileController?.enablePictureInPicture(playerKey);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            margin: EdgeInsets.symmetric(horizontal: 16),
            content: Text('暂不支持画中画'),
          ),
        );
      }
    } else {
      throw UnimplementedError('Unsupported Platform');
    }
  }

  Future<double> volumn() async {
    if (Platform.isWindows || Platform.isLinux) {
      return Future(() => desktopController?.general.volume ?? 1);
    } else if (Platform.isAndroid || Platform.isIOS) {
      return await volumeController.getVolume();
    } else {
      throw UnimplementedError('Unsupported Platform');
    }
  }

  Future<double> brightness() async {
    if (Platform.isWindows || Platform.isLinux) {
      return await brightnessController.current;
    } else if (Platform.isAndroid || Platform.isIOS) {
      return await brightnessController.current;
    } else {
      throw UnimplementedError('Unsupported Platform');
    }
  }

  void setVolumn(double value) async {
    if (Platform.isWindows || Platform.isLinux) {
      desktopController?.setVolume(value);
    } else if (Platform.isAndroid || Platform.isIOS) {
      volumeController.setVolume(value);
    } else {
      throw UnimplementedError('Unsupported Platform');
    }
  }

  Future<double> setBrightness(double value) async {
    if (Platform.isWindows || Platform.isLinux) {
      brightnessController.setScreenBrightness(value);
    } else if (Platform.isAndroid || Platform.isIOS) {
      brightnessController.setScreenBrightness(value);
    } else {
      throw UnimplementedError('Unsupported Platform');
    }
    return 1;
  }
}

class DanmakuText extends StatelessWidget {
  const DanmakuText({
    Key? key,
    required this.message,
    required this.danmakuFontSize,
    required this.danmakuFontBorder,
  }) : super(key: key);

  final String message;
  final RxDouble danmakuFontSize;
  final RxDouble danmakuFontBorder;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => BorderedText(
        strokeWidth: danmakuFontBorder.value,
        child: Text(
          message,
          maxLines: 1,
          style: TextStyle(
            fontSize: danmakuFontSize.value,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
