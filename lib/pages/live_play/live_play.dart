import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:hot_live/api/danmaku/danmaku_stream.dart';
import 'package:hot_live/api/liveapi.dart';
import 'package:hot_live/generated/l10n.dart';
import 'package:hot_live/model/liveroom.dart' hide Platform;
import 'package:hot_live/pages/live_dlna/live_dlna.dart';
import 'package:hot_live/pages/live_play/danmaku_video_player.dart';
import 'package:hot_live/provider/favorite_provider.dart';
import 'package:hot_live/pages/live_play/danmaku_list_view.dart';
import 'package:hot_live/provider/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';

class LivePlayPage extends StatefulWidget {
  const LivePlayPage({Key? key, required this.room}) : super(key: key);

  final RoomInfo room;

  @override
  State<LivePlayPage> createState() => _LivePlayPageState();
}

class _LivePlayPageState extends State<LivePlayPage> {
  late FavoriteProvider favorite;
  late SettingsProvider settings;
  late DanmakuStream danmakuStream;

  Map<String, Map<String, String>> streamList = {};
  String datasource = '';
  bool datasourceError = false;

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
      setState(() {
        if (streamList.isNotEmpty && streamList.values.first.isNotEmpty) {
          datasource = streamList.values.first.values.first;
        } else {
          datasourceError = true;
        }
      });
    });
  }

  @override
  void dispose() {
    settings.resetPlayerFitMode();
    ScreenBrightness().resetScreenBrightness();
    danmakuStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    favorite = Provider.of<FavoriteProvider>(context);
    settings = Provider.of<SettingsProvider>(context);

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
            tooltip: "小窗播放",
            onPressed: showFloatingWindow,
            icon: const Icon(Icons.photo_size_select_small_rounded, size: 22),
          ),
          IconButton(
            tooltip: S.of(context).dlan_button_info,
            onPressed: showDlnaSelectorDialog,
            icon: const Icon(Icons.cast_rounded, size: 22),
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
                    _buildInfoResolutionRow(),
                    const Divider(height: 1),
                    Expanded(child: _buildDanmakuListView()),
                  ]),
                ),
              ])
            : Column(
                children: <Widget>[
                  _buildVideoPlayer(),
                  _buildInfoResolutionRow(),
                  const Divider(height: 1),
                  Expanded(child: _buildDanmakuListView()),
                ],
              ),
      ),
      floatingActionButton: _buildFavoriteButton(),
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
                allowBackgroundPlay: settings.enableBackgroundPlay,
                allowedScreenSleep: !settings.enableScreenKeepOn,
              )
            : Center(
                child: datasourceError
                    ? const Icon(
                        Icons.error_outline_rounded,
                        size: 42,
                        color: Colors.white70,
                      )
                    : Container(),
              ),
      ),
    );
  }

  Widget _buildDanmakuListView() {
    return DanmakuListView(
      key: _danmakuViewKey,
      room: widget.room,
      danmakuStream: danmakuStream,
    );
  }

  Widget _buildFavoriteButton() {
    return favorite.isFavorite(widget.room.roomId)
        ? FloatingActionButton(
            elevation: 2,
            backgroundColor: Theme.of(context).cardColor,
            tooltip: S.of(context).unfollow,
            onPressed: () => favorite.removeRoom(widget.room),
            child: CircleAvatar(
              foregroundImage: (widget.room.avatar == '')
                  ? null
                  : NetworkImage(widget.room.avatar),
              radius: 18,
              backgroundColor: Theme.of(context).disabledColor,
            ),
          )
        : FloatingActionButton.extended(
            elevation: 2,
            backgroundColor: Theme.of(context).cardColor,
            onPressed: () => favorite.addRoom(widget.room),
            icon: CircleAvatar(
              foregroundImage: (widget.room.avatar == '')
                  ? null
                  : NetworkImage(widget.room.avatar),
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
                  widget.room.nick,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
  }

  Widget _buildInfoResolutionRow() {
    final resolutionBtns = [];
    streamList.forEach((resolution, cdns) {
      final btn = PopupMenuButton(
        iconSize: 24,
        icon: Text(
          resolution.substring(resolution.length - 2, resolution.length),
          style: Theme.of(context).textTheme.labelMedium,
        ),
        onSelected: videoPlayer?.setResolution,
        itemBuilder: (context) {
          final menuList = <PopupMenuItem<String>>[];
          cdns.forEach((cdn, url) {
            final menuItem = PopupMenuItem<String>(
              child: Text(cdn, style: const TextStyle(fontSize: 14.0)),
              value: url,
            );
            menuList.add(menuItem);
          });
          return menuList;
        },
      );
      resolutionBtns.add(btn);
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const IconButton(onPressed: null, icon: Text('')),
          ...resolutionBtns,
        ],
      ),
    );
  }

  void showDlnaSelectorDialog() {
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
