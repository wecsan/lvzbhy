import 'package:flutter/cupertino.dart';
import 'package:hot_live/model/danmaku.dart';
import 'package:hot_live/model/liveroom.dart';
import 'package:hot_live/utils/danmaku/bilibili_danmaku.dart';
import 'package:hot_live/utils/danmaku/douyu_danmaku.dart';
import 'package:hot_live/utils/danmaku/huya_danmaku.dart';

class DanmakuStream with ChangeNotifier {
  final RoomInfo room;
  late final dynamic _damakuSteam;

  DanmakuStream({required this.room}) {
    switch (room.platform) {
      case 'bilibili':
        _damakuSteam = BilibiliDanmakuStream(danmakuId: int.parse(room.roomId));
        break;
      case 'douyu':
        _damakuSteam = DouyuDanmakuSteam(danmakuId: int.parse(room.roomId));
        break;
      case 'huya':
        _damakuSteam = HuyaDanmakuStream(danmakuId: room.huyaDanmakuId);
        break;
    }
  }

  void setDanmakuListener(void Function(DanmakuInfo)? onData) {
    _damakuSteam.setDanmakuListener(onData);
  }

  @override
  void dispose() {
    _damakuSteam.dispose();
    super.dispose();
  }
}
