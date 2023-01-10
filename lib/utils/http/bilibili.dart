// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:ice_live_viewer/model/livearea.dart';
import 'package:ice_live_viewer/model/liveroom.dart';

class BilibiliApi {
  static Future<dynamic> _getJson(String url) async {
    var resp = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1 Edg/108.0.0.0'
      },
    );
    return await jsonDecode(const Utf8Codec().decode(resp.bodyBytes));
  }

  /// 获取直播间所有清晰度的url
  /// @param urls
  /// @param rid
  static Future<Map<String, dynamic>> _getRoomStreamLink(RoomInfo room) async {
    String defaultQn = '10000';
    String newStreamUrl =
        'https://api.live.bilibili.com/xlive/web-room/v2/index/getRoomPlayInfo?room_id=${room.roomId}&qn=$defaultQn&platform=h5&ptype=8&codec=0,1&format=0,1,2&protocol=0,1';
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

    //get m3u8 default, if not, get unplayable flv
    Map streamProtocol =
        streamMultiList[1]['format'][0] ?? streamMultiList[0]['format'][0];
    Map<String, List> finalStream = {};

    //Find the m3u8-fmp4 link
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
        List urlMap = [];
        for (int i = 0; i < urlInfo.length; i++) {
          String finalUrl = urlInfo[i]['host'] + baseUrl + urlInfo[i]['extra'];
          urlMap.add(finalUrl);
        }
        finalStream[qnName] = urlMap;
        continue;
      }

      String qnUrl =
          'https://api.live.bilibili.com/xlive/web-room/v2/index/getRoomPlayInfo?room_id=${room.roomId}&qn=$qn&platform=h5&ptype=8&codec=0,1&format=0,1,2&protocol=0,1';
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
      List urlMap = [];
      for (int i = 0; i < urlInfo.length; i++) {
        String finalUrl = urlInfo[i]['host'] + baseUrl + urlInfo[i]['extra'];
        urlMap.add(finalUrl);
      }
      finalStream[qnName] = urlMap;
    }

    Map<String, Map<String, String>> result = {};
    for (var key in finalStream.keys) {
      List<dynamic> list = finalStream[key] ?? [];
      result[key] = {};
      for (int i = 0; i < list.length; i++) {
        result[key]!["线路$i"] = list[i];
      }
    }
    return result;
  }

  /// 获取单个直播间信息
  /// @param roomId 房间号
  /// @return
  static Future<RoomInfo> getRoomInfo(RoomInfo room) async {
    String reqUrl =
        "https://api.live.bilibili.com/xlive/web-room/v1/index/getH5InfoByRoom?room_id=${room.roomId}";
    dynamic response = await _getJson(reqUrl);
    dynamic data = response["data"];
    dynamic roomInfo = data["room_info"];
    dynamic ownerInfo = data["anchor_info"]["base_info"];
    dynamic liveStatus = roomInfo["live_status"];

    room.platform = "bilibili";
    room.roomId = roomInfo["room_id"].toString();
    room.title = roomInfo["title"];
    room.nick = ownerInfo["uname"];
    room.cover = roomInfo["cover"];
    room.avatar = ownerInfo["face"];

    if (liveStatus == 1) {
      Map links = await _getRoomStreamLink(room);
      room.liveStatus = LiveStatus.live;
      room.cdnMultiLink = links;
    } else {}
    return room;
  }

  /// 根据分页获取推荐直播间
  /// @param page 页数
  /// @param size 每页大小
  /// @return
  static Future<List<RoomInfo>> getRecommend(int page, int size) async {
    List<RoomInfo> list = <RoomInfo>[];

    String url =
        "https://api.live.bilibili.com/room/v1/room/get_user_recommend?page=$page&page_size=$size";
    dynamic response = await _getJson(url);
    if (response["code"] == 0) {
      List<dynamic> data = response["data"];
      data.forEach((roomInfo) {
        var room = RoomInfo(roomInfo["roomid"].toString());
        room.platform = "bilibili";
        room.title = roomInfo["title"];
        room.nick = roomInfo["uname"];
        room.cover = roomInfo["system_cover"];
        room.avatar = roomInfo["face"];
        room.liveStatus = LiveStatus.live;
        list.add(room);
      });
    } else {
      log("BILIBILI---获取推荐直播间异常");
    }
    return list;
  }

  /// 获取bilibili所有分类
  /// @return
  static Future<List<List<AreaInfo>>> getAreaList() async {
    List<List<AreaInfo>> areaList = [];
    String url =
        "https://api.live.bilibili.com/xlive/web-interface/v1/index/getWebAreaList?source_id=2";

    dynamic response = await _getJson(url);
    if (response["code"] == 0) {
      List<dynamic> data = response["data"]["data"];
      data.forEach((areaType) {
        List<AreaInfo> subAreaList = [];
        List<dynamic> areaInfoList = areaType["list"];
        areaInfoList.forEach((areaInfo) {
          AreaInfo area = AreaInfo();
          area.platform = "bilibili";
          area.areaType = areaInfo["parent_id"].toString();
          area.typeName = areaInfo["parent_name"];
          area.areaId = areaInfo["id"].toString();
          area.areaName = areaInfo["name"];
          area.areaPic = areaInfo["pic"];
          subAreaList.add(area);
        });
        areaList.add(subAreaList);
      });
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

    page++;
    String url =
        "https://api.live.bilibili.com/xlive/web-interface/v1/second/getList?platform=web&parent_area_id=${area.areaType}&area_id=${area.areaId}&sort_type=&page=$page";

    dynamic response = await _getJson(url);
    if (response["code"] == 0) {
      List<dynamic> roomInfoList = response["data"]["list"];
      for (var roomInfo in roomInfoList) {
        var room = RoomInfo(roomInfo["roomid"].toString());
        room.platform = "bilibili";
        room.title = roomInfo["title"];
        room.nick = roomInfo["uname"];
        room.cover = roomInfo["cover"];
        room.avatar = roomInfo["face"];
        room.liveStatus = LiveStatus.live;
        list.add(room);
      }
    }
    return list;
  }

  /// 搜索
  /// @param keyWords  搜索关键字
  /// @param isLive 是否搜索直播中的信息
  /// @return
  static Future<List<Map<String, String>>> search(
      String keyWords, String isLive) async {
    return [];
  }
}

Future<BiliBiliHostServerConfig?> getBServerHost(String roomId) async {
  String url = "https://api.live.bilibili.com/room/v1/Danmu/getConf?id=$roomId";
  try {
    var resp = await http.get(
      Uri.parse(url),
    );
    var respData = jsonDecode(const Utf8Codec().decode(resp.bodyBytes));
    if (respData["data"] != null) {
      return BiliBiliHostServerConfig.fromJson(respData["data"]);
    }
    return null;
  } catch (e) {
    return null;
  }
}

class BiliBiliHostServerConfig {
  double? refreshRowFactor;
  int? refreshRate;
  int? maxDelay;
  int? port;
  String? host;
  List<HostServerList>? hostServerList;
  List<ServerList>? serverList;
  String? token;

  BiliBiliHostServerConfig(
      {this.refreshRowFactor,
      this.refreshRate,
      this.maxDelay,
      this.port,
      this.host,
      this.hostServerList,
      this.serverList,
      this.token});

  BiliBiliHostServerConfig.fromJson(Map<String, dynamic> json) {
    refreshRowFactor = json['refresh_row_factor'];
    refreshRate = json['refresh_rate'];
    maxDelay = json['max_delay'];
    port = json['port'];
    host = json['host'];
    if (json['host_server_list'] != null) {
      hostServerList = [];
      json['host_server_list'].forEach((v) {
        hostServerList!.add(HostServerList.fromJson(v));
      });
    }
    if (json['server_list'] != null) {
      serverList = [];
      json['server_list'].forEach((v) {
        serverList!.add(ServerList.fromJson(v));
      });
    }
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['refresh_row_factor'] = refreshRowFactor;
    data['refresh_rate'] = refreshRate;
    data['max_delay'] = maxDelay;
    data['port'] = port;
    data['host'] = host;
    if (hostServerList != null) {
      data['host_server_list'] =
          hostServerList!.map((v) => v.toJson()).toList();
    }
    if (serverList != null) {
      data['server_list'] = serverList!.map((v) => v.toJson()).toList();
    }
    data['token'] = token;
    return data;
  }
}

class HostServerList {
  String? host;
  int? port;
  int? wssPort;
  int? wsPort;

  HostServerList({this.host, this.port, this.wssPort, this.wsPort});

  HostServerList.fromJson(Map<String, dynamic> json) {
    host = json['host'];
    port = json['port'];
    wssPort = json['wss_port'];
    wsPort = json['ws_port'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['host'] = host;
    data['port'] = port;
    data['wss_port'] = wssPort;
    data['ws_port'] = wsPort;
    return data;
  }
}

class ServerList {
  String? host;
  int? port;

  ServerList({this.host, this.port});

  ServerList.fromJson(Map<String, dynamic> json) {
    host = json['host'];
    port = json['port'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['host'] = host;
    data['port'] = port;
    return data;
  }
}
