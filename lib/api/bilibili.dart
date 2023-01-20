// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:hot_live/model/livearea.dart';
import 'package:hot_live/model/liveroom.dart';
import 'package:hot_live/utils/pref_util.dart';

class BilibiliApi {
  static Future<dynamic> _getJson(String url) async {
    final cookie = PrefUtil.getString('bilibiliCustomCookie') ?? '';
    Map<String, String> _headers = {
      'User-Agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 12_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148'
    };
    if (cookie.isNotEmpty) _headers['cookie'] = cookie;

    var resp = await http.get(
      Uri.parse(url),
      headers: _headers,
    );
    return await jsonDecode(utf8.decode(resp.bodyBytes));
  }

  /// 获取直播间所有清晰度的url
  /// @param urls
  /// @param rid
  static Future<Map<String, Map<String, String>>> getRoomStreamLink(
      RoomInfo room) async {
    Map<String, Map<String, String>> links = {};

    String defaultQn = '10000';
    String newStreamUrl =
        'https://api.live.bilibili.com/xlive/web-room/v2/index/getRoomPlayInfo'
        '?room_id=${room.roomId}&qn=$defaultQn&platform=h5&ptype=8'
        '&codec=0,1&format=0,1,2&protocol=0,1';

    try {
      dynamic streamJson = await _getJson(newStreamUrl);
      List<dynamic> qualityReferenceList =
          streamJson['data']['playurl_info']['playurl']['g_qn_desc'];

      Map<int, String> qualityRefMap = {};
      for (var i = 0; i < qualityReferenceList.length; i++) {
        qualityRefMap[qualityReferenceList[i]['qn']] =
            qualityReferenceList[i]['desc'];
      }
      List<dynamic> streamMultiList =
          streamJson['data']['playurl_info']['playurl']['stream'];

      // Get m3u8 default, if not, get unplayable flv
      Map streamProtocol =
          streamMultiList[1]['format'][0] ?? streamMultiList[0]['format'][0];

      // Find the m3u8-fmp4 link
      for (int i = 0; i < streamMultiList.length; i++) {
        if (streamMultiList[i]['protocol_name'] == 'http_hls') {
          for (int j = 0; j < streamMultiList[i]['format'].length; j++) {
            if (streamMultiList[i]['format'][j]['format_name'] == 'fmp4') {
              streamProtocol = streamMultiList[i]['format'][j];
              break;
            }
          }
        }
      }

      List<dynamic> acceptQn = streamProtocol['codec'][0]['accept_qn'];
      for (int i = 0; i < acceptQn.length; i++) {
        int qn = acceptQn[i].toInt();
        String qnName = qualityRefMap[qn] ?? qn.toString();

        if (qn == 10000) {
          List urlInfo = streamProtocol['codec'][0]['url_info'];
          String baseUrl = streamProtocol['codec'][0]['base_url'];
          Map<String, String> urlMap = {};
          for (int i = 0; i < urlInfo.length; i++) {
            String finalUrl =
                urlInfo[i]['host'] + baseUrl + urlInfo[i]['extra'];
            urlMap['线路$i'] = finalUrl;
          }
          links[qnName] = urlMap;
          continue;
        }

        String qnUrl =
            'https://api.live.bilibili.com/xlive/web-room/v2/index/getRoomPlayInfo'
            '?room_id=${room.roomId}&qn=$qn&platform=h5&ptype=8'
            '&codec=0,1&format=0,1,2&protocol=0,1';
        dynamic qnJson = await _getJson(qnUrl);
        List<dynamic> qnStreamMultiList =
            qnJson['data']['playurl_info']['playurl']['stream'];

        //get m3u8 default, if not, get unplayable flv
        Map qnStreamProtocol = qnStreamMultiList[1]['format'][0] ??
            qnStreamMultiList[0]['format'][0];
        for (int i = 0; i < qnStreamMultiList.length; i++) {
          if (qnStreamMultiList[i]['protocol_name'] == 'http_hls') {
            for (int j = 0; j < qnStreamMultiList[i]['format'].length; j++) {
              if (qnStreamMultiList[i]['format'][j]['format_name'] == 'fmp4') {
                qnStreamProtocol = qnStreamMultiList[i]['format'][j];
                break;
              }
            }
          }
        }
        List urlInfo = qnStreamProtocol['codec'][0]['url_info'];
        String baseUrl = qnStreamProtocol['codec'][0]['base_url'];
        Map<String, String> urlMap = {};
        for (int i = 0; i < urlInfo.length; i++) {
          String finalUrl = urlInfo[i]['host'] + baseUrl + urlInfo[i]['extra'];
          urlMap['线路$i'] = finalUrl;
        }
        links[qnName] = urlMap;
      }
    } catch (e) {
      log(e.toString(), name: 'BilibiliApi.getRoomStreamLink');
      return links;
    }
    return links;
  }

  /// 获取单个直播间信息
  /// @param roomId 房间号
  /// @return
  static Future<RoomInfo> getRoomInfo(RoomInfo room) async {
    String reqUrl = 'https://api.live.bilibili.com/xlive/web-room/v1/index/'
        'getH5InfoByRoom?room_id=${room.roomId}';

    try {
      dynamic response = await _getJson(reqUrl);
      if (response['code'] == 0) {
        Map data = response['data'];
        room.platform = 'bilibili';
        room.title = data['room_info']?['title'] ?? '';
        room.nick = data['anchor_info']?['base_info']?['uname'] ?? '';
        room.cover = data['room_info']?['cover'] ?? '';
        room.avatar = data['anchor_info']?['base_info']?['face'] ?? '';
        room.area = data['room_info']?['area_name'] ?? '';
        room.watching = data['watched_show']?['num']?.toString() ?? '';
        room.followers =
            data['anchor_info']?['relation_info']?['attention']?.toString() ??
                '';
        room.liveStatus = (data['room_info']?.containsKey('live_status') &&
                data['room_info']?['live_status'] == 1)
            ? LiveStatus.live
            : LiveStatus.offline;
      }
    } catch (e) {
      log(e.toString(), name: 'BilibiliApi.getRoomInfo');
      return room;
    }
    return room;
  }

  /// 根据分页获取推荐直播间
  /// @param page 页数
  /// @param size 每页大小
  /// @return
  static Future<List<RoomInfo>> getRecommend(int page, int size) async {
    List<RoomInfo> list = [];
    String url = 'https://api.live.bilibili.com/room/v1/room/get_user_recommend'
        '?page=$page&page_size=$size';

    try {
      dynamic response = await _getJson(url);
      if (response['code'] == 0) {
        List<dynamic> roomList = response['data'];
        for (var roomInfo in roomList) {
          var room = RoomInfo(roomInfo['roomid'].toString());
          room.platform = 'bilibili';
          room.nick = roomInfo['uname'] ?? '';
          room.title = roomInfo['title'] ?? '';
          room.cover = roomInfo['user_cover'];
          room.avatar = roomInfo['face'];
          room.area = roomInfo['areaName'] ?? '';
          room.watching = roomInfo['watched_show']?['num']?.toString() ?? '';
          room.liveStatus = LiveStatus.live;
          list.add(room);
        }
      }
    } catch (e) {
      log(e.toString(), name: 'BilibiliApi.getRecommend');
      return list;
    }
    return list;
  }

  /// 获取bilibili所有分类
  /// @return
  static Future<List<List<AreaInfo>>> getAreaList() async {
    List<List<AreaInfo>> areaList = [];
    String url =
        'https://api.live.bilibili.com/xlive/web-interface/v1/index/getWebAreaList?source_id=2';

    try {
      dynamic response = await _getJson(url);
      if (response['code'] == 0) {
        List<dynamic> data = response['data']['data'];
        data.forEach((areaType) {
          List<AreaInfo> subAreaList = [];
          List<dynamic> areaInfoList = areaType['list'];
          areaInfoList.forEach((areaInfo) {
            AreaInfo area = AreaInfo();
            area.platform = 'bilibili';
            area.areaType = areaInfo['parent_id']?.toString() ?? '';
            area.typeName = areaInfo['parent_name'] ?? '';
            area.areaId = areaInfo['id']?.toString() ?? '';
            area.areaName = areaInfo['name'] ?? '';
            area.areaPic = areaInfo['pic'] ?? '';
            subAreaList.add(area);
          });
          areaList.add(subAreaList);
        });
      }
    } catch (e) {
      log(e.toString(), name: 'BilibiliApi.getAreaList');
      return areaList;
    }
    return areaList;
  }

  /// 获取b站分区房间
  /// @param area 分类id
  /// @param page 请求页数
  /// @param size
  /// @return
  static Future<List<RoomInfo>> getAreaRooms(
      AreaInfo area, int page, int size) async {
    List<RoomInfo> list = [];
    String url =
        'https://api.live.bilibili.com/xlive/web-interface/v1/second/getList?'
        'platform=web&parent_area_id=${area.areaType}&area_id=${area.areaId}&'
        'sort_type=&page=${page + 1}';

    try {
      dynamic response = await _getJson(url);
      if (response['code'] == 0) {
        List<dynamic> roomInfoList = response['data']['list'];
        for (var roomInfo in roomInfoList) {
          var room = RoomInfo(roomInfo['roomid'].toString());
          room.platform = 'bilibili';
          room.nick = roomInfo['uname'] ?? '';
          room.title = roomInfo['title'] ?? '';
          room.cover = roomInfo['cover'] ?? '';
          room.avatar = roomInfo['face'] ?? '';
          room.area = area.areaName;
          room.watching = roomInfo['watched_show']?['num']?.toString() ?? '';
          room.liveStatus = LiveStatus.live;
          list.add(room);
        }
      }
    } catch (e) {
      log(e.toString(), name: 'BilibiliApi.getAreaRooms');
      return list;
    }
    return list;
  }

  /// 搜索
  /// @param keyWords  搜索关键字
  /// @param isLive 是否搜索直播中的信息
  /// @return
  static Future<List<RoomInfo>> search(String keyWords) async {
    List<RoomInfo> list = [];
    String url = 'https://api.bilibili.com/x/web-interface/search/'
        'type?context=&search_type=live_user&cover_type=user_cover'
        '&page=1&order=&keyword=$keyWords&category_id=&__refresh__=true'
        '&_extra=&highlight=1&single_column=0';

    try {
      dynamic response = await _getJson(url);
      if (response['code'] == 0) {
        List<dynamic> ownerList = response['data']['result'];
        for (Map ownerInfo in ownerList) {
          RoomInfo owner = RoomInfo(ownerInfo['roomid'].toString());
          owner.platform = 'bilibili';
          final nick = ownerInfo['uname'] ?? '';
          owner.nick = nick
              .replaceAll('<em class="keyword">', '')
              .replaceAll('</em>', '');
          owner.avatar = 'https:${ownerInfo['uface'] ?? ''}';
          owner.area = ownerInfo['cate_name'] ?? '';
          owner.followers = ownerInfo['attentions']?.toString() ?? '';
          owner.liveStatus = (ownerInfo['is_live'] ?? false)
              ? LiveStatus.live
              : LiveStatus.offline;
          list.add(owner);
        }
      }
    } catch (e) {
      log(e.toString(), name: 'BilibiliApi.search');
      return list;
    }
    return list;
  }
}
