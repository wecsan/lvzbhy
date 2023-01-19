import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hot_live/model/liveroom.dart';
import 'package:hot_live/api/liveapi.dart';
import 'package:hot_live/utils/pref_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FavoriteProvider with ChangeNotifier {
  FavoriteProvider() {
    onRefresh();
  }

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  final List<RoomInfo> roomsList = [];
  final List<RoomInfo> onlineRoomList = [];

  void _loadFromPref() {
    roomsList.clear();
    onlineRoomList.clear();
    List<String> prefs = PrefUtil.getStringList('favorites') ?? [];
    for (var item in prefs) {
      roomsList.add(RoomInfo.fromJson(jsonDecode(item)));
    }
  }

  void _saveToPref() {
    var roomJsons = <String>[];
    for (var element in roomsList) {
      roomJsons.add(jsonEncode(element.toJson()));
    }
    PrefUtil.setStringList('favorites', roomJsons);
  }

  void _getRoomsInfoFromApi() async {
    for (int i = 0; i < roomsList.length; i++) {
      roomsList[i] = await LiveApi.getRoomInfo(roomsList[i]);
    }
    onlineRoomList
        .addAll(roomsList.where((room) => room.liveStatus == LiveStatus.live));
    refreshController.refreshCompleted();
    notifyListeners();
    _saveToPref();
  }

  void onRefresh() {
    _loadFromPref();
    _getRoomsInfoFromApi();
  }

  bool isFavorite(String roomId) {
    return roomsList.indexWhere((e) => e.roomId == roomId) != -1;
  }

  void addRoom(RoomInfo room) async {
    if (room.title.isEmpty || room.cover.isEmpty) {
      room = await LiveApi.getRoomInfo(room);
    }

    final idx = roomsList.indexWhere((e) => e.roomId == room.roomId);
    if (idx != -1) roomsList[idx] = room;
    roomsList.add(room);
    if (room.liveStatus == LiveStatus.live) onlineRoomList.add(room);
    notifyListeners();
    _saveToPref();
  }

  void removeRoom(RoomInfo room) {
    roomsList.removeWhere((e) => e.roomId == room.roomId);
    onlineRoomList.removeWhere((e) => e.roomId == room.roomId);
    notifyListeners();
    _saveToPref();
  }

  void moveToTop(RoomInfo room) {
    final index = roomsList.indexWhere((e) => e.roomId == room.roomId);
    if (index != -1) {
      roomsList.insert(0, roomsList[index]);
      roomsList.removeAt(index + 1);
    }
    final index1 = onlineRoomList.indexWhere((e) => e.roomId == room.roomId);
    if (index1 != -1) {
      onlineRoomList.insert(0, onlineRoomList[index1]);
      onlineRoomList.removeAt(index1 + 1);
    }
    notifyListeners();
    _saveToPref();
  }
}
