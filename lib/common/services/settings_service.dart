import 'dart:convert';

import 'package:pure_live/common/index.dart';

class SettingsProvider with ChangeNotifier {
  SettingsProvider();

  // Theme settings
  static Map<String, ThemeMode> themeModes = {
    "System": ThemeMode.system,
    "Dark": ThemeMode.dark,
    "Light": ThemeMode.light,
  };
  String _themeModeName = PrefUtil.getString('themeMode') ?? "System";
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
  String _themeColorName = PrefUtil.getString('themeColor') ?? "Blue";
  get themeColor => SettingsProvider.themeColors[_themeColorName]!;
  get themeColorName => _themeColorName;
  void changeThemeColor(String color) {
    _themeColorName = color;
    notifyListeners();
    PrefUtil.setString('themeColor', _themeColorName);
  }

  bool _enableDynamicTheme = PrefUtil.getBool('enableDynamicTheme') ?? false;
  bool get enableDynamicTheme => _enableDynamicTheme;
  set enableDynamicTheme(bool value) {
    _enableDynamicTheme = value;
    notifyListeners();
    PrefUtil.setBool('enableDynamicTheme', _enableDynamicTheme);
  }

  static Map<String, Locale> languages = {
    "English": const Locale.fromSubtags(languageCode: 'en'),
    "简体中文": const Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
  };
  String _languageName = PrefUtil.getString('language') ?? "简体中文";
  get language => SettingsProvider.languages[_languageName]!;
  get languageName => _languageName;
  void changeLanguage(String value) {
    _languageName = value;
    notifyListeners();
    PrefUtil.setString('language', _languageName);
  }

  // Custom settings
  int _autoRefreshTime = PrefUtil.getInt('autoRefreshTime') ?? 60;
  int get autoRefreshTime => _autoRefreshTime;
  set autoRefreshTime(value) {
    _autoRefreshTime = value;
    notifyListeners();
    PrefUtil.setInt('autoRefreshTime', _autoRefreshTime);
  }

  bool _enableDenseFavorites =
      PrefUtil.getBool('enableDenseFavorites') ?? false;
  bool get enableDenseFavorites => _enableDenseFavorites;
  set enableDenseFavorites(bool value) {
    _enableDenseFavorites = value;
    notifyListeners();
    PrefUtil.setBool('enableDenseFavorites', _enableDenseFavorites);
  }

  bool _enableBackgroundPlay =
      PrefUtil.getBool('enableBackgroundPlay') ?? false;
  bool get enableBackgroundPlay => _enableBackgroundPlay;
  set enableBackgroundPlay(bool value) {
    _enableBackgroundPlay = value;
    notifyListeners();
    PrefUtil.setBool('enableBackgroundPlay', _enableBackgroundPlay);
  }

  bool _enableScreenKeepOn = PrefUtil.getBool('enableScreenKeepOn') ?? false;
  bool get enableScreenKeepOn => _enableScreenKeepOn;
  set enableScreenKeepOn(bool value) {
    _enableScreenKeepOn = value;
    notifyListeners();
    PrefUtil.setBool('enableScreenKeepOn', _enableScreenKeepOn);
  }

  bool _enableAutoCheckUpdate =
      PrefUtil.getBool('enableAutoCheckUpdate') ?? true;
  bool get enableAutoCheckUpdate => _enableAutoCheckUpdate;
  set enableAutoCheckUpdate(bool value) {
    _enableAutoCheckUpdate = value;
    notifyListeners();
    PrefUtil.setBool('enableAutoCheckUpdate', _enableAutoCheckUpdate);
  }

  bool _enableFullScreenDefault =
      PrefUtil.getBool('enableFullScreenDefault') ?? true;
  bool get enableFullScreenDefault => _enableFullScreenDefault;
  set enableFullScreenDefault(bool value) {
    _enableFullScreenDefault = value;
    notifyListeners();
    PrefUtil.setBool('enableFullScreenDefault', _enableFullScreenDefault);
  }

  String _bilibiliCustomCookie =
      PrefUtil.getString('bilibiliCustomCookie') ?? '';
  String get bilibiliCustomCookie => _bilibiliCustomCookie;
  set bilibiliCustomCookie(String value) {
    _bilibiliCustomCookie = value;
    PrefUtil.setString('bilibiliCustomCookie', _bilibiliCustomCookie);
    notifyListeners();
  }

  static const List<String> resolutions = ['原画', '蓝光8M', '蓝光4M', '超清', '流畅'];
  String _preferResolution =
      PrefUtil.getString('preferResolution') ?? resolutions[0];
  String get preferResolution => _preferResolution;
  void changePreferResolution(String name) {
    if (resolutions.indexWhere((e) => e == name) != -1) {
      _preferResolution = name;
      notifyListeners();
      PrefUtil.setString('preferResolution', _preferResolution);
    }
  }

  static const List<String> platforms = ['bilibili', 'douyu', 'huya'];
  String _preferPlatform = PrefUtil.getString('preferPlatform') ?? platforms[0];
  String get preferPlatform => _preferPlatform;
  void changePreferPlatform(String name) {
    if (platforms.indexWhere((e) => e == name) != -1) {
      _preferPlatform = name;
      notifyListeners();
      PrefUtil.setString('preferPlatform', _preferPlatform);
    }
  }

  // for backup storage
  List<RoomInfo> _favorites = [];

  void fromJson(Map<String, dynamic> json) {
    List<String> prefs = (json['favorites'] ?? []) as List<String>;
    _favorites =
        prefs.map<RoomInfo>((e) => RoomInfo.fromJson(jsonDecode(e))).toList();
    changeThemeMode(json['themeMode'] ?? "System");
    changeThemeColor(json['themeColor'] ?? "Crimson");
    enableDenseFavorites = json['enableDenseFavorites'] ?? false;
    enableBackgroundPlay = json['enableBackgroundPlay'] ?? false;
    enableScreenKeepOn = json['enableScreenKeepOn'] ?? false;
    enableAutoCheckUpdate = json['enableAutoCheckUpdate'] ?? true;
    enableFullScreenDefault = json['enableFullScreenDefault'] ?? false;
    bilibiliCustomCookie = json['bilibiliCustomCookie'] ?? '';
    changePreferResolution(json['preferResolution'] ?? resolutions[0]);
    changePreferPlatform(json['preferPlatform'] ?? platforms[0]);
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
    json['bilibiliCustomCookie'] = _bilibiliCustomCookie;
    json['preferResolution'] = _preferResolution;
    json['preferPlatform'] = _preferPlatform;
    return json;
  }
}
