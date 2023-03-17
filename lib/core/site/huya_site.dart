import 'dart:convert';
import 'dart:developer';
import 'package:pure_live/common/index.dart';
import 'package:http/http.dart' as http;

import '../danmaku/huya_danmaku.dart';
import '../interface/live_danmaku.dart';
import '../interface/live_site.dart';

class HuyaSite implements LiveSite {
  @override
  String id = 'huya';

  @override
  String name = '虎牙';

  @override
  LiveDanmaku getDanmaku() => HuyaDanmaku();

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

  @override
  Future<Map<String, List<String>>> getLiveStream(LiveRoom room) async {
    Map<String, List<String>> links = {};

    String url = 'https://mp.huya.com/cache.php?m=Live'
        '&do=profileRoom&roomid=${room.roomId}';

    try {
      dynamic response = await _getJson(url);
      if (response['status'] == 200) {
        Map data = response['data']['stream']['flv'];

        // 获取支持的分辨率
        Map<String, String> rates = {};
        for (var rate in data['rateArray']) {
          String bitrate = rate['iBitRate'].toString();
          rates[rate['sDisplayName']] = '_$bitrate';
        }

        // 获取支持的线路
        links['原画'] = [];
        for (var item in data['multiLine']) {
          String url = (item['url']).replaceAll('http://', 'https://');
          links['原画']?.add(url);
          for (var name in rates.keys) {
            links[name] ??= [];
            links[name]?.add(
                url.replaceAll('imgplus.flv', 'imgplus${rates[name]!}.flv'));
          }
        }
      }
    } catch (e) {
      log(e.toString(), name: 'HuyaApi.getRoomStreamLink');
      return links;
    }
    return links;
  }

  @override
  Future<LiveRoom> getRoomInfo(LiveRoom room) async {
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
        room.watching = data['liveData']?['attendeeCount']?.toString() ?? '';
        room.followers = data['liveData']?['totalCount']?.toString() ?? '';

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
      log(e.toString(), name: 'HuyaApi.getRoomInfo');
      return room;
    }
    return room;
  }

  @override
  Future<List<LiveRoom>> getRecommend({int page = 1, int size = 20}) async {
    List<LiveRoom> list = [];

    page--;
    int realPage = page ~/ 6 + 1;
    if (size == 10) realPage = page ~/ 12 + 1;
    String url = 'https://www.huya.com/cache.php?m=LiveList'
        '&do=getLiveListByPage&tagAll=0&page=$realPage';

    try {
      dynamic response = await _getJson(url);
      if (response['status'] == 200) {
        List<dynamic> roomInfoList = response['data']['datas'];
        for (var roomInfo in roomInfoList) {
          LiveRoom room = LiveRoom(roomInfo['profileRoom'].toString());
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
      log(e.toString(), name: 'HuyaApi.getRecommend');
      return list;
    }
    return list;
  }

  @override
  Future<List<List<LiveArea>>> getAreaList() async {
    List<List<LiveArea>> areaList = [];
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
        List<LiveArea> subAreaList = [];
        List<dynamic> areaInfoList = response['gameList'];
        for (var areaInfo in areaInfoList) {
          LiveArea area = LiveArea();
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
      log(e.toString(), name: 'HuyaApi.getAreaList');
      return areaList;
    }
    return areaList;
  }

  @override
  Future<List<LiveRoom>> getAreaRooms(LiveArea area,
      {int page = 1, int size = 20}) async {
    List<LiveRoom> list = [];

    page--;
    int realPage = page ~/ 6 + 1;
    if (size == 10) realPage = page ~/ 12 + 1;
    String url = 'https://www.huya.com/cache.php?m=LiveList'
        '&do=getLiveListByPage&gameId=${area.areaId}&tagAll=0&page=$realPage';

    try {
      dynamic response = await _getJson(url);
      if (response['status'] == 200) {
        List<dynamic> roomInfoList = response['data']['datas'];
        for (var roomInfo in roomInfoList) {
          LiveRoom room = LiveRoom(roomInfo['profileRoom'].toString());
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
      log(e.toString(), name: 'HuyaApi.getAreaRooms');
      return list;
    }
    return list;
  }

  @override
  Future<List<LiveRoom>> search(String keyWords) async {
    List<LiveRoom> list = [];
    String url = 'https://search.cdn.huya.com/?m=Search&do=getSearchContent&'
        'q=$keyWords&uid=0&v=4&typ=-5&livestate=0&rows=5&start=0';

    try {
      dynamic response = await _getJson(url);
      List<dynamic> ownerList = response['response']['1']['docs'];
      for (Map ownerInfo in ownerList) {
        LiveRoom owner = LiveRoom(ownerInfo['room_id'].toString());
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
      log(e.toString(), name: 'HuyaApi.search');
      return list;
    }
    return list;
  }
}
