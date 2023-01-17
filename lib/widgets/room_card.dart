import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hot_live/generated/l10n.dart';
import 'package:hot_live/model/liveroom.dart';
import 'package:hot_live/pages/live_play/live_play.dart';
import 'package:hot_live/widgets/keep_alive_wrapper.dart';

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
    if (room.liveStatus == LiveStatus.live) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LivePlayPage(room: room)),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(
              S.of(context).info_is_offline(room.nick),
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
        margin: const EdgeInsets.all(7.5),
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
                      ? CachedNetworkImage(
                          imageUrl: room.cover,
                          fit: BoxFit.fill,
                          errorWidget: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.live_tv_rounded,
                              size: dense ? 30 : 48,
                            ),
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.tv_off_rounded,
                                size: dense ? 38 : 48,
                              ),
                              Text(
                                S.of(context).offline,
                                style: TextStyle(
                                  fontSize: dense ? 18 : 26,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          ),
                        ),
                ),
              ),
              ListTile(
                dense: dense,
                contentPadding:
                    dense ? const EdgeInsets.only(left: 8, right: 10) : null,
                horizontalTitleGap: dense ? 8 : null,
                leading: CircleAvatar(
                  foregroundImage: room.avatar.isNotEmpty
                      ? CachedNetworkImageProvider(room.avatar)
                      : null,
                  radius: dense ? 18 : null,
                  backgroundColor: Theme.of(context).disabledColor,
                ),
                title: Text(
                  room.nick,
                  maxLines: 1,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  room.title,
                  maxLines: 1,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: dense
                    ? null
                    : Text(
                        room.platform.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
