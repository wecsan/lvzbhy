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

  final List<RoomInfo> _roomsList = [];
  final List<RoomInfo> _onlineRoomList = [];
  get roomsList => isHideOffline ? _onlineRoomList : _roomsList;

  bool _isHideOffline = false;
  get isHideOffline => _isHideOffline;

  void _loadFromPref() {
    _roomsList.clear();
    _onlineRoomList.clear();
    List<String> prefs = PrefUtil.getStringList('favorites') ?? [];
    for (var item in prefs) {
      RoomInfo singleRoom = RoomInfo.fromJson(jsonDecode(item));
      _roomsList.add(singleRoom);
    }
  }

  void _saveToPref() {
    var roomJsons = <String>[];
    for (var element in _roomsList) {
      roomJsons.add(jsonEncode(element.toJson()));
    }
    PrefUtil.setStringList('favorites', roomJsons);
  }

  void _getRoomsInfoFromApi() async {
    for (int i = 0; i < _roomsList.length; i++) {
      _roomsList[i] = await LiveApi.getRoomInfo(_roomsList[i]);
      if (_roomsList[i].liveStatus == LiveStatus.live) {
        _onlineRoomList.add(_roomsList[i]);
      }
    }
    refreshController.refreshCompleted();
    notifyListeners();
  }

  void onRefresh() {
    _loadFromPref();
    _getRoomsInfoFromApi();
  }

  bool isFavorite(String roomId) {
    return _roomsList.indexWhere((e) => e.roomId == roomId) != -1;
  }

  void addRoom(RoomInfo room) async {
    if (room.title.isEmpty || room.cover.isEmpty) {
      room = await LiveApi.getRoomInfo(room);
    }

    final idx = _roomsList.indexWhere((e) => e.roomId == room.roomId);
    if (idx != -1) _roomsList[idx] = room;
    _roomsList.add(room);
    if (room.liveStatus == LiveStatus.live) _onlineRoomList.add(room);
    notifyListeners();
    _saveToPref();
  }

  void removeRoom(RoomInfo room) {
    _roomsList.removeWhere((e) => e.roomId == room.roomId);
    _onlineRoomList.removeWhere((e) => e.roomId == room.roomId);
    notifyListeners();
    _saveToPref();
  }

  void moveToTop(RoomInfo room) {
    final index = _roomsList.indexWhere((e) => e.roomId == room.roomId);
    _roomsList.insert(0, _roomsList[index]);
    _roomsList.removeAt(index + 1);
    notifyListeners();
    _saveToPref();
  }

  void hideOfflineRooms() {
    _isHideOffline = true;
    notifyListeners();
  }

  void showOfflineRooms() {
    _isHideOffline = false;
    notifyListeners();
  }
}
