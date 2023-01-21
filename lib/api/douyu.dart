import 'dart:convert';
import 'dart:developer';
import 'package:hot_live/model/livearea.dart';
import 'package:hot_live/model/liveroom.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class DouyuApi {
  static Future<dynamic> _getJson(String url) async {
    var resp = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (iPhone; CPU iPhone OS 12_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148'
      },
    );
    return await jsonDecode(resp.body);
  }

  static Future<Map<String, Map<String, String>>> getRoomStreamLink(
      RoomInfo room) async {
    Map<String, Map<String, String>> links = {};

    String url =
        'https://playweb.douyucdn.cn/lapi/live/hlsH5Preview/${room.roomId}';

    try {
      String time = ((DateTime.now().millisecondsSinceEpoch) * 1000).toString();
      String sign = md5.convert(utf8.encode('${room.roomId}$time')).toString();
      Map<String, String> headers = {
        'rid': room.roomId,
        'time': time,
        'auth': sign
      };
      Map data = {
        'rid': room.roomId,
        'did': '10000000000000000000000000001501'
      };
      var resp = await http.post(Uri.parse(url), headers: headers, body: data);
      var body = json.decode(resp.body);
      if (body['error'] == 0) {
        String rtmpLive = body['data']['rtmp_live'];
        RegExpMatch? match =
            RegExp(r'(\d{1,8}[0-9a-zA-Z]+)_?\d{0,4}(/playlist|.m3u8)')
                .firstMatch(rtmpLive);
        String? key = match?.group(1);

        // add stream links
        Map<String, String> resolutions = {
          '原画': '',
          '蓝光8M': '_2000',
          '蓝光4M': '_1500',
          '超清': '_1200',
          '流畅': '_900',
        };
        List<String> cdns = ['hw', 'ws', 'akm'];
        for (String res in resolutions.keys) {
          String v = resolutions[res]!;
          links[res] = {};
          for (String cdn in cdns) {
            links[res]![cdn] =
                'https://$cdn-tct.douyucdn.cn/live/$key$v.flv?uuid=';
          }
        }
      }
    } catch (e) {
      log(e.toString(), name: 'DouyuApi.getRoomStreamLink');
      return links;
    }
    return links;
  }

  static Future<RoomInfo> getRoomInfo(RoomInfo room) async {
    try {
      dynamic body = await _getJson(
          'https://open.douyucdn.cn/api/RoomApi/room/${room.roomId}');
      if (body['error'] == 0) {
        Map data = body['data'];
        room.nick = data['owner_name'] ?? '';
        room.title = data['room_name'] ?? '';
        room.avatar = data['avatar'] ?? '';
        room.cover = data['room_thumb'] ?? '';
        room.area = data['cate_name'] ?? '';
        room.watching = data['hn']?.toString() ?? '';
        room.liveStatus =
            (data.containsKey('room_status') && data['room_status'] == '1')
                ? LiveStatus.live
                : LiveStatus.offline;
      }
      // fix douyu replay status
      try {
        dynamic body = await _getJson(
            'https://www.douyu.com/wgapi/live/liveweb/getRoomLoopInfo?rid=${room.roomId}');
        if (body['error'] == 0) {
          Map data = body['data'];
          if (data.containsKey('rst') && data['rst'] == 3) {
            room.liveStatus = LiveStatus.replay;
          }
        }
      } catch (e) {
        log(e.toString(), name: 'DouyuApi.getRoomInfo.rstinfo');
      }
    } catch (e) {
      log(e.toString(), name: 'DouyuApi.getRoomInfo');
      return room;
    }
    return room;
  }

  static Future<List<RoomInfo>> getRecommend(int page, int size) async {
    List<RoomInfo> list = [];

    try {
      int start =
          size * (page - 1) ~/ 8 + ((size * (page - 1) % 8 == 0) ? 0 : 1);
      start = (start == 0) ? 1 : start;
      int end = size * (page) ~/ 8 + ((size * (page) % 8 == 0) ? 0 : 1);

      for (int i = start; i <= end; i++) {
        String url = "https://m.douyu.com/api/room/list?page=$i&type=";
        dynamic response = await _getJson(url);
        dynamic result = response["data"];
        if (response["code"] == 0) {
          List<dynamic> roomInfoList = result["list"];
          for (var roomInfo in roomInfoList) {
            RoomInfo room = RoomInfo(roomInfo["rid"].toString());
            room.platform = 'douyu';
            room.nick = roomInfo["nickname"] ?? '';
            room.title = roomInfo["roomName"] ?? '';
            room.cover = roomInfo["roomSrc"] ?? '';
            room.avatar = roomInfo["avatar"] ?? '';
            room.watching = roomInfo["hn"] ?? '';
            room.liveStatus =
                (roomInfo.containsKey("isLive") && roomInfo["isLive"] == 1)
                    ? LiveStatus.live
                    : LiveStatus.offline;
            list.add(room);
          }
        }
      }
    } catch (e) {
      log(e.toString(), name: 'DouyuApi.getRecommend');
      return list;
    }
    return list;
  }

  static Future<List<List<AreaInfo>>> getAreaList() async {
    List<List<AreaInfo>> areaList = [];
    String url = "https://m.douyu.com/api/cate/list";

    try {
      dynamic response = await _getJson(url);
      Map<String, String> cate1Map = {};
      Map<String, List<AreaInfo>> cate2Map = {};
      if (response["code"] == 0) {
        List<dynamic> cate1InfoList = response["data"]["cate1Info"];
        for (var element in cate1InfoList) {
          String cate1Name = element["cate1Name"];
          String cate1Id = element["cate1Id"].toString();
          cate1Map[cate1Id] = cate1Name;
          cate2Map[cate1Id] = [];
        }

        List<dynamic> areaInfoList = response["data"]["cate2Info"];
        for (var areaInfo in areaInfoList) {
          final typeId = areaInfo["cate1Id"].toString();
          if ("21" == typeId || !cate1Map.containsKey(typeId)) {
            continue;
          }

          AreaInfo area = AreaInfo();
          area.areaType = typeId;
          area.typeName = cate1Map[typeId]!;

          area.platform = "douyu";
          area.areaId = areaInfo["cate2Id"]?.toString() ?? '';
          area.areaName = areaInfo["cate2Name"] ?? '';
          area.areaPic = areaInfo["pic"] ?? '';
          area.shortName = areaInfo["shortName"] ?? '';

          cate2Map[typeId]?.add(area);
        }
      }

      cate2Map.forEach((key, value) {
        if (value.isNotEmpty) areaList.add(value);
      });
    } catch (e) {
      log(e.toString(), name: 'DouyuApi.getAreaList');
      return areaList;
    }
    return areaList;
  }

  static Future<List<RoomInfo>> getAreaRooms(
      AreaInfo area, int page, int size) async {
    List<RoomInfo> list = [];

    try {
      int start = size * (page - 1) ~/ 8 + 1;
      start = (start == 0) ? 1 : start;
      int end = size * page ~/ 8 + ((size * (page) % 8 == 0) ? 0 : 1);

      for (int i = start; i <= end; i++) {
        String url =
            "https://m.douyu.com/api/room/list?page=$i&type=${area.shortName}";
        dynamic response = await _getJson(url);
        dynamic result = response["data"];
        if (response["code"] == 0) {
          List<dynamic> roomInfoList = result["list"];
          for (var roomInfo in roomInfoList) {
            RoomInfo room = RoomInfo(roomInfo["rid"].toString());
            room.platform = 'douyu';
            room.nick = roomInfo["nickname"] ?? '';
            room.title = roomInfo["roomName"] ?? '';
            room.cover = roomInfo["roomSrc"] ?? '';
            room.avatar = roomInfo["avatar"] ?? '';
            room.area = area.areaName;
            room.watching = roomInfo["hn"] ?? '';
            room.liveStatus =
                (roomInfo.containsKey("isLive") && roomInfo["isLive"] == 1)
                    ? LiveStatus.live
                    : LiveStatus.offline;
            list.add(room);
          }
        }
      }
    } catch (e) {
      log(e.toString(), name: 'DouyuApi.getAreaRooms');
      return list;
    }
    return list;
  }

  static Future<List<RoomInfo>> search(String keyWords) async {
    List<RoomInfo> list = [];
    String url = "https://m.douyu.com/api/search/anchor";

    try {
      Map<String, String> headers = {
        'User-Agent':
            'Mozilla/5.0 (iPhone; CPU iPhone OS 12_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148',
        'Content-Type': 'application/json',
      };
      Map data = {
        "sk": keyWords,
        "offset": 0,
        "limit": 20,
      };
      dynamic resp = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );
      dynamic response = jsonDecode(resp.body);
      if (response["error"] == 0) {
        List<dynamic> ownerList = response["data"]["list"];
        for (var ownerInfo in ownerList) {
          RoomInfo owner = RoomInfo(ownerInfo['roomId'].toString());
          owner.platform = "douyu";
          owner.userId = ownerInfo['ownerUID']?.toString() ?? '';
          owner.nick = ownerInfo["nickname"] ?? '';
          owner.title = ownerInfo["roomName"] ?? '';
          owner.cover = ownerInfo["roomSrc"] ?? '';
          owner.avatar = ownerInfo["avatar"] ?? '';
          owner.area = ownerInfo["cateName"] ?? '';
          owner.watching = ownerInfo["hn"] ?? '';
          owner.liveStatus =
              (ownerInfo.containsKey("isLive") && ownerInfo["isLive"] == 1)
                  ? LiveStatus.live
                  : LiveStatus.offline;
          list.add(owner);
        }
      }
    } catch (e) {
      log(e.toString(), name: 'DouyuApi.search');
      return list;
    }
    return list;
  }
}
