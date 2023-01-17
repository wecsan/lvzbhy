import 'package:flutter/material.dart';
import 'package:hot_live/api/danmaku/danmaku_stream.dart';
import 'package:hot_live/api/liveapi.dart';
import 'package:hot_live/generated/l10n.dart';
import 'package:hot_live/model/liveroom.dart';
import 'package:hot_live/pages/live_dlna/live_dlna.dart';
import 'package:hot_live/pages/live_play/danmaku_video_player.dart';
import 'package:hot_live/provider/favorite_provider.dart';
import 'package:hot_live/pages/live_play/danmaku_list_view.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock/wakelock.dart';

class LivePlayPage extends StatefulWidget {
  const LivePlayPage({Key? key, required this.room}) : super(key: key);

  final RoomInfo room;

  @override
  State<LivePlayPage> createState() => _LivePlayPageState();
}

class _LivePlayPageState extends State<LivePlayPage> {
  late DanmakuStream danmakuStream = DanmakuStream(room: widget.room);
  Map<String, Map<String, String>> streamList = {};
  String datasource = '';
  bool datasourceError = false;

  late final favorite = Provider.of<FavoriteProvider>(context);
  final GlobalKey<DanmakuVideoPlayerState> _videoPlayerKey = GlobalKey();
  final GlobalKey<DanmakuListViewState> _danmakuViewKey = GlobalKey();
  DanmakuVideoPlayerState get videoPlayer => _videoPlayerKey.currentState!;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
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
    Wakelock.toggle(enable: false);
    Wakelock.disable();
    ScreenBrightness().resetScreenBrightness();
    danmakuStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.room.title),
        actions: [
          IconButton(
            onPressed: () {
              videoPlayer.pause();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LiveDlnaPage(streamList: streamList),
                  ));
            },
            icon: const Icon(Icons.tv_rounded),
          )
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
                title: widget.room.title,
              )
            : Center(
                child: datasourceError
                    ? const Icon(
                        Icons.error_outline_rounded,
                        size: 42,
                        color: Colors.white70,
                      )
                    : const CircularProgressIndicator(),
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
        onSelected: (String link) => videoPlayer.setDataSource(link),
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
        children: [
          const SizedBox(width: 8),
          CircleAvatar(
            foregroundImage: (widget.room.avatar == '')
                ? null
                : NetworkImage(widget.room.avatar),
            radius: 13,
            backgroundColor: Theme.of(context).disabledColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.room.nick,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  widget.room.platform,
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      ?.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          const IconButton(onPressed: null, icon: Text('')),
          ...resolutionBtns,
        ],
      ),
    );
  }
}
