import 'package:flutter/material.dart';
import 'package:ice_live_viewer/provider/settings_provider.dart';
import 'package:provider/provider.dart';

class DanmakuController extends StatefulWidget {
  const DanmakuController({Key? key}) : super(key: key);

  @override
  State<DanmakuController> createState() => _DanmakuControllerState();
}

class _DanmakuControllerState extends State<DanmakuController> {
  final TextStyle fontStyle = TextStyle(color: Colors.white.withOpacity(0.8));

  @override
  Widget build(BuildContext context) {
    SettingsProvider settings = Provider.of<SettingsProvider>(context);

    return AlertDialog(
      backgroundColor: Colors.black.withOpacity(0.6),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            leading: Text('显示区域', style: fontStyle),
            title: Slider(
              value: settings.danmakuArea,
              min: 0.0,
              max: 1.0,
              onChanged: (val) => settings.danmakuArea = val,
            ),
            trailing: Text(
              settings.danmakuArea.toStringAsPrecision(2),
              style: fontStyle,
            ),
          ),
          ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            leading: Text('不透明度', style: fontStyle),
            title: Slider(
              value: settings.danmakuOpcity,
              min: 0.0,
              max: 1.0,
              onChanged: (val) => settings.danmakuOpcity = val,
            ),
            trailing: Text(
              settings.danmakuOpcity.toStringAsPrecision(2),
              style: fontStyle,
            ),
          ),
          ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            leading: Text('弹幕速度', style: fontStyle),
            title: Slider(
              value: settings.danmakuSpeed,
              min: 1.0,
              max: 20.0,
              onChanged: (val) => settings.danmakuSpeed = val,
            ),
            trailing: Text(
              settings.danmakuSpeed.toStringAsPrecision(2),
              style: fontStyle,
            ),
          ),
          ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            leading: Text('弹幕字号', style: fontStyle),
            title: Slider(
              value: settings.danmakuFontSize,
              min: 10.0,
              max: 40.0,
              onChanged: (val) => settings.danmakuFontSize = val,
            ),
            trailing: Text(
              settings.danmakuFontSize.toStringAsPrecision(2),
              style: fontStyle,
            ),
          ),
        ],
      ),
    );
  }
}
