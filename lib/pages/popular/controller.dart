import 'package:hot_live/common/index.dart';

class PlatformRooms {
  String tag = 'bilibili';
  String name = '哔哩';
  int page = 0;
  List<RoomInfo> rooms = [];

  PlatformRooms({
    this.tag = '',
    this.name = '',
    this.page = 0,
  });
}

class PopularProvider with ChangeNotifier {
  final BuildContext context;

  String platform = 'bilibili';
  Map<String, PlatformRooms> platformRooms = {
    'bilibili': PlatformRooms(tag: 'bilibili', name: '哔哩'),
    'douyu': PlatformRooms(tag: 'douyu', name: '斗鱼'),
    'huya': PlatformRooms(tag: 'huya', name: '虎牙'),
  };

  int get page => platformRooms[platform]?.page ?? 0;
  set page(int _page) => platformRooms[platform]?.page = _page;

  List<RoomInfo> get rooms => platformRooms[platform]?.rooms ?? [];
  set rooms(List<RoomInfo> _rooms) => platformRooms[platform]?.rooms = _rooms;

  PopularProvider(this.context) {
    platform = Provider.of<SettingsProvider>(
      context,
      listen: false,
    ).preferPlatform;
    initRefresh();
  }

  void initRefresh() async {
    for (final p in platformRooms.keys) {
      platformRooms[p]?.rooms = await LiveApi.getRecommend(p, page: 0);
    }
    notifyListeners();
  }

  Future<bool> onRefresh() async {
    page = 0;
    rooms = await LiveApi.getRecommend(platform, page: page);
    notifyListeners();
    return rooms.isNotEmpty;
  }

  Future<bool> onLoading() async {
    page++;
    final items = await LiveApi.getRecommend(platform, page: page);
    if (items.isNotEmpty) {
      for (var item in items) {
        if (rooms.indexWhere((e) => e.roomId == item.roomId) != -1) continue;
        rooms.add(item);
      }
    }
    notifyListeners();
    return items.isNotEmpty;
  }

  void changePlatform(String plat) {
    platform = plat;
    notifyListeners();
  }
}
