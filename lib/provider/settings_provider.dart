import 'dart:convert';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:hot_live/model/liveroom.dart';
import 'package:hot_live/utils/pref_util.dart';

class SettingsProvider with ChangeNotifier {
  SettingsProvider() {
    // 设置电量监听
    initBattery();
    _loadFromPref();
  }

  // 电量状态监听
  final Battery _battery = Battery();
  int batteryLevel = 100;
  void initBattery() {
    _battery.batteryLevel.then((value) => batteryLevel = value);
    _battery.onBatteryStateChanged.listen((state) async {
      batteryLevel = await _battery.batteryLevel;
      notifyListeners();
    });
  }

  // 播放器比例监听
  int _playerFitMode = 0;
  int get playerFitMode => _playerFitMode;
  BoxFit get playerBoxFit => _playerFitMode == 0
      ? BoxFit.contain
      : _playerFitMode == 1
          ? BoxFit.fill
          : BoxFit.fitWidth;
  set playerFitMode(int value) {
    if (value < 0 || value > 2) return;
    _playerFitMode = value;
    notifyListeners();
  }

  void resetPlayerFitMode() {
    _playerFitMode = 0;
  }

  void _loadFromPref() async {
    _themeModeName = PrefUtil.getString('themeMode') ?? "System";
    _themeColorName = PrefUtil.getString('themeColor') ?? "Crimson";
    _languageName = PrefUtil.getString('language') ?? "简体中文";
    _enableAutoCheckUpdate = PrefUtil.getBool('enableAutoCheckUpdate') ?? true;
    _enableDenseFavorites = PrefUtil.getBool('enableDenseFavorites') ?? false;
    _enableBackgroundPlay = PrefUtil.getBool('enableBackgroundPlay') ?? false;
    _enableScreenKeepOn = PrefUtil.getBool('enableScreenKeepOn') ?? false;
    _enableFullScreenDefault =
        PrefUtil.getBool('enableFullScreenDefault') ?? false;
    _bilibiliCustomCookie = PrefUtil.getString('bilibiliCustomCookie') ?? '';
    _hideOfflineRoom = PrefUtil.getBool('hideOfflineRoom') ?? false;
    _hideDanmaku = PrefUtil.getBool('hideDanmaku') ?? false;
    _danmakuArea = PrefUtil.getDouble('danmakuArea') ?? 0.5;
    _danmakuSpeed = PrefUtil.getDouble('danmakuSpeed') ?? 8;
    _danmakuFontBorder = PrefUtil.getDouble('danmakuFontBorder') ?? 0.5;
    _danmakuFontSize = PrefUtil.getDouble('danmakuFontSize') ?? 16;
    _danmakuOpacity = PrefUtil.getDouble('danmakuOpcity') ?? 1.0;
    _floatOverlayRatio = PrefUtil.getDouble('floatOverlayRatio') ?? 0.8;
    _preferResolutionIndex = PrefUtil.getInt('preferResolutionIndex') ?? 0;
  }

  void _saveToPref() {
    PrefUtil.setString('themeMode', _themeModeName);
    PrefUtil.setString('themeColor', _themeColorName);
    PrefUtil.setString('language', _languageName);
    PrefUtil.setBool('enableDenseFavorites', _enableDenseFavorites);
    PrefUtil.setBool('enableBackgroundPlay', _enableBackgroundPlay);
    PrefUtil.setBool('enableScreenKeepOn', _enableScreenKeepOn);
    PrefUtil.setBool('enableAutoCheckUpdate', _enableAutoCheckUpdate);
    PrefUtil.setBool('enableFullScreenDefault', _enableFullScreenDefault);
    PrefUtil.setString('bilibiliCustomCookie', _bilibiliCustomCookie);
    PrefUtil.setBool('hideOfflineRoom', _hideOfflineRoom);
    PrefUtil.setBool('hideDanmaku', _hideDanmaku);
    PrefUtil.setDouble('danmakuArea', _danmakuArea);
    PrefUtil.setDouble('danmakuSpeed', _danmakuSpeed);
    PrefUtil.setDouble('danmakuFontBorder', _danmakuFontBorder);
    PrefUtil.setDouble('danmakuFontSize', _danmakuFontSize);
    PrefUtil.setDouble('danmakuOpcity', _danmakuOpacity);
    PrefUtil.setDouble('floatOverlayRatio', _floatOverlayRatio);
    PrefUtil.setInt('preferResolutionIndex', _preferResolutionIndex);
  }

  // Theme settings
  static Map<String, ThemeMode> themeModes = {
    "System": ThemeMode.system,
    "Dark": ThemeMode.dark,
    "Light": ThemeMode.light,
  };

  String _themeModeName = "System";
  get themeMode => SettingsProvider.themeModes[_themeModeName]!;
  get themeModeName => _themeModeName;
  void changeThemeMode(String mode) {
    _themeModeName = mode;
    notifyListeners();
    PrefUtil.setString('themeMode', _themeModeName);
  }

  static Map<String, Color> themeColors = {
    "Crimson": const Color.fromARGB(255, 220, 20, 60),
    "Orange": Colors.orange,
    "Chrome": const Color.fromARGB(255, 230, 184, 0),
    "Grass": Colors.lightGreen,
    "Teal": Colors.teal,
    "SeaFoam": const Color.fromARGB(255, 112, 193, 207),
    "Ice": const Color.fromARGB(255, 115, 155, 208),
    "Blue": Colors.blue,
    "Indigo": Colors.indigo,
    "Violet": Colors.deepPurple,
    "Orchid": const Color.fromARGB(255, 218, 112, 214),
  };

  String _themeColorName = "Blue";
  get themeColor => SettingsProvider.themeColors[_themeColorName]!;
  get themeColorName => _themeColorName;
  void changeThemeColor(String color) {
    _themeColorName = color;
    notifyListeners();
    PrefUtil.setString('themeColor', _themeColorName);
  }

  static Map<String, Locale> languages = {
    "English": const Locale.fromSubtags(languageCode: 'en'),
    "简体中文": const Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
  };
  String _languageName = "English";
  get language => SettingsProvider.languages[_languageName]!;
  get languageName => _languageName;
  void changeLanguage(String value) {
    _languageName = value;
    notifyListeners();
    PrefUtil.setString('language', _languageName);
  }

  // Custom settings
  bool _enableDenseFavorites = false;
  bool get enableDenseFavorites => _enableDenseFavorites;
  set enableDenseFavorites(bool value) {
    _enableDenseFavorites = value;
    notifyListeners();
    PrefUtil.setBool('enableDenseFavorites', _enableDenseFavorites);
  }

  bool _enableBackgroundPlay = false;
  bool get enableBackgroundPlay => _enableBackgroundPlay;
  set enableBackgroundPlay(bool value) {
    _enableBackgroundPlay = value;
    notifyListeners();
    PrefUtil.setBool('enableBackgroundPlay', _enableBackgroundPlay);
  }

  bool _enableScreenKeepOn = false;
  bool get enableScreenKeepOn => _enableScreenKeepOn;
  set enableScreenKeepOn(bool value) {
    _enableScreenKeepOn = value;
    notifyListeners();
    PrefUtil.setBool('enableScreenKeepOn', _enableScreenKeepOn);
  }

  bool _enableAutoCheckUpdate = true;
  bool get enableAutoCheckUpdate => _enableAutoCheckUpdate;
  set enableAutoCheckUpdate(bool value) {
    _enableAutoCheckUpdate = value;
    notifyListeners();
    PrefUtil.setBool('enableAutoCheckUpdate', _enableAutoCheckUpdate);
  }

  bool _enableFullScreenDefault = true;
  bool get enableFullScreenDefault => _enableFullScreenDefault;
  set enableFullScreenDefault(bool value) {
    _enableFullScreenDefault = value;
    notifyListeners();
    PrefUtil.setBool('enableFullScreenDefault', _enableFullScreenDefault);
  }

  String _bilibiliCustomCookie = '';
  String get bilibiliCustomCookie => _bilibiliCustomCookie;
  set bilibiliCustomCookie(String value) {
    _bilibiliCustomCookie = value;
    PrefUtil.setString('bilibiliCustomCookie', _bilibiliCustomCookie);
    notifyListeners();
  }

  bool _hideOfflineRoom = false;
  bool get hideOfflineRoom => _hideOfflineRoom;
  set hideOfflineRoom(bool value) {
    _hideOfflineRoom = value;
    notifyListeners();
    PrefUtil.setBool("hideOfflineRoom", _hideOfflineRoom);
  }

  // Danmaku settings
  bool _hideDanmaku = false;
  bool get hideDanmaku => _hideDanmaku;
  set hideDanmaku(bool value) {
    _hideDanmaku = value;
    notifyListeners();
    PrefUtil.setBool("hideDanmaku", _hideDanmaku);
  }

  double _danmakuArea = 0.5;
  double get danmakuArea => _danmakuArea;
  set danmakuArea(value) {
    if (value < 0 || value > 1) return;
    _danmakuArea = value;
    notifyListeners();
    PrefUtil.setDouble('danmakuArea', _danmakuArea);
  }

  double _danmakuSpeed = 8;
  double get danmakuSpeed => _danmakuSpeed;
  set danmakuSpeed(value) {
    if (value < 1 || value > 20) return;
    _danmakuSpeed = value;
    notifyListeners();
    PrefUtil.setDouble('danmakuSpeed', _danmakuSpeed);
  }

  double _danmakuFontBorder = 0.5;
  double get danmakuFontBorder => _danmakuFontBorder;
  set danmakuFontBorder(value) {
    if (value < 0 || value > 2.5) return;
    _danmakuFontBorder = value;
    notifyListeners();
    PrefUtil.setDouble('danmakuFontBorder', _danmakuFontBorder);
  }

  double _danmakuFontSize = 16;
  double get danmakuFontSize => _danmakuFontSize;
  set danmakuFontSize(value) {
    if (value < 10 || value > 30) return;
    _danmakuFontSize = value;
    notifyListeners();
    PrefUtil.setDouble('danmakuFontSize', _danmakuFontSize);
  }

  double _danmakuOpacity = 1;
  double get danmakuOpacity => _danmakuOpacity;
  set danmakuOpacity(value) {
    if (value < 0 || value > 1) return;
    _danmakuOpacity = value;
    notifyListeners();
    PrefUtil.setDouble('danmakuOpcity', _danmakuOpacity);
  }

  double _floatOverlayRatio = 0.8;
  double get floatOverlayRatio => _floatOverlayRatio;
  set floatOverlayRatio(double value) {
    if (value < 0.1 || value > 1.0) return;
    _floatOverlayRatio = value;
    notifyListeners();
    PrefUtil.setDouble('floatOverlayRatio', _floatOverlayRatio);
  }

  static const List<String> resolutions = ['原画', '蓝光8M', '蓝光4M', '超清', '流畅'];
  String get preferResolution => resolutions[_preferResolutionIndex];
  int _preferResolutionIndex = 0;
  void changePreferResolution(String name) {
    int index = resolutions.indexWhere((e) => e == name);
    if (index != -1) {
      _preferResolutionIndex = index;
      notifyListeners();
      PrefUtil.setInt('preferResolutionIndex', _preferResolutionIndex);
    }
  }

  // for backup storage
  List<RoomInfo> _favorites = [];

  void fromJson(Map<String, dynamic> json) {
    List<String> prefs = (json['favorites'] ?? []) as List<String>;
    _favorites =
        prefs.map<RoomInfo>((e) => RoomInfo.fromJson(jsonDecode(e))).toList();
    _themeModeName = json['themeMode'] ?? "System";
    _themeColorName = json['themeColor'] ?? "Crimson";
    _enableDenseFavorites = json['enableDenseFavorites'] ?? false;
    _enableBackgroundPlay = json['enableBackgroundPlay'] ?? false;
    _enableScreenKeepOn = json['enableScreenKeepOn'] ?? false;
    _enableAutoCheckUpdate = json['enableAutoCheckUpdate'] ?? true;
    _enableFullScreenDefault = json['enableFullScreenDefault'] ?? false;
    _hideOfflineRoom = json['hideOfflineRoom'] ?? false;
    _hideDanmaku = json['hideDanmaku'] ?? false;
    _bilibiliCustomCookie = json['bilibiliCustomCookie'] ?? '';
    _danmakuArea = json['danmakuArea'] ?? 0.5;
    _danmakuSpeed = json['danmakuSpeed'] ?? 8;
    _danmakuFontBorder = json['danmakuFontBorder'] ?? 0.8;
    _danmakuFontSize = json['danmakuFontSize'] ?? 16;
    _danmakuOpacity = json['danmakuOpcity'] ?? 1.0;
    _floatOverlayRatio = json['floatOverlayRatio'] ?? 0.8;
    _preferResolutionIndex = json['preferResolutionIndex'] ?? 0;
    _saveToPref();
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['favorites'] =
        _favorites.map<String>((e) => jsonEncode(e.toJson())).toList();
    json['themeMode'] = _themeModeName;
    json['themeColor'] = _themeColorName;
    json['enableDenseFavorites'] = _enableDenseFavorites;
    json['enableBackgroundPlay'] = _enableBackgroundPlay;
    json['enableScreenKeepOn'] = _enableScreenKeepOn;
    json['enableAutoCheckUpdate'] = _enableAutoCheckUpdate;
    json['enableFullScreenDefault'] = _enableFullScreenDefault;
    json['hideOfflineRoom'] = _hideOfflineRoom;
    json['hideDanmaku'] = _hideDanmaku;
    json['bilibiliCustomCookie'] = _bilibiliCustomCookie;
    json['danmakuArea'] = _danmakuArea;
    json['danmakuSpeed'] = _danmakuSpeed;
    json['danmakuFontBorder'] = _danmakuFontBorder;
    json['danmakuFontSize'] = _danmakuFontSize;
    json['danmakuOpcity'] = _danmakuOpacity;
    json['floatOverlayRatio'] = _floatOverlayRatio;
    json['preferResolutionIndex'] = _preferResolutionIndex;
    return json;
  }
}
