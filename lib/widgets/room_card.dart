import 'package:flutter/material.dart';
import 'package:ice_live_viewer/model/liveroom.dart';
import 'package:ice_live_viewer/pages/live_play/live_play.dart';
import 'package:ice_live_viewer/utils/http/bilibili.dart';
import 'package:ice_live_viewer/utils/http/douyu.dart';
import 'package:ice_live_viewer/utils/http/huya.dart';
import 'package:ice_live_viewer/utils/keepalivewrapper.dart';

class RoomCard extends StatelessWidget {
  const RoomCard({
    Key? key,
    required this.room,
    this.onLongPress,
    this.dense = false,
  }) : super(key: key);

  final RoomInfo room;
  final Function()? onLongPress;
  final bool dense;

  void onTap(BuildContext context) async {
    final fullRoom = room.platform == 'bilibili'
        ? await BilibiliApi.getRoomFullInfo(room)
        : room.platform == 'huya'
            ? await HuyaApi.getLiveInfo(room.link)
            : await DouyuApi.getRoomFullInfo(room);

    if (fullRoom.liveStatus == LiveStatus.live) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LivePlayPage(room: fullRoom)),
      );
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(
                '${fullRoom.nick} is offline.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeepAliveWrapper(
        child: Card(
      elevation: 5,
      margin: const EdgeInsets.fromLTRB(7.5, 7.5, 7.5, 7.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15.0),
        onTap: () => onTap(context),
        onLongPress: onLongPress,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Card(
                  margin: const EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  color: Theme.of(context).focusColor,
                  elevation: 0,
                  child: room.liveStatus.name == 'live'
                      ? Image.network(
                          room.cover,
                          fit: BoxFit.fill,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                            child: Icon(Icons.live_tv_rounded, size: 48),
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.tv_off_rounded, size: 48),
                              Text("Offline",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w500,
                                  ))
                            ],
                          ),
                        )),
            ),
            ListTile(
              dense: dense,
              contentPadding:
                  dense ? const EdgeInsets.only(left: 8, right: 10) : null,
              horizontalTitleGap: dense ? 8 : null,
              leading: CircleAvatar(
                foregroundImage:
                    (room.avatar == '') ? null : NetworkImage(room.avatar),
                radius: 20,
                backgroundColor: Theme.of(context).disabledColor,
              ),
              title: Text(
                room.title,
                maxLines: 1,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                room.nick,
                maxLines: 1,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: Text(
                room.platform,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
              ),
            )
          ],
        ),
      ),
    ));
  }
}
