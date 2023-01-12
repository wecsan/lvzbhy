import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  SettingsProvider() {
    load();
  }

  late SharedPreferences prefs;

  void load() async {
    prefs = await SharedPreferences.getInstance();
    _danmakuArea = prefs.getDouble('danmakuArea') ?? 0.5;
    _danmakuSpeed = prefs.getDouble('danmakuSpeed') ?? 8;
    _danmakuFontBorder = prefs.getDouble('danmakuFontBorder') ?? 0.8;
    _danmakuFontSize = prefs.getDouble('danmakuFontSize') ?? 16;
    _danmakuOpcity = prefs.getDouble('danmakuOpcity') ?? 1.0;
  }

  void save() {
    prefs.setDouble('danmakuArea', _danmakuArea);
    prefs.setDouble('danmakuSpeed', _danmakuSpeed);
    prefs.setDouble('danmakuFontBorder', _danmakuFontBorder);
    prefs.setDouble('danmakuFontSize', _danmakuFontSize);
    prefs.setDouble('danmakuOpcity', _danmakuOpcity);
  }

  // Danmaku settings
  double _danmakuArea = 0.5;
  double _danmakuSpeed = 8;
  double _danmakuFontBorder = 0.8;
  double _danmakuFontSize = 16;
  double _danmakuOpcity = 1;

  double get danmakuArea => _danmakuArea;
  set danmakuArea(value) {
    if (value < 0 || value > 1) return;
    _danmakuArea = value;
    save();
    notifyListeners();
  }

  double get danmakuSpeed => _danmakuSpeed;
  set danmakuSpeed(value) {
    if (value < 1 || value > 20) return;
    _danmakuSpeed = value;
    save();
    notifyListeners();
  }

  double get danmakuFontBorder => _danmakuFontBorder;
  set danmakuFontBorder(value) {
    if (value < 0 || value > 5) return;
    _danmakuFontBorder = value;
    save();
    notifyListeners();
  }

  double get danmakuFontSize => _danmakuFontSize;
  set danmakuFontSize(value) {
    if (value < 10 || value > 30) return;
    _danmakuFontSize = value;
    save();
    notifyListeners();
  }

  double get danmakuOpcity => _danmakuOpcity;
  set danmakuOpcity(value) {
    if (value < 0 || value > 1) return;
    _danmakuOpcity = value;
    save();
    notifyListeners();
  }
}
