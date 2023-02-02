import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:pure_live/common/models/index.dart';
import 'package:web_socket_channel/io.dart';

class DouyuDanmaku {
  final int danmakuId;
  final StreamController<DanmakuInfo> controller;

  DouyuDanmaku({
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

  void initLive() {
    _channel = IOWebSocketChannel.connect("wss://danmuproxy.douyu.com:8506");
    login();
    // 设置监听
    _channel!.stream.listen((msg) {
      Uint8List list = Uint8List.fromList(msg);
      decode(list);
    });
    timer = Timer.periodic(const Duration(seconds: 45), (callback) {
      totleTime += 45;
      heartBeat();
    });
  }

  void heartBeat() {
    String heartbeat = 'type@=mrkl/';
    _channel!.sink.add(encode(heartbeat));
  }

  void login() {
    String login = "type@=loginreq/roomid@=$danmakuId/";
    String joingroup = "type@=joingroup/rid@=$danmakuId/gid@=-9999/";

    _channel!.sink.add(encode(login));
    _channel!.sink.add(encode(joingroup));
    heartBeat();
  }

  Uint8List encode(String msg) {
    ByteData header = ByteData(12);
    //定义协议头
    header.setInt32(0, msg.length + 9, Endian.little);
    header.setInt32(4, msg.length + 9, Endian.little);
    header.setInt32(8, 689, Endian.little);
    List<int> data = header.buffer.asUint8List().toList();
    List<int> msgData = utf8.encode(msg);
    data.addAll(msgData);
    //结尾 \0 协议规定
    data.add(0);
    return Uint8List.fromList(data);
  }

  decode(Uint8List list) {
    // 消息总长度
    int totalLength = list.length;
    // 当前消息长度
    int len = 0;
    int decodedMsgLen = 0;
    // 单条消息的 buffer
    Uint8List singleMsgBuffer;
    Uint8List lenStr;
    while (decodedMsgLen < totalLength) {
      lenStr = list.sublist(decodedMsgLen, decodedMsgLen + 4);
      len = lenStr.buffer.asByteData().getInt32(0, Endian.little) + 4;
      singleMsgBuffer = list.sublist(decodedMsgLen, decodedMsgLen + len);
      decodedMsgLen += len;
      String byteDatas =
          utf8.decode(singleMsgBuffer.sublist(12, singleMsgBuffer.length - 2));

      // 目前只处理弹幕信息所以简单点
      if (byteDatas.contains("type@=chatmsg")) {
        // 截取用户名
        var nickname = byteDatas
            .substring(byteDatas.indexOf("nn@="), byteDatas.indexOf("/txt"))
            .replaceAll("nn@=", "");
        // 截取弹幕信息
        var content = byteDatas
            .substring(byteDatas.indexOf("txt@="), byteDatas.indexOf("/cid"))
            .replaceAll("txt@=", "");
        // 修复斗鱼弹幕@信息
        content.replaceAll('@A', '@');
        controller.sink.add(DanmakuInfo(nickname, content));
      }
    }
  }
}
