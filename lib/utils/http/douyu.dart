import 'dart:convert';
import 'package:ice_live_viewer/model/livearea.dart';
import 'package:ice_live_viewer/model/liveroom.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:ice_live_viewer/utils/linkparser.dart';

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

  static String _generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  static Future<Map> _getRoomBasicInfo(RoomInfo room) async {
    var resp = await http.get(
        Uri.parse('https://open.douyucdn.cn/api/RoomApi/room/${room.roomId}'));
    var body = json.decode(resp.body);
    if (resp.statusCode == 200) {
      if (body['error'] == 0) {
        Map data = body['data'];
        data['gift'] = [];
        return data;
      } else if (body['error'] == 101) {
        throw Exception([body['data'], body['error'], resp.statusCode]);
      } else {
        //return {'error': body};
        throw Exception([body, resp.statusCode]);
      }
    } else {
      //return {'error': body};
      throw Exception([body, resp.statusCode]);
    }
  }

  static Future<String> fixErrorroomId(String wrongroomId) async {
    var resp =
        await http.get(Uri.parse('https://m.douyu.com/$wrongroomId'), headers: {
      'User-Agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 12_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148'
    });
    String body = resp.body;
    if (resp.body.contains('不存在')) {
      throw Exception(
          '不能修复信息，因为房间信息不存在\nThe room number cannot be fixed because the room information does not exist.');
    } else {
      RegExpMatch? match = RegExp(r'rid":(\d{1,8}),"vipId').firstMatch(body);
      String? rightroomId = match?.group(1);
      return rightroomId!;
    }
  }

  static Future<String> verifyLink(String link) async {
    return fixErrorroomId(LinkParser.getRoomId(link));
  }

  static Future<Map<String, dynamic>> getRoomStreamLink(RoomInfo room) async {
    Map<String, dynamic> links = {'hw': {}, 'ws': {}, 'akm': {}};
    String url =
        'https://playweb.douyucdn.cn/lapi/live/hlsH5Preview/${room.roomId}';

    String time = ((DateTime.now().millisecondsSinceEpoch) * 1000).toString();
    String sign = _generateMd5('${room.roomId}$time');
    Map<String, String> headers = {
      'rid': room.roomId,
      'time': time,
      'auth': sign
    };
    Map data = {'rid': room.roomId, 'did': '10000000000000000000000000001501'};

    try {
      Map info = {};
      var resp = await http.post(Uri.parse(url), headers: headers, body: data);
      var body = json.decode(resp.body);
      if (body['error'] == 0) {
        String rtmpLive = body['data']['rtmp_live'];
        RegExpMatch? match =
            RegExp(r'(\d{1,8}[0-9a-zA-Z]+)_?\d{0,4}(/playlist|.m3u8)')
                .firstMatch(rtmpLive);
        String? key = match?.group(1);
        info = {'error': 0, 'key': key, 'msg': rtmpLive, 'data': body['data']};
      } else {
        info = {'error': 104, 'msg': '房间不存在'};
      }

      if (info['error'] == 0 || info['error'] == 104) {
        String key = info['key'];
        for (String cdn in links.keys) {
          links[cdn]['原画'] = 'https://$cdn-tct.douyucdn.cn/live/$key.flv?uuid=';
          links[cdn]['流畅'] =
              'https://$cdn-tct.douyucdn.cn/live/${key}_900.flv?uuid=';
        }
      }
    } catch (e) {
      return links;
    }

    return links;
  }

  static Future<RoomInfo> getRoomInfo(RoomInfo room) async {
    Map roomBasicInfo = await _getRoomBasicInfo(room);
    dynamic liveStatus = roomBasicInfo['room_status'];
    Map<String, dynamic> data = {
      'name': roomBasicInfo['owner_name'],
      'avatar': roomBasicInfo['avatar'],
      'title': roomBasicInfo['room_name'],
      'cover': roomBasicInfo['room_thumb'],
      'id': roomBasicInfo['room_id'],
      'startTime': roomBasicInfo['start_time'],
    };
    room.nick = data['name'];
    room.title = data['title'];
    room.avatar = data['avatar'];
    room.cover = data['cover'];
    room.liveStatus = liveStatus == '1' ? LiveStatus.live : LiveStatus.offline;
    return room;
  }

  static Future<List<RoomInfo>> getRecommend(int page, int size) async {
    List<RoomInfo> list = [];

    int start = size * (page - 1) ~/ 8 + ((size * (page - 1) % 8 == 0) ? 0 : 1);
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
          room.nick = roomInfo["nickname"];
          room.title = roomInfo["roomName"];
          room.cover = roomInfo["roomSrc"];
          room.avatar = roomInfo["avatar"];
          room.liveStatus = LiveStatus.live;
          list.add(room);
        }
      }
    }
    return list;
  }

  static Future<List<List<AreaInfo>>> getAreaList() async {
    List<List<AreaInfo>> areaList = [];
    Map<String, String> cate1Map = {};
    Map<String, List<AreaInfo>> cate2Map = {};
    String url = "https://m.douyu.com/api/cate/list";

    dynamic response = await _getJson(url);
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
        area.areaId = areaInfo["cate2Id"].toString();
        area.areaName = areaInfo["cate2Name"];
        area.areaPic = areaInfo["pic"];
        area.shortName = areaInfo["shortName"];

        cate2Map[typeId]?.add(area);
      }
    }

    cate2Map.forEach((key, value) {
      if (value.isNotEmpty) areaList.add(value);
    });
    return areaList;
  }

  static Future<List<RoomInfo>> getAreaRooms(
      AreaInfo area, int page, int size) async {
    List<RoomInfo> list = [];

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
          room.nick = roomInfo["nickname"];
          room.title = roomInfo["roomName"];
          room.cover = roomInfo["roomSrc"];
          room.avatar = roomInfo["avatar"];
          room.liveStatus = LiveStatus.live;
          list.add(room);
        }
      }
    }
    return list;
  }

  static Future<List<RoomInfo>> search(String keyWords, bool isLive) async {
    List<RoomInfo> list = [];
    String url = "https://www.douyu.com/japi/search/api/searchAnchor?kw=" +
        const Utf8Encoder().convert(keyWords).toString() +
        "&page=1&pageSize=5&filterType=${isLive ? 1 : 0}";

    dynamic response = await _getJson(url);
    if (response["error"] == 0) {
      List<dynamic> ownerList = response["data"]["relateAnchor"];
      for (var ownerInfo in ownerList) {
        RoomInfo owner = RoomInfo(ownerInfo['rid'].toString());
        owner.platform = "douyu";
        owner.nick = ownerInfo["nickName"];
        owner.areaName = ownerInfo["cateName"];
        owner.avatar = ownerInfo["avatar"];
        owner.liveStatus =
            ownerInfo["isLive"] == 1 ? LiveStatus.live : LiveStatus.offline;
        list.add(owner);
      }
    }
    return list;
  }
}
