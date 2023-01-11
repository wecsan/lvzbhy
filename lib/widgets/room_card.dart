import 'package:flutter/material.dart';
import 'package:ice_live_viewer/model/liveroom.dart';
import 'package:ice_live_viewer/pages/live_play/live_play.dart';
import 'package:ice_live_viewer/utils/http/httpapi.dart';
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
    room.cdnMultiLink = await HttpApi.getRoomStreamLink(room);
    String info = '';
    if (room.liveStatus == LiveStatus.live) {
      if (room.cdnMultiLink.isEmpty) {
        info = 'Get live stream link failed';
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LivePlayPage(room: room)),
        );
      }
    } else {
      info = '${room.nick} is offline.';
    }

    if (info.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(
              info,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          );
        },
      );
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
