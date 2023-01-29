import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:hot_live/common/models/index.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class BilibiliDanmaku {
  final int danmakuId;
  final StreamController<DanmakuInfo> controller;

  BilibiliDanmaku({
    required this.danmakuId,
    required this.controller,
  }) {
    initState();
  }

  Timer? timer;
  IOWebSocketChannel? _channel;
  int totleTime = 0;
  BiliBiliHostServerConfig? config;

  void dispose() {
    timer?.cancel();
    _channel?.sink.close();
  }

  initState() {
    timer = Timer.periodic(const Duration(seconds: 60), (callback) {
      totleTime += 60;
      debugPrint("时间: $totleTime s");
      _channel!.sink.close();
      initLive();
    });
    initLive();
  }

  /// ----- danmaku network stream ------
  Future<void> initLive() async {
    config = await getBServerHost(danmakuId.toString());
    _channel = IOWebSocketChannel.connect("wss://" +
        config!.hostServerList![2].host! +
        ":" +
        config!.hostServerList![2].wssPort.toString() +
        "/sub");
    login();
    // 设置监听
    _channel!.stream.listen((msg) {
      Uint8List list = Uint8List.fromList(msg);
      decode(list);
    });
  }

  void heartBeat() {
    List<int> code = [0, 0, 0, 0, 0, 16, 0, 1, 0, 0, 0, 2, 0, 0, 0, 1];
    _channel!.sink.add(Uint8List.fromList(code));
  }

  void login() {
    String msg = "{"
            "\"roomid\":$danmakuId,"
            "\"uId\":0,"
            "\"protover\":2,"
            "\"platform\":\"web\","
            "\"clientver\":\"1.10.6\","
            "\"type\":2,"
            "\"key\":\"" +
        config!.token! +
        "\"}";
    debugPrint(msg);
    _channel!.sink.add(encode(7, msg: msg));
    heartBeat();
  }

  Uint8List encode(int op, {String? msg}) {
    List<int> header = [0, 0, 0, 0, 0, 16, 0, 1, 0, 0, 0, op, 0, 0, 0, 1];
    if (msg != null) {
      List<int> msgCode = utf8.encode(msg);
      header.addAll(msgCode);
    }
    Uint8List uint8list = Uint8List.fromList(header);
    uint8list = writeInt(uint8list, 0, 4, header.length);
    return uint8list;
  }

  decode(Uint8List list) {
    int headerLen = readInt(list, 4, 2);
    int ver = readInt(list, 6, 2);
    int op = readInt(list, 8, 4);

    switch (op) {
      case 8:
        debugPrint("进入房间");
        break;
      case 5:
        int offset = 0;
        while (offset < list.length) {
          int packLen = readInt(list, offset + 0, 4);
          int headerLen = readInt(list, offset + 4, 2);
          Uint8List body;
          if (ver == 2) {
            body = list.sublist(offset + headerLen, offset + packLen);
            decode(ZLibDecoder().convert(body) as Uint8List);
            offset += packLen;
            continue;
          } else {
            body = list.sublist(offset + headerLen, offset + packLen);
          }
          String data = utf8.decode(body);
          offset += packLen;
          Map<String, dynamic> jd = json.decode(data);
          switch (jd["cmd"]) {
            case "DANMU_MSG":
              String msg = jd["info"][1].toString();
              String name = jd["info"][2][1].toString();
              controller.sink.add(DanmakuInfo(name, msg));
              break;
            default:
          }
        }
        break;
      case 3:
        int people = readInt(list, headerLen, 4);
        debugPrint("人气: $people");
        break;
      default:
    }
  }

  /// 写入编码
  Uint8List writeInt(Uint8List src, int start, int len, int value) {
    int i = 0;
    while (i < len) {
      src[start + i] = value ~/ pow(256, len - i - 1);
      i++;
    }
    return src;
  }

  /// 从编码读出数字
  int readInt(Uint8List src, int start, int len) {
    int res = 0;
    for (int i = len - 1; i >= 0; i--) {
      res += pow(256, len - i - 1) * src[start + i] as int;
    }
    return res;
  }
}

Future<BiliBiliHostServerConfig?> getBServerHost(String roomId) async {
  String url = "https://api.live.bilibili.com/room/v1/Danmu/getConf?id=$roomId";
  try {
    var resp = await http.get(Uri.parse(url));
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
