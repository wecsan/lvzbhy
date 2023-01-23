import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hot_live/model/liveroom.dart';
import 'package:hot_live/api/liveapi.dart';
import 'package:hot_live/provider/settings_provider.dart';
import 'package:hot_live/utils/pref_util.dart';
import 'package:provider/provider.dart';

class FavoriteProvider with ChangeNotifier {
  final BuildContext context;
  late SettingsProvider settings;

  FavoriteProvider(this.context) {
    settings = Provider.of<SettingsProvider>(context, listen: false);
    onRefresh();
  }

  final List<RoomInfo> _roomsList = [];
  final List<RoomInfo> _onlineRoomList = [];

  List<RoomInfo> get roomList =>
      settings.hideOfflineRoom ? _onlineRoomList : _roomsList;
  bool get hideOffline => settings.hideOfflineRoom;
  void toggleHideOffline() {
    settings.hideOfflineRoom = !settings.hideOfflineRoom;
    notifyListeners();
  }

  void _loadFromPref() {
    _roomsList.clear();
    _onlineRoomList.clear();
    List<String> prefs = PrefUtil.getStringList('favorites') ?? [];
    _roomsList.addAll(prefs.map((e) => RoomInfo.fromJson(jsonDecode(e))));
    _onlineRoomList
        .addAll(_roomsList.where((room) => room.liveStatus == LiveStatus.live));
  }

  void _saveToPref() {
    var roomJsons = <String>[];
    for (var element in _roomsList) {
      roomJsons.add(jsonEncode(element.toJson()));
    }
    PrefUtil.setStringList('favorites', roomJsons);
  }

  Future<void> onRefresh() async {
    _loadFromPref();
    await _getRoomsInfoFromApi();
  }

  Future<void> _getRoomsInfoFromApi() async {
    for (int i = 0; i < _roomsList.length; i++) {
      _roomsList[i] = await LiveApi.getRoomInfo(_roomsList[i]);
    }
    _onlineRoomList.clear();
    _onlineRoomList
        .addAll(_roomsList.where((room) => room.liveStatus == LiveStatus.live));
    notifyListeners();
    _saveToPref();
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
    if (index != -1) {
      _roomsList.insert(0, _roomsList[index]);
      _roomsList.removeAt(index + 1);
    }
    final index1 = _onlineRoomList.indexWhere((e) => e.roomId == room.roomId);
    if (index1 != -1) {
      _onlineRoomList.insert(0, _onlineRoomList[index1]);
      _onlineRoomList.removeAt(index1 + 1);
    }
    notifyListeners();
    _saveToPref();
  }
}
