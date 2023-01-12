import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hot_live/model/danmaku.dart';
import 'package:hot_live/utils/dart_tars_protocol/tarscodec.dart';
import 'package:web_socket_channel/io.dart';

class HuyaDanmakuStream with ChangeNotifier {
  HuyaDanmakuStream({
    Key? key,
    required this.danmakuId,
  }) {
    initLive();
  }

  final int danmakuId;
  Timer? timer;
  IOWebSocketChannel? _channel;
  int totleTime = 0;

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

  //初始化
  void initLive() {
    _channel = IOWebSocketChannel.connect("wss://cdnws.api.huya.com");
    login();
    setListener();
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

  /// 设置监听
  void setListener() {
    _channel!.stream.listen((msg) {
      Uint8List list = Uint8List.fromList(msg);
      decode(list);
    });
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
      damakuSteam.add(DanmakuInfo(nickname, message));
    }
  }
}
