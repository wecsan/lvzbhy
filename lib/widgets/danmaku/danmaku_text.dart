import 'package:flutter/material.dart';
import 'package:hot_live/provider/settings_provider.dart';
import 'package:provider/provider.dart';

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
