import 'dart:async';

import 'package:pure_live/common/index.dart';

class FavoriteProvider with ChangeNotifier {
  final BuildContext context;
  late SettingsProvider settings;

  FavoriteProvider(this.context) {
    settings = Provider.of<SettingsProvider>(context, listen: false);
    // fist loading
    onlineRoomList.clear();
    onlineRoomList.addAll(settings.favoriteRooms
        .where((room) => room.liveStatus == LiveStatus.live));

    offlineRoomList.clear();
    offlineRoomList.addAll(settings.favoriteRooms
        .where((room) => room.liveStatus != LiveStatus.live));

    onRefresh();
    Timer.periodic(Duration(seconds: settings.autoRefreshTime), (timer) {
      onRefresh();
    });
  }

  final List<RoomInfo> onlineRoomList = [];
  final List<RoomInfo> offlineRoomList = [];

  Future<void> onRefresh() async {
    for (final room in settings.favoriteRooms) {
      settings.updateRoom(await LiveApi.getRoomInfo(room));
    }

    onlineRoomList.clear();
    onlineRoomList.addAll(settings.favoriteRooms
        .where((room) => room.liveStatus == LiveStatus.live));

    offlineRoomList.clear();
    offlineRoomList.addAll(settings.favoriteRooms
        .where((room) => room.liveStatus != LiveStatus.live));
    notifyListeners();
  }

  bool isFavorite(RoomInfo room) {
    return settings.isFavorite(room);
  }

  void addRoom(RoomInfo room) async {
    if (room.title.isEmpty || room.cover.isEmpty) {
      room = await LiveApi.getRoomInfo(room);
    }

    if (settings.addRoom(room)) {
      if (room.liveStatus == LiveStatus.live) {
        onlineRoomList.add(room);
      } else {
        offlineRoomList.add(room);
      }
      notifyListeners();
    }
  }

  void removeRoom(RoomInfo room) {
    if (settings.removeRoom(room)) {
      onlineRoomList.remove(room);
      offlineRoomList.remove(room);
      notifyListeners();
    }
  }
}
