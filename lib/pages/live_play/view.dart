import 'package:hot_live/common/index.dart';
import 'package:hot_live/pages/index.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock/wakelock.dart';

import 'widgets/index.dart';

class LivePlayPage extends StatefulWidget {
  final String preferResolution;

  const LivePlayPage({
    Key? key,
    required this.room,
    required this.preferResolution,
  }) : super(key: key);

  final RoomInfo room;

  @override
  State<LivePlayPage> createState() => _LivePlayPageState();
}

class _LivePlayPageState extends State<LivePlayPage> {
  late FavoriteProvider favorite;
  late SettingsProvider settings;
  late DanmakuStream danmakuStream;

  bool _loading = true;
  Map<String, Map<String, String>> _streamList = {};
  String _selectedResolution = '';
  String _datasource = '';

  // 控制唯一子组件
  final GlobalKey<DanmakuVideoPlayerState> _videoPlayerKey = GlobalKey();
  final GlobalKey<DanmakuListViewState> _danmakuViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    danmakuStream = DanmakuStream(room: widget.room);
    LiveApi.getRoomStreamLink(widget.room).then((value) {
      _streamList = value;
      setPreferResolution();
      setState(() => _loading = false);
    });
    Wakelock.enable();
  }

  @override
  void dispose() {
    Wakelock.disable();
    settings.resetPlayerFitMode();
    ScreenBrightness().resetScreenBrightness();
    danmakuStream.dispose();
    super.dispose();
  }

  void setPreferResolution() {
    if (_streamList.isEmpty || _streamList.values.first.isEmpty) return;

    for (var key in _streamList.keys) {
      if (widget.preferResolution.contains(key)) {
        _selectedResolution = key;
        _datasource = _streamList[key]!.values.first;
        return;
      }
    }
    // 蓝光8M/4M选择缺陷
    if (widget.preferResolution.contains('蓝光')) {
      for (var key in _streamList.keys) {
        if (key.contains('蓝光')) {
          _selectedResolution = key;
          _datasource = _streamList[key]!.values.first;
          return;
        }
      }
    }
    // 偏好选择失败，选择最低清晰度
    _selectedResolution = _streamList.keys.last;
    _datasource = _streamList.values.last.values.first;
  }

  void setResolution(String name, String url) {
    setState(() => _selectedResolution = name);
    _datasource = url;
    _videoPlayerKey.currentState?.setResolution(_datasource);
  }

  @override
  Widget build(BuildContext context) {
    favorite = Provider.of<FavoriteProvider>(context);
    settings = Provider.of<SettingsProvider>(context);
    if (settings.enableScreenKeepOn) {
      Wakelock.toggle(enable: settings.enableScreenKeepOn);
    }

    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          CircleAvatar(
            foregroundImage: (widget.room.avatar == '')
                ? null
                : NetworkImage(widget.room.avatar),
            radius: 13,
            backgroundColor: Theme.of(context).disabledColor,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.room.nick,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(
                '${widget.room.platform.toUpperCase()} / ${widget.room.area}',
                style:
                    Theme.of(context).textTheme.caption?.copyWith(fontSize: 8),
              ),
            ],
          ),
        ]),
        actions: [
          IconButton(
            tooltip: S.of(context).dlan_button_info,
            onPressed: showDlnaCastDialog,
            icon: const Icon(CustomIcons.cast),
          ),
        ],
      ),
      body: SafeArea(
        child: screenWidth > 640
            ? Row(children: <Widget>[
                Flexible(
                  flex: 5,
                  child: _buildVideoPlayer(
                    width: MediaQuery.of(context).size.width / 8.0 * 5.0,
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: Column(children: [
                    _buildResolutions(),
                    const Divider(height: 1),
                    Expanded(
                      child: DanmakuListView(
                        key: _danmakuViewKey,
                        room: widget.room,
                        danmakuStream: danmakuStream,
                      ),
                    ),
                  ]),
                ),
              ])
            : Column(
                children: <Widget>[
                  _buildVideoPlayer(),
                  _buildResolutions(),
                  const Divider(height: 1),
                  Expanded(
                    child: DanmakuListView(
                      key: _danmakuViewKey,
                      room: widget.room,
                      danmakuStream: danmakuStream,
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FavoriteFloatingButton(room: widget.room),
    );
  }

  Widget _buildVideoPlayer({double? width}) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: _loading
            ? Container()
            : DanmakuVideoPlayer(
                key: _videoPlayerKey,
                url: _datasource,
                danmakuStream: danmakuStream,
                room: widget.room,
                fullScreenByDefault: settings.enableFullScreenDefault,
                allowBackgroundPlay: settings.enableBackgroundPlay,
                allowedScreenSleep: !settings.enableScreenKeepOn,
                width: width,
              ),
      ),
    );
  }

  Widget _buildResolutions() {
    // room watching or followers
    final List<Widget> infos = [];
    if (widget.room.followers.isNotEmpty) {
      infos.addAll([
        const Icon(Icons.person_rounded, size: 14),
        const SizedBox(width: 4),
        Text(
          readableCount(widget.room.followers),
          style: Theme.of(context).textTheme.caption,
        ),
      ]);
    } else if (widget.room.watching.isNotEmpty) {
      infos.addAll([
        const Icon(Icons.whatshot_rounded, size: 14),
        const SizedBox(width: 4),
        Text(
          readableCount(widget.room.watching),
          style: Theme.of(context).textTheme.caption,
        ),
      ]);
    }

    // resolution popmenu buttons
    final resButtons = _streamList.keys
        .map<Widget>((res) => PopupMenuButton(
              iconSize: 24,
              icon: Text(
                res.substring(res.length - 2, res.length),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: res == _selectedResolution
                        ? Theme.of(context).colorScheme.primary
                        : null),
              ),
              onSelected: (String url) => setResolution(res, url),
              itemBuilder: (context) => _streamList[res]!
                  .keys
                  .map((cdn) => PopupMenuItem<String>(
                        child:
                            Text(cdn, style: const TextStyle(fontSize: 14.0)),
                        value: _streamList[res]![cdn],
                      ))
                  .toList(),
            ))
        .toList();

    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: infos,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: resButtons,
      ),
    );
  }

  void showDlnaCastDialog() {
    showDialog(
      context: context,
      builder: (context) => LiveDlnaPage(datasource: _datasource),
    );
  }
}

class FavoriteFloatingButton extends StatelessWidget {
  const FavoriteFloatingButton({
    Key? key,
    required this.room,
  }) : super(key: key);

  final RoomInfo room;

  @override
  Widget build(BuildContext context) {
    final favorite = Provider.of<FavoriteProvider>(context);
    return favorite.isFavorite(room.roomId)
        ? FloatingActionButton(
            elevation: 2,
            backgroundColor: Theme.of(context).cardColor,
            tooltip: S.of(context).unfollow,
            onPressed: () => favorite.removeRoom(room),
            child: CircleAvatar(
              foregroundImage:
                  (room.avatar == '') ? null : NetworkImage(room.avatar),
              radius: 18,
              backgroundColor: Theme.of(context).disabledColor,
            ),
          )
        : FloatingActionButton.extended(
            elevation: 2,
            backgroundColor: Theme.of(context).cardColor,
            onPressed: () => favorite.addRoom(room),
            icon: CircleAvatar(
              foregroundImage:
                  (room.avatar == '') ? null : NetworkImage(room.avatar),
              radius: 18,
              backgroundColor: Theme.of(context).disabledColor,
            ),
            label: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).follow,
                  style: Theme.of(context).textTheme.caption,
                ),
                Text(
                  room.nick,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
  }
}
