import 'package:ice_live_viewer/model/liveroom.dart';
import 'package:ice_live_viewer/utils/http/bilibili.dart';
import 'package:ice_live_viewer/utils/http/douyu.dart';
import 'package:ice_live_viewer/utils/http/huya.dart';

///the api interface
class HttpApi {
  static Future<RoomInfo> getLiveInfo(RoomInfo room) {
    switch (room.platform) {
      case "bilibili":
        return BilibiliApi.getRoomFullInfo(room);
      case 'huya':
        return HuyaApi.getLiveInfo(room.link);
      case 'douyu':
        return DouyuApi.getRoomFullInfo(room);
      default:
        return Future(() => room);
    }
  }
}
