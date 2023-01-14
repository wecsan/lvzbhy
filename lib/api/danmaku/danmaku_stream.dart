import 'dart:async';

import 'package:hot_live/model/danmaku.dart';
import 'package:hot_live/model/liveroom.dart';

import 'bilibili.dart';
import 'douyu.dart';
import 'huya.dart';

class DanmakuStream {
  final RoomInfo room;
  final StreamController<DanmakuInfo> _controller =
      StreamController.broadcast(sync: true);
  late final dynamic _damakuStream;

  Stream<DanmakuInfo> get stream => _controller.stream;

  DanmakuStream({required this.room}) {
    switch (room.platform) {
      case 'bilibili':
        _damakuStream = BilibiliDanmaku(
          danmakuId: int.parse(room.roomId),
          controller: _controller,
        );
        break;
      case 'douyu':
        _damakuStream = DouyuDanmaku(
          danmakuId: int.parse(room.roomId),
          controller: _controller,
        );
        break;
      case 'huya':
        _damakuStream = HuyaDanmaku(
          danmakuId: int.parse(room.danmakuId),
          controller: _controller,
        );
        break;
    }
  }

  void listen(void Function(DanmakuInfo)? onData) {
    stream.listen(onData);
  }

  void dispose() {
    _controller.close();
    _damakuStream.dispose();
  }
}
