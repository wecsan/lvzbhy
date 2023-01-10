import 'package:flutter/cupertino.dart';
import 'package:flutter_barrage/flutter_barrage.dart';
import 'package:ice_live_viewer/model/liveroom.dart';

import 'bilibilianmaku.dart';
import 'douyudanmaku.dart';
import 'huyadanmaku.dart';

class DanmakuListView extends StatelessWidget {
  final RoomInfo room;
  final BarrageWallController barrageController;

  const DanmakuListView(
      {Key? key, required this.room, required this.barrageController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (room.platform) {
      case 'bilibili':
        return BilibiliDanmakuListView(
          roomId: int.parse(room.roomId),
          barrageController: barrageController,
        );
      case 'douyu':
        return DouYuDanmakuListView(
          roomId: int.parse(room.roomId),
          barrageController: barrageController,
        );
      case 'huya':
        return HuyaDanmakuListView(
          danmakuId: room.huyaDanmakuId,
          barrageController: barrageController,
        );
      default:
        return Container();
    }
  }
}
