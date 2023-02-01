import 'dart:async';
import 'dart:convert';

import 'package:hot_live/common/index.dart';

class FavoriteProvider with ChangeNotifier {
  final BuildContext context;
  late SettingsProvider settings;

  FavoriteProvider(this.context) {
    settings = Provider.of<SettingsProvider>(context, listen: false);
    onRefresh();
    Timer.periodic(Duration(seconds: settings.autoRefreshTime), (timer) {
      onRefresh();
    });
  }

  final List<RoomInfo> _roomsList = [];
  final List<RoomInfo> onlineRoomList = [];
  final List<RoomInfo> offlineRoomList = [];

  void _loadFromPref() {
    _roomsList.clear();
    onlineRoomList.clear();
    List<String> prefs = PrefUtil.getStringList('favorites') ?? [];
    _roomsList.addAll(prefs.map((e) => RoomInfo.fromJson(jsonDecode(e))));
    onlineRoomList
        .addAll(_roomsList.where((room) => room.liveStatus == LiveStatus.live));
    offlineRoomList
        .addAll(_roomsList.where((room) => room.liveStatus != LiveStatus.live));
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
    onlineRoomList.clear();
    offlineRoomList.clear();
    onlineRoomList
        .addAll(_roomsList.where((room) => room.liveStatus == LiveStatus.live));
    offlineRoomList
        .addAll(_roomsList.where((room) => room.liveStatus != LiveStatus.live));
    notifyListeners();
    _saveToPref();
  }

  bool isFavorite(RoomInfo room) {
    return _roomsList.indexWhere((e) => e == room) != -1;
  }

  void addRoom(RoomInfo room) async {
    if (room.title.isEmpty || room.cover.isEmpty) {
      room = await LiveApi.getRoomInfo(room);
    }

    final idx = _roomsList.indexWhere((e) => e == room);
    if (idx != -1) _roomsList[idx] = room;
    _roomsList.add(room);
    if (room.liveStatus == LiveStatus.live) {
      onlineRoomList.add(room);
    } else {
      offlineRoomList.add(room);
    }
    notifyListeners();
    _saveToPref();
  }

  void removeRoom(RoomInfo room) {
    _roomsList.removeWhere((e) => e == room);
    onlineRoomList.removeWhere((e) => e == room);
    offlineRoomList.removeWhere((e) => e == room);
    notifyListeners();
    _saveToPref();
  }
}
