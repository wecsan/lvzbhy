import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:hot_live/api/danmaku/danmaku_stream.dart';
import 'package:hot_live/api/liveapi.dart';
import 'package:hot_live/generated/l10n.dart';
import 'package:hot_live/model/liveroom.dart' hide Platform;
import 'package:hot_live/pages/live_play/widgets/live_dlna_dialog.dart';
import 'package:hot_live/pages/live_play/widgets/danmaku_video_player.dart';
import 'package:hot_live/provider/favorite_provider.dart';
import 'package:hot_live/pages/live_play/widgets/danmaku_list_view.dart';
import 'package:hot_live/provider/settings_provider.dart';
import 'package:hot_live/utils/text_util.dart';
import 'package:hot_live/widgets/custom_icons.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock/wakelock.dart';

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

  bool noStreamError = false;
  Map<String, Map<String, String>> streamList = {};
  String selectedResolution = '';
  String datasource = '';

  // 控制唯一子组件
  final GlobalKey<DanmakuVideoPlayerState> _videoPlayerKey = GlobalKey();
  final GlobalKey<DanmakuListViewState> _danmakuViewKey = GlobalKey();
  DanmakuVideoPlayerState? get videoPlayer => _videoPlayerKey.currentState;

  @override
  void initState() {
    super.initState();
    danmakuStream = DanmakuStream(room: widget.room);
    LiveApi.getRoomStreamLink(widget.room).then((value) {
      streamList = value;
      if (streamList.isNotEmpty && streamList.values.first.isNotEmpty) {
        selectPreferResolution();
      } else {
        noStreamError = true;
      }
      setState(() {});
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

  void selectPreferResolution() {
    for (var key in streamList.keys) {
      if (widget.preferResolution.contains(key)) {
        selectedResolution = key;
        datasource = streamList[key]!.values.first;
        return;
      }
    }
    // 蓝光8M/4M选择缺陷
    if (widget.preferResolution.contains('蓝光')) {
      for (var key in streamList.keys) {
        if (key.contains('蓝光')) {
          selectedResolution = key;
          datasource = streamList[key]!.values.first;
          return;
        }
      }
    }
    // 偏好选择失败，选择最低清晰度
    selectedResolution = streamList.keys.last;
    datasource = streamList.values.last.values.first;
  }

  void selectResolution(String name, String url) {
    setState(() => selectedResolution = name);
    datasource = url;
    videoPlayer?.setResolution(url);
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
                '${widget.room.platform} / ${widget.room.area}',
                style:
                    Theme.of(context).textTheme.caption?.copyWith(fontSize: 10),
              ),
            ],
          ),
        ]),
        actions: [
          IconButton(
            tooltip: S.of(context).float_window_play,
            onPressed: showFloatingWindow,
            icon: const Icon(CustomIcons.float_window),
          ),
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
                  child: _buildVideoPlayer(),
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

  Widget _buildVideoPlayer() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: datasource.isNotEmpty
            ? DanmakuVideoPlayer(
                key: _videoPlayerKey,
                url: datasource,
                danmakuStream: danmakuStream,
                room: widget.room,
                fullScreenByDefault: settings.enableFullScreenDefault,
                allowBackgroundPlay: settings.enableBackgroundPlay,
                allowedScreenSleep: !settings.enableScreenKeepOn,
              )
            : Center(
                child: noStreamError
                    ? const Text(
                        "未发现直播源",
                        style: TextStyle(color: Colors.white),
                      )
                    : Container(),
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
          transformCount(widget.room.followers),
          style: Theme.of(context).textTheme.caption,
        ),
        const SizedBox(width: 12),
      ]);
    }
    if (widget.room.watching.isNotEmpty) {
      infos.addAll([
        const Icon(Icons.whatshot_rounded, size: 14),
        const SizedBox(width: 4),
        Text(
          transformCount(widget.room.watching),
          style: Theme.of(context).textTheme.caption,
        ),
      ]);
    }

    // resolution popmenu buttons
    final resButtons = streamList.keys
        .map<Widget>((res) => PopupMenuButton(
              iconSize: 24,
              icon: Text(
                res.substring(res.length - 2, res.length),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: res == selectedResolution
                        ? Theme.of(context).colorScheme.primary
                        : null),
              ),
              onSelected: (String url) => selectResolution(res, url),
              itemBuilder: (context) => streamList[res]!
                  .keys
                  .map((cdn) => PopupMenuItem<String>(
                        child:
                            Text(cdn, style: const TextStyle(fontSize: 14.0)),
                        value: streamList[res]![cdn],
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
      builder: (context) => LiveDlnaPage(datasource: datasource),
    );
  }

  void showFloatingWindow() async {
    if (!Platform.isAndroid) {
      return;
    }

    var allowed = await FlutterOverlayWindow.isPermissionGranted();
    if (!allowed) {
      allowed = (await FlutterOverlayWindow.requestPermission()) ?? false;
    }
    if (!allowed) {
      return;
    }

    videoPlayer?.stopPlayer();
    final width = MediaQuery.of(context).size.width *
        MediaQuery.of(context).devicePixelRatio *
        settings.floatOverlayRatio;
    final height = width / 16 * 9;

    if (!(await FlutterOverlayWindow.isActive())) {
      await FlutterOverlayWindow.showOverlay(
        width: width.toInt(),
        height: height.toInt(),
        enableDrag: true,
        overlayTitle: '悬浮播放${widget.room.nick}的直播间',
        overlayContent: widget.room.title,
        flag: OverlayFlag.defaultFlag,
        alignment: OverlayAlignment.topRight,
        visibility: NotificationVisibility.visibilityPrivate,
        positionGravity: PositionGravity.auto,
      );
    }
    FlutterOverlayWindow.shareData({"url": datasource});
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
