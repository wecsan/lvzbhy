import 'dart:async';

import 'package:pure_live/common/models/index.dart';

import 'danmaku/bilibili.dart';
import 'danmaku/douyu.dart';
import 'danmaku/huya.dart';

class DanmakuStream {
  final RoomInfo room;
  final StreamController<DanmakuInfo> _controller =
      StreamController.broadcast(sync: true);
  late final dynamic _damakuStream;

  Stream<DanmakuInfo> get stream => _controller.stream;

  DanmakuStream({required this.room}) {
    initPlatform();
  }

  void initPlatform() {
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
          danmakuId: int.parse(room.userId),
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
