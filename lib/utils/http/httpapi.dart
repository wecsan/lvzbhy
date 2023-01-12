import 'package:hot_live/model/livearea.dart';
import 'package:hot_live/model/liveroom.dart';
import 'package:hot_live/utils/http/bilibili.dart';
import 'package:hot_live/utils/http/douyu.dart';
import 'package:hot_live/utils/http/huya.dart';

///the api interface
class HttpApi {
  static Future<Map<String, dynamic>> getRoomStreamLink(RoomInfo room) {
    switch (room.platform) {
      case "bilibili":
        return BilibiliApi.getRoomStreamLink(room);
      case 'huya':
        return HuyaApi.getRoomStreamLink(room);
      case 'douyu':
        return DouyuApi.getRoomStreamLink(room);
      default:
        return Future(() => {});
    }
  }

  static Future<RoomInfo> getRoomInfo(RoomInfo room) {
    switch (room.platform) {
      case "bilibili":
        return BilibiliApi.getRoomInfo(room);
      case 'huya':
        return HuyaApi.getRoomInfo(room);
      case 'douyu':
        return DouyuApi.getRoomInfo(room);
      default:
        return Future(() => room);
    }
  }

  static Future<List<RoomInfo>> getRecommend(String platform,
      {int page = 0, int size = 20}) {
    switch (platform) {
      case "bilibili":
        return BilibiliApi.getRecommend(page, size);
      case 'huya':
        return HuyaApi.getRecommend(page, size);
      case 'douyu':
        return DouyuApi.getRecommend(page, size);
      default:
        return Future(() => []);
    }
  }

  static Future<List<List<AreaInfo>>> getAreaList(String platform) {
    switch (platform) {
      case "bilibili":
        return BilibiliApi.getAreaList();
      case 'huya':
        return HuyaApi.getAreaList();
      case 'douyu':
        return DouyuApi.getAreaList();
      default:
        return Future(() => []);
    }
  }

  static Future<List<RoomInfo>> getAreaRooms(AreaInfo area,
      {int page = 1, int size = 20}) {
    switch (area.platform) {
      case "bilibili":
        return BilibiliApi.getAreaRooms(area, page, size);
      case 'huya':
        return HuyaApi.getAreaRooms(area, page, size);
      case 'douyu':
        return DouyuApi.getAreaRooms(area, page, size);
      default:
        return Future(() => []);
    }
  }

  static Future<List<RoomInfo>> search(String platform, String keyWords,
      {bool isLive = false}) {
    switch (platform) {
      case "bilibili":
        return BilibiliApi.search(keyWords, isLive);
      case 'huya':
        return HuyaApi.search(keyWords, isLive);
      case 'douyu':
        return DouyuApi.search(keyWords, isLive);
      default:
        return Future(() => []);
    }
  }
}
