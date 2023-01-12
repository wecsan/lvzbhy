import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hot_live/model/danmaku.dart';
import 'package:web_socket_channel/io.dart';

class DouyuDanmakuSteam with ChangeNotifier {
  DouyuDanmakuSteam({
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

  void initLive() {
    _channel = IOWebSocketChannel.connect("wss://danmuproxy.douyu.com:8506");
    login();
    setListener();
    timer = Timer.periodic(const Duration(seconds: 45), (callback) {
      totleTime += 45;
      heartBeat();
      //print("时间: $totleTime s");
    });
  }

  /// 发送心跳包
  void heartBeat() {
    String heartbeat = 'type@=mrkl/';
    _channel!.sink.add(encode(heartbeat));
  }

  /// 设置监听
  void setListener() {
    _channel!.stream.listen((msg) {
      Uint8List list = Uint8List.fromList(msg);
      decode(list);
    });
  }

  void login() {
    String roomID = danmakuId.toString();
    String login =
        "type@=loginreq/room_id@=$roomID/dfl@=sn@A=105@Sss@A=1/username@=61609154/uid@=61609154/ver@=20190610/aver@=218101901/ct@=0/";
    _channel!.sink.add(encode(login));
    String joingroup = "type@=joingroup/rid@=$roomID/gid@=-9999/";
    _channel!.sink.add(encode(joingroup));
    String heartbeat = 'type@=mrkl/';
    _channel!.sink.add(encode(heartbeat));
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

  /// 对消息进行解码
  decode(Uint8List list) {
    //消息总长度
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

      //目前只处理弹幕信息所以简单点
      if (byteDatas.contains("type@=chatmsg")) {
        //截取用户名
        var nickname = byteDatas
            .substring(byteDatas.indexOf("nn@="), byteDatas.indexOf("/txt"))
            .replaceAll("nn@=", "");
        //截取弹幕信息
        var content = byteDatas
            .substring(byteDatas.indexOf("txt@="), byteDatas.indexOf("/cid"))
            .replaceAll("txt@=", "");
        damakuSteam.add(DanmakuInfo(nickname, content));
      }
    }
  }
}
