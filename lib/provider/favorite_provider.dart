import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ice_live_viewer/model/liveroom.dart';
import 'package:ice_live_viewer/utils/http/httpapi.dart';
import 'package:ice_live_viewer/utils/prefs_helper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FavoriteProvider with ChangeNotifier {
  FavoriteProvider() {
    onRefresh();
  }
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  final List<RoomInfo> _roomsList = [];
  final List<RoomInfo> _tempRoomsList = [];
  bool _isHideOffline = false;
  get roomsList => _roomsList;
  get isHideOffline => _isHideOffline;

  void _getRoomsFromPrefs() {
    var prefs = PrefsHelper.getFavoriteRoomsPref();
    for (var item in prefs) {
      RoomInfo singleRoom = RoomInfo.fromJson(jsonDecode(item));
      _roomsList.add(singleRoom);
    }
    notifyListeners();
  }

  void _getRoomsInfoFromApi() async {
    for (int i = 0; i < _roomsList.length; i++) {
      _roomsList[i] = await HttpApi.getRoomInfo(_roomsList[i]);
      notifyListeners();
    }
    refreshController.refreshCompleted();
  }

  void onRefresh() {
    _roomsList.clear();
    _getRoomsFromPrefs();
    _getRoomsInfoFromApi();
  }

  void _saveRoomsToPrefs() {
    PrefsHelper.setFavoriteRoomsPref(_roomsList);
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
    final idx = _roomsList.indexWhere((e) => e.roomId == room.roomId);
    if (idx != -1) _roomsList[idx] = room;
    _roomsList.add(room);
    notifyListeners();
    _saveRoomsToPrefs();
  }

  void removeRoom(RoomInfo room) {
    _roomsList.removeWhere((e) => e.roomId == room.roomId);
    notifyListeners();
    _saveRoomsToPrefs();
  }

  void updateRoom(RoomInfo room) {
    final idx = _roomsList.indexWhere((e) => e.roomId == room.roomId);
    if (idx != -1) _roomsList[idx] = room;
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
    for (var element in _roomsList) {
      _tempRoomsList.add(element);
    }
    for (var item in _tempRoomsList) {
      if (item.liveStatus.name != 'live') {
        _roomsList.removeWhere((element) => element.roomId == item.roomId);
      }
    }
    notifyListeners();
    _isHideOffline = true;
  }

  void showOfflineRooms() {
    _roomsList.clear();
    for (var item in _tempRoomsList) {
      _roomsList.add(item);
    }
    _tempRoomsList.clear();
    _isHideOffline = false;
    notifyListeners();
  }
}
