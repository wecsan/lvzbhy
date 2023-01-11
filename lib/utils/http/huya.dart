import 'dart:convert';
import 'package:ice_live_viewer/model/livearea.dart';
import 'package:ice_live_viewer/model/liveroom.dart';
import 'package:ice_live_viewer/utils/prefs_helper.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

class HuyaApi {
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

  static String profileUrl =
      'https://mp.huya.com/cache.php?m=Live&do=profileRoom&roomid=';

  static Future<String> fixRoomId(String notDigitRoomId) async {
    var resp = await http.get(
      Uri.parse('https://m.huya.com/$notDigitRoomId'),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (iPhone; CPU iPhone OS 12_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148'
      },
    );
    String value = resp.body;
    var dataLive = parse(value);
    var body = dataLive.getElementsByTagName('body')[0];
    var script = body.getElementsByTagName('script')[3];
    String json = script.text.replaceAll('window.HNF_GLOBAL_INIT = ', '');
    return jsonDecode(json)['roomInfo']['tProfileInfo']['lProfileRoom']
        .toString();
  }

  static String getRoomId(String url) {
    String path = url.split("/").last;
    for (var i = 0; i < path.length; i++) {
      if (path[i] == "?") {
        return path.substring(0, i);
      }
    }
    return path;
  }

  static Future<Map<String, dynamic>> getRoomStreamLink(RoomInfo room) async {
    Map<String, dynamic> links = {};

    String url =
        'https://mp.huya.com/cache.php?m=Live&do=profileRoom&roomid=${room.roomId}';
    dynamic response = await _getJson(url);
    if (response["status"] == 200) {
      dynamic roomInfo = response['data'];
      bool useCustomResolution = PrefsHelper.getUseCustomResolutionPref();
      Map streamDict = roomInfo['stream']['flv'];
      List multiLine = streamDict['multiLine'];
      List rateArray = streamDict['rateArray'];
      Map supportedResolutions = {};

      for (Map resolutions in rateArray) {
        String bitrate = resolutions['iBitRate'].toString();
        supportedResolutions[resolutions['sDisplayName']] = '_$bitrate';
      }
      Map reso = useCustomResolution
          ? {'1080P': '_4000', '720P': '_2000', '540P': '_1500'}
          : supportedResolutions;

      for (Map item in multiLine) {
        String url = item['url'];
        url = url.replaceAll('http://', 'https://');
        String cdnType = item['cdnType'];
        Map cdnLinks = {};
        cdnLinks['原画'] = url;
        for (String resolution in reso.keys) {
          String key = reso[resolution];
          String tempUrl = url.replaceAll('imgplus.flv', 'imgplus$key.flv');
          cdnLinks[resolution] = tempUrl;
        }
        links[cdnType] = cdnLinks;
      }
    }
    return links;
  }

  static Future<RoomInfo> getRoomInfo(RoomInfo room) async {
    String url =
        'https://mp.huya.com/cache.php?m=Live&do=profileRoom&roomid=${room.roomId}';

    dynamic response = await _getJson(url);

    if (response["status"] == 200) {
      dynamic roomInfo = response['data'];
      String liveStatus = roomInfo['liveStatus'];

      room.platform = 'huya';
      room.nick = roomInfo['profileInfo']['nick'];
      room.avatar = roomInfo['profileInfo']['avatar180'];
      room.title = roomInfo['liveData']['introduction'];
      if (liveStatus == 'OFF' || liveStatus == 'FREEZE') {
        room.liveStatus = LiveStatus.offline;
      } else if (liveStatus == 'REPLAY') {
        room.liveStatus = LiveStatus.replay;
      } else {
        room.liveStatus = LiveStatus.live;
        room.cover = roomInfo['liveData']['screenshot'];
        room.huyaDanmakuId = roomInfo['profileInfo']['uid'];
      }
    }
    return room;
  }

  static Future<List<RoomInfo>> getRecommend(int page, int size) async {
    List<RoomInfo> list = [];

    int realPage = page ~/ 6 + 1;
    int start = (page - 1) * size % 120;
    if (size == 10) {
      realPage = page ~/ 12 + 1;
      start = (page - 1) * size % 120;
    }

    String url =
        "https://www.huya.com/cache.php?m=LiveList&do=getLiveListByPage&tagAll=0&page=$realPage";
    dynamic response = await _getJson(url);
    if (response["status"] == 200) {
      List<dynamic> roomInfoList = response["data"]["datas"];
      for (var roomInfo in roomInfoList) {
        RoomInfo room = RoomInfo(roomInfo["profileRoom"].toString());
        room.platform = 'huya';
        room.nick = roomInfo["nick"];
        room.title = roomInfo["introduction"];
        room.cover = roomInfo["screenshot"];
        room.avatar = roomInfo["avatar180"];
        room.liveStatus = LiveStatus.live;
        list.add(room);
      }
    }
    return list;
  }

  static Future<List<List<AreaInfo>>> getAreaList() async {
    List<List<AreaInfo>> areaList = [];
    String url =
        "https://m.huya.com/cache.php?m=Game&do=ajaxGameList&bussType=";

    final areas = {
      '1': "网游竞技",
      '2': "单机热游",
      '3': "手游休闲",
      '8': "娱乐天地",
    };

    for (var typeId in areas.keys) {
      String typeName = areas[typeId]!;
      dynamic response = await _getJson(url + typeId);
      List<AreaInfo> subAreaList = [];
      List<dynamic> areaInfoList = response["gameList"];
      for (var areaInfo in areaInfoList) {
        AreaInfo area = AreaInfo();
        area.platform = "huya";
        area.areaType = typeId.toString();
        area.typeName = typeName;
        area.areaId = areaInfo["gid"].toString();
        area.areaName = areaInfo["gameFullName"];
        area.areaPic =
            "https://huyaimg.msstatic.com/cdnimage/game/${area.areaId}-MS.jpg";
        subAreaList.add(area);
      }
      areaList.add(subAreaList);
    }

    return areaList;
  }

  static Future<List<RoomInfo>> getAreaRooms(
      AreaInfo area, int page, int size) async {
    List<RoomInfo> list = [];

    int realPage = page ~/ 6 + 1;
    int start = (page - 1) * size % 120;
    if (size == 10) {
      realPage = page ~/ 12 + 1;
      start = (page - 1) * size % 120;
    }

    String url =
        "https://www.huya.com/cache.php?m=LiveList&do=getLiveListByPage&gameId=${area.areaId}&tagAll=0&page=$realPage";
    dynamic response = await _getJson(url);
    if (response["status"] == 200) {
      List<dynamic> roomInfoList = response["data"]["datas"];
      for (var roomInfo in roomInfoList) {
        RoomInfo room = RoomInfo(roomInfo["profileRoom"].toString());
        room.platform = 'huya';
        room.nick = roomInfo["nick"];
        room.title = roomInfo["introduction"];
        room.cover = roomInfo["screenshot"];
        room.avatar = roomInfo["avatar180"];
        room.liveStatus = LiveStatus.live;
        list.add(room);
      }
    }
    return list;
  }

  static Future<List<RoomInfo>> searchRoom(String platform, AreaInfo area,
      {int page = 1}) {
    throw UnimplementedError();
  }
}
