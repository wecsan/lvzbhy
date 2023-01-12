import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hot_live/model/danmaku.dart';
import 'package:hot_live/utils/http/bilibili.dart';
import 'package:web_socket_channel/io.dart';

class BilibiliDanmakuStream with ChangeNotifier {
  BilibiliDanmakuStream({required this.danmakuId}) {
    initState();
  }

  final int danmakuId;
  Timer? timer;
  IOWebSocketChannel? _channel;
  int totleTime = 0;
  BiliBiliHostServerConfig? config;

  /// ----- danmaku output stream ------
  final StreamController<DanmakuInfo> damakuSteam = StreamController();

  void setDanmakuListener(void Function(DanmakuInfo)? listener) {
    damakuSteam.stream.listen(listener);
  }

  @override
  void dispose() {
    damakuSteam.close();
    timer?.cancel();
    _channel?.sink.close();
    super.dispose();
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
    joinRoom(danmakuId);
    setListener();
  }

  void sendHeartBeat() {
    List<int> code = [0, 0, 0, 0, 0, 16, 0, 1, 0, 0, 0, 2, 0, 0, 0, 1];
    _channel!.sink.add(Uint8List.fromList(code));
  }

  /// 加入房间
  void joinRoom(int id) {
    String msg = "{"
            "\"roomid\":$id,"
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
    sendHeartBeat();
  }

  /// 设置监听
  void setListener() {
    _channel!.stream.listen((msg) {
      Uint8List list = Uint8List.fromList(msg);
      decode(list);
    });
  }

  /// 对消息编码
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

  /// 对消息进行解码
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
              damakuSteam.add(DanmakuInfo(name, msg));
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
