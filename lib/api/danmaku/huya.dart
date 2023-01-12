import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hot_live/model/danmaku.dart';
import 'package:hot_live/utils/dart_tars_protocol/tarscodec.dart';
import 'package:web_socket_channel/io.dart';

class HuyaDanmaku {
  final int danmakuId;
  final StreamController<DanmakuInfo> controller;

  HuyaDanmaku({
    required this.danmakuId,
    required this.controller,
  }) {
    initLive();
  }

  Timer? timer;
  IOWebSocketChannel? _channel;
  int totleTime = 0;

  void dispose() {
    timer?.cancel();
    _channel?.sink.close();
  }

  //初始化
  void initLive() {
    _channel = IOWebSocketChannel.connect("wss://cdnws.api.huya.com");
    login();
    // 设置监听
    _channel!.stream.listen((msg) {
      Uint8List list = Uint8List.fromList(msg);
      decode(list);
    });
    timer = Timer.periodic(const Duration(seconds: 30), (callback) {
      totleTime += 30;
      heartBeat();
      //print("时间: $totleTime s");
    });
  }

  //发送心跳包
  void heartBeat() {
    Uint8List heartbeat = huyaWsHeartbeat();
    _channel!.sink.add(heartbeat);
  }

  void login() {
    Uint8List regData = regDataEncode(danmakuId);
    _channel!.sink.add(regData);
    debugPrint("login");
    Uint8List heartbeat = huyaWsHeartbeat();
    //print("heartbeat");
    _channel!.sink.add(heartbeat);
  }

  /// 对消息进行解码
  decode(Uint8List list) {
    List danmaku = danmakuDecode(list);
    String nickname = danmaku[0];
    String message = danmaku[1];
    if (message != '') {
      controller.add(DanmakuInfo(nickname, message));
    }
  }
}
