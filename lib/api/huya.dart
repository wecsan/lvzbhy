import 'dart:convert';
import 'package:hot_live/model/livearea.dart';
import 'package:hot_live/model/liveroom.dart';
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

  static Future<Map<String, Map<String, String>>> getRoomStreamLink(
      RoomInfo room) async {
    Map<String, Map<String, String>> links = {};

    String url = 'https://mp.huya.com/cache.php?m=Live'
        '&do=profileRoom&roomid=${room.roomId}';

    try {
      dynamic response = await _getJson(url);
      if (response['status'] == 200) {
        Map streamDict = response['data']['stream']['flv'];

        // 获取支持的分辨率
        Map resolutions = {};
        List rateArray = streamDict['rateArray'];
        for (Map res in rateArray) {
          String bitrate = res['iBitRate'].toString();
          resolutions[res['sDisplayName']] = '_$bitrate';
        }

        // 获取支持的线路
        List multiLine = streamDict['multiLine'];
        links['原画'] = {};
        for (Map item in multiLine) {
          String url = (item['url']).replaceAll('http://', 'https://');
          String cdn = item['cdnType'];
          links['原画']![cdn] = url;
          for (var resolution in resolutions.keys) {
            String key = resolutions[resolution];
            String tempUrl = url.replaceAll('imgplus.flv', 'imgplus$key.flv');
            if (links[resolution] == null) links[resolution] = {};
            links[resolution]![cdn] = tempUrl;
          }
        }
      }
    } catch (e) {
      return links;
    }
    return links;
  }

  static Future<RoomInfo> getRoomInfo(RoomInfo room) async {
    String url = 'https://mp.huya.com/cache.php?m=Live'
        '&do=profileRoom&roomid=${room.roomId}';

    try {
      dynamic response = await _getJson(url);
      if (response['status'] == 200) {
        dynamic data = response['data'];

        room.platform = 'huya';
        room.userId = data['profileInfo']?['uid']?.toString() ?? '';
        room.nick = data['profileInfo']?['nick'] ?? '';
        room.title = data['liveData']?['introduction'] ?? '';
        room.cover = data['liveData']?['screenshot'] ?? '';
        room.avatar = data['profileInfo']?['avatar180'] ?? '';
        room.area = data['liveData']?['gameFullName'] ?? '';
        room.watching = data['liveData']?['attendeeCount'] ?? '';
        room.followers = data['liveData']?['totalCount'] ?? '';

        final liveStatus = data['liveStatus'] ?? 'OFF';
        if (liveStatus == 'OFF' || liveStatus == 'FREEZE') {
          room.liveStatus = LiveStatus.offline;
        } else if (liveStatus == 'REPLAY') {
          room.liveStatus = LiveStatus.replay;
        } else {
          room.liveStatus = LiveStatus.live;
        }
      }
    } catch (e) {
      return room;
    }
    return room;
  }

  static Future<List<RoomInfo>> getRecommend(int page, int size) async {
    List<RoomInfo> list = [];

    int realPage = page ~/ 6 + 1;
    if (size == 10) realPage = page ~/ 12 + 1;
    String url = 'https://www.huya.com/cache.php?m=LiveList'
        '&do=getLiveListByPage&tagAll=0&page=$realPage';

    try {
      dynamic response = await _getJson(url);
      if (response['status'] == 200) {
        List<dynamic> roomInfoList = response['data']['datas'];
        for (var roomInfo in roomInfoList) {
          RoomInfo room = RoomInfo(roomInfo['profileRoom'].toString());
          room.platform = 'huya';
          room.userId = roomInfo['uid']?.toString() ?? '';
          room.nick = roomInfo['nick'] ?? '';
          room.title = roomInfo['introduction'] ?? '';
          room.cover = roomInfo['screenshot'] ?? '';
          room.avatar = roomInfo['avatar180'] ?? '';
          room.area = roomInfo['gameFullName'] ?? '';
          room.followers = roomInfo['totalCount'] ?? '';
          room.liveStatus = LiveStatus.live;
          list.add(room);
        }
      }
    } catch (e) {
      return list;
    }
    return list;
  }

  static Future<List<List<AreaInfo>>> getAreaList() async {
    List<List<AreaInfo>> areaList = [];
    String url =
        'https://m.huya.com/cache.php?m=Game&do=ajaxGameList&bussType=';

    final areas = {
      '1': '网游竞技',
      '2': '单机热游',
      '3': '手游休闲',
      '8': '娱乐天地',
    };
    try {
      for (var typeId in areas.keys) {
        String typeName = areas[typeId]!;
        dynamic response = await _getJson(url + typeId);
        List<AreaInfo> subAreaList = [];
        List<dynamic> areaInfoList = response['gameList'];
        for (var areaInfo in areaInfoList) {
          AreaInfo area = AreaInfo();
          area.platform = 'huya';
          area.areaType = typeId;
          area.typeName = typeName;
          area.areaId = areaInfo['gid']?.toString() ?? '';
          area.areaName = areaInfo['gameFullName'] ?? '';
          area.areaPic =
              'https://huyaimg.msstatic.com/cdnimage/game/${area.areaId}-MS.jpg';
          subAreaList.add(area);
        }
        areaList.add(subAreaList);
      }
    } catch (e) {
      return areaList;
    }
    return areaList;
  }

  static Future<List<RoomInfo>> getAreaRooms(
    AreaInfo area,
    int page,
    int size,
  ) async {
    List<RoomInfo> list = [];

    int realPage = page ~/ 6 + 1;
    if (size == 10) realPage = page ~/ 12 + 1;
    String url = 'https://www.huya.com/cache.php?m=LiveList'
        '&do=getLiveListByPage&gameId=${area.areaId}&tagAll=0&page=$realPage';

    try {
      dynamic response = await _getJson(url);
      if (response['status'] == 200) {
        List<dynamic> roomInfoList = response['data']['datas'];
        for (var roomInfo in roomInfoList) {
          RoomInfo room = RoomInfo(roomInfo['profileRoom'].toString());
          room.platform = 'huya';
          room.userId = roomInfo['uid'] ?? '';
          room.nick = roomInfo['nick'] ?? '';
          room.title = roomInfo['introduction'] ?? '';
          room.cover = roomInfo['screenshot'] ?? '';
          room.avatar = roomInfo['avatar180'] ?? '';
          room.area = roomInfo['gameFullName'] ?? '';
          room.followers = roomInfo['totalCount'] ?? '';
          room.liveStatus = LiveStatus.live;
          list.add(room);
        }
      }
    } catch (e) {
      return list;
    }
    return list;
  }

  static Future<List<RoomInfo>> search(String keyWords) async {
    List<RoomInfo> list = [];
    String url = 'https://search.cdn.huya.com/?m=Search&do=getSearchContent&'
        'q=$keyWords&uid=0&v=4&typ=-5&livestate=0&rows=5&start=0';

    try {
      dynamic response = await _getJson(url);
      List<dynamic> ownerList = response['response']['1']['docs'];
      for (Map ownerInfo in ownerList) {
        RoomInfo owner = RoomInfo(ownerInfo['room_id'].toString());
        owner.platform = 'huya';
        owner.userId = ownerInfo['uid']?.toString() ?? '';
        owner.nick = ownerInfo['game_nick'] ?? '';
        owner.title = ownerInfo['live_intro'] ?? '';
        owner.area = ownerInfo['game_name'] ?? '';
        owner.avatar = ownerInfo['game_avatarUrl52'] ?? '';
        owner.followers = ownerInfo['game_activityCount']?.toString() ?? '';
        owner.liveStatus = (ownerInfo['gameLiveOn'] ?? false)
            ? LiveStatus.live
            : LiveStatus.offline;
        list.add(owner);
      }
    } catch (e) {
      return list;
    }
    return list;
  }
}
