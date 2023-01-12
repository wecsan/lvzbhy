import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hot_live/model/liveroom.dart';
import 'package:hot_live/utils/http/httpapi.dart';
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

  void _getRoomsFromPrefs() {
    List<String> prefs = PrefUtil.getStringList('favorites') ?? [];
    for (var item in prefs) {
      RoomInfo singleRoom = RoomInfo.fromJson(jsonDecode(item));
      _roomsList.add(singleRoom);
    }
  }

  void _saveRoomsToPrefs() {
    var roomJsons = <String>[];
    for (var element in _roomsList) {
      roomJsons.add(jsonEncode(element.toJson()));
    }
    PrefUtil.setStringList('favorites', roomJsons);
  }

  void _getRoomsInfoFromApi() async {
    _onlineRoomList.clear();
    for (int i = 0; i < _roomsList.length; i++) {
      _roomsList[i] = await HttpApi.getRoomInfo(_roomsList[i]);
      if (_roomsList[i].liveStatus == LiveStatus.live) {
        _onlineRoomList.add(_roomsList[i]);
      }
      notifyListeners();
    }
    refreshController.refreshCompleted();
  }

  void onRefresh() {
    _roomsList.clear();
    _getRoomsFromPrefs();
    _getRoomsInfoFromApi();
  }

  bool isFavorite(String roomId) {
    return _roomsList.indexWhere((e) => e.roomId == roomId) != -1;
  }

  void addRoomLink(String link) async {
    RoomInfo singleRoom = RoomInfo.fromLink(link);
    singleRoom = await HttpApi.getRoomInfo(singleRoom);
    addRoom(singleRoom);
  }

  void addRoom(RoomInfo room) async {
    if (room.title.isEmpty || room.cover.isEmpty) {
      room = await HttpApi.getRoomInfo(room);
    }

    final idx = _roomsList.indexWhere((e) => e.roomId == room.roomId);
    if (idx != -1) _roomsList[idx] = room;
    _roomsList.add(room);
    if (room.liveStatus == LiveStatus.live) _onlineRoomList.add(room);
    notifyListeners();
    _saveRoomsToPrefs();
  }

  void removeRoom(RoomInfo room) {
    _roomsList.removeWhere((e) => e.roomId == room.roomId);
    _onlineRoomList.removeWhere((e) => e.roomId == room.roomId);
    notifyListeners();
    _saveRoomsToPrefs();
  }

  void moveToTop(RoomInfo room) {
    final index = _roomsList.indexWhere((e) => e.roomId == room.roomId);
    _roomsList.insert(0, _roomsList[index]);
    _roomsList.removeAt(index + 1);
    notifyListeners();
    _saveRoomsToPrefs();
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
