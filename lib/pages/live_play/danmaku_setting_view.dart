import 'package:flutter/material.dart';
import 'package:hot_live/provider/settings_provider.dart';
import 'package:provider/provider.dart';

class DanmakuSettingView extends StatefulWidget {
  const DanmakuSettingView({Key? key}) : super(key: key);

  @override
  State<DanmakuSettingView> createState() => _DanmakuSettingViewState();
}

class _DanmakuSettingViewState extends State<DanmakuSettingView> {
  final double opcity = 0.7;

  @override
  Widget build(BuildContext context) {
    SettingsProvider settings = Provider.of<SettingsProvider>(context);

    final Color backgroundColor = Colors.black.withOpacity(opcity);
    final Color fontColor = Colors.white.withOpacity(opcity);
    final TextStyle labelStyle =
        Theme.of(context).textTheme.labelMedium?.copyWith(color: fontColor) ??
            TextStyle(color: fontColor);
    final TextStyle digitStyle =
        Theme.of(context).textTheme.caption?.copyWith(color: fontColor) ??
            TextStyle(color: fontColor);

    return AlertDialog(
      backgroundColor: backgroundColor,
      content: Column(
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
    );
  }
}
