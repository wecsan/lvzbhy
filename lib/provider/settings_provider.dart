import 'package:flutter/material.dart';
import 'package:hot_live/utils/pref_util.dart';

class SettingsProvider with ChangeNotifier {
  SettingsProvider() {
    _loadFromPref();
  }

  void _loadFromPref() async {
    _bilibiliCustomCookie = PrefUtil.getString('bilibiliCustomCookie') ?? '';
    _enbaleAutoCheckUpdate = PrefUtil.getBool('enbaleAutoCheckUpdate') ?? true;
    _danmakuArea = PrefUtil.getDouble('danmakuArea') ?? 0.5;
    _danmakuSpeed = PrefUtil.getDouble('danmakuSpeed') ?? 8;
    _danmakuFontBorder = PrefUtil.getDouble('danmakuFontBorder') ?? 0.8;
    _danmakuFontSize = PrefUtil.getDouble('danmakuFontSize') ?? 16;
    _danmakuOpacity = PrefUtil.getDouble('danmakuOpcity') ?? 1.0;
  }

  void _saveToPref() {
    PrefUtil.setString('bilibiliCustomCookie', _bilibiliCustomCookie);
    PrefUtil.setBool('enbaleAutoCheckUpdate', _enbaleAutoCheckUpdate);
    PrefUtil.setDouble('danmakuArea', _danmakuArea);
    PrefUtil.setDouble('danmakuSpeed', _danmakuSpeed);
    PrefUtil.setDouble('danmakuFontBorder', _danmakuFontBorder);
    PrefUtil.setDouble('danmakuFontSize', _danmakuFontSize);
    PrefUtil.setDouble('danmakuOpcity', _danmakuOpacity);
  }

  // Theme settings

  // Custom settings
  String _bilibiliCustomCookie = '';
  String get bilibiliCustomCookie => _bilibiliCustomCookie;
  set bilibiliCustomCookie(value) {
    _bilibiliCustomCookie = value;
    _saveToPref();
    notifyListeners();
  }

  bool _enbaleAutoCheckUpdate = true;
  bool get enbaleAutoCheckUpdate => _enbaleAutoCheckUpdate;
  set enbaleAutoCheckUpdate(value) {
    _enbaleAutoCheckUpdate = value;
    _saveToPref();
    notifyListeners();
  }

  // Danmaku settings
  double _danmakuArea = 0.5;
  double _danmakuSpeed = 8;
  double _danmakuFontBorder = 0.8;
  double _danmakuFontSize = 16;
  double _danmakuOpacity = 1;

  double get danmakuArea => _danmakuArea;
  set danmakuArea(value) {
    if (value < 0 || value > 1) return;
    _danmakuArea = value;
    _saveToPref();
    notifyListeners();
  }

  double get danmakuSpeed => _danmakuSpeed;
  set danmakuSpeed(value) {
    if (value < 1 || value > 20) return;
    _danmakuSpeed = value;
    _saveToPref();
    notifyListeners();
  }

  double get danmakuFontBorder => _danmakuFontBorder;
  set danmakuFontBorder(value) {
    if (value < 0 || value > 5) return;
    _danmakuFontBorder = value;
    _saveToPref();
    notifyListeners();
  }

  double get danmakuFontSize => _danmakuFontSize;
  set danmakuFontSize(value) {
    if (value < 10 || value > 30) return;
    _danmakuFontSize = value;
    _saveToPref();
    notifyListeners();
  }

  double get danmakuOpacity => _danmakuOpacity;
  set danmakuOpacity(value) {
    if (value < 0 || value > 1) return;
    _danmakuOpacity = value;
    _saveToPref();
    notifyListeners();
  }
}
