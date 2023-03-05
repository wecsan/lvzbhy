import 'package:cached_network_image/cached_network_image.dart';
import 'package:pure_live/common/index.dart';
import 'package:pure_live/pages/live_play/view.dart';

// ignore: must_be_immutable
class RoomCard extends StatelessWidget {
  RoomCard({
    Key? key,
    required this.room,
    this.onLongPress,
    this.dense = false,
  }) : super(key: key);

  final RoomInfo room;
  final Function()? onLongPress;
  final bool dense;

  bool loading = false;

  void onTap(BuildContext context) async {
    // set loading tag avoid double click
    if (loading) return;
    loading = true;
    final fullRoom = await LiveApi.getRoomInfo(room);
    loading = false;

    if (fullRoom.liveStatus == LiveStatus.live) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LivePlayPage(
            room: fullRoom,
            preferResolution:
                Provider.of<SettingsProvider>(context).preferResolution,
          ),
        ),
      );
    } else {
      final info = fullRoom.liveStatus == LiveStatus.offline
          ? S.of(context).info_is_offline(fullRoom.nick)
          : S.of(context).info_is_replay(fullRoom.nick);
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
    return Card(
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
            Stack(
              children: [
                Hero(
                  tag: room.roomId,
                  child: AspectRatio(
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
                              errorWidget: (context, error, stackTrace) =>
                                  Center(
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
                ),
                if (room.liveStatus == LiveStatus.live &&
                    room.watching.isNotEmpty)
                  Positioned(
                    right: dense ? 1 : 4,
                    bottom: dense ? 1 : 4,
                    child: CountChip(
                      icon: Icons.whatshot_rounded,
                      count: readableCount(room.watching),
                      dense: dense,
                    ),
                  ),
              ],
            ),
            ListTile(
              dense: dense,
              minLeadingWidth: dense ? 34 : null,
              contentPadding:
                  dense ? const EdgeInsets.only(left: 8, right: 10) : null,
              horizontalTitleGap: dense ? 8 : null,
              leading: CircleAvatar(
                foregroundImage: room.avatar.isNotEmpty
                    ? CachedNetworkImageProvider(room.avatar)
                    : null,
                radius: dense ? 17 : null,
                backgroundColor: Theme.of(context).disabledColor,
              ),
              title: Text(
                room.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: dense ? 12.5 : 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                room.nick,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: dense ? 12 : 14,
                ),
              ),
              trailing: dense
                  ? null
                  : Text(
                      room.platform.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}

class CountChip extends StatelessWidget {
  const CountChip({
    Key? key,
    required this.icon,
    required this.count,
    this.dense = false,
  }) : super(key: key);

  final IconData icon;
  final String count;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const StadiumBorder(),
      color: Colors.black.withOpacity(0.4),
      shadowColor: Colors.transparent,
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(dense ? 4 : 6),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(0.8),
              size: dense ? 13 : 16,
            ),
            const SizedBox(width: 4),
            Text(
              count,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: dense ? 10 : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
