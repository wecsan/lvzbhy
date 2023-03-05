import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:pure_live/common/index.dart';
import 'package:pure_live/modules/live_play/live_play_controller.dart';
import 'package:wakelock/wakelock.dart';

import 'widgets/index.dart';

class LivePlayPage extends GetView<LivePlayController> {
  LivePlayPage({Key? key}) : super(key: key);

  final SettingsService settings = Get.find<SettingsService>();

  @override
  Widget build(BuildContext context) {
    if (settings.enableScreenKeepOn.value) {
      Wakelock.toggle(enable: settings.enableScreenKeepOn.value);
    }

    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          CircleAvatar(
            foregroundImage: controller.room.avatar.isEmpty
                ? null
                : NetworkImage(controller.room.avatar),
            radius: 13,
            backgroundColor: Theme.of(context).disabledColor,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.room.nick,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(
                '${controller.room.platform.toUpperCase()} / ${controller.room.area}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 8),
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
                  child: _buildVideoPlayer(width: screenWidth / 8.0 * 5.0),
                ),
                Flexible(
                  flex: 3,
                  child: Column(children: [
                    _buildResolutions(),
                    const Divider(height: 1),
                    Expanded(
                      child: DanmakuListView(
                        key: controller.danmakuViewKey,
                        room: controller.room,
                      ),
                    ),
                  ]),
                ),
              ])
            : Column(
                children: <Widget>[
                  _buildVideoPlayer(width: screenWidth),
                  _buildResolutions(),
                  const Divider(height: 1),
                  Expanded(
                    child: DanmakuListView(
                      key: controller.danmakuViewKey,
                      room: controller.room,
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FavoriteFloatingButton(room: controller.room),
    );
  }

  Widget _buildVideoPlayer({required double width}) {
    return Hero(
      tag: controller.room.roomId,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          child: controller.success.value
              ? Card(
                  elevation: 0,
                  margin: const EdgeInsets.all(0),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                  clipBehavior: Clip.antiAlias,
                  color: Get.theme.focusColor,
                  child: CachedNetworkImage(
                    imageUrl: controller.room.cover,
                    fit: BoxFit.fill,
                    errorWidget: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.live_tv_rounded, size: 48),
                    ),
                  ),
                )
              : VideoPlayer(
                  key: controller.playerKey,
                  controller: controller.controller!,
                  width: width,
                  height: width / 16.0 * 9.0,
                ),
        ),
      ),
    );
  }

  Widget _buildResolutions() {
    // controller.room watching or followers
    Widget info = Container();
    if (controller.room.followers.isNotEmpty) {
      info = Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.person_rounded, size: 14),
        const SizedBox(width: 4),
        Text(
          readableCount(controller.room.followers),
          style: Get.textTheme.bodySmall,
        ),
      ]);
    } else if (controller.room.watching.isNotEmpty) {
      info = Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.whatshot_rounded, size: 14),
        const SizedBox(width: 4),
        Text(
          readableCount(controller.room.watching),
          style: Get.textTheme.bodySmall,
        ),
      ]);
    }

    // resolution popmenu buttons
    final resButtons = controller.liveStream.keys
        .map<Widget>((res) => PopupMenuButton(
              tooltip: res,
              color: Get.theme.colorScheme.surfaceVariant,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              offset: const Offset(0.0, 5.0),
              position: PopupMenuPosition.under,
              icon: Text(
                res,
                style: Get.theme.textTheme.labelSmall?.copyWith(
                  color: res == controller.selectedResolution
                      ? Get.theme.colorScheme.primary
                      : null,
                ),
              ),
              onSelected: (String url) => controller.setResolution(res, url),
              itemBuilder: (context) => controller.liveStream[res]!.keys
                  .map((cdn) => PopupMenuItem<String>(
                        value: controller.liveStream[res]![cdn],
                        child: Text(
                          cdn,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: controller.liveStream[res]![cdn] ==
                                            controller.selectedStreamUrl
                                        ? Get.theme.colorScheme.primary
                                        : null,
                                  ),
                        ),
                      ))
                  .toList(),
            ))
        .toList();

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Padding(padding: const EdgeInsets.all(8), child: info),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: resButtons,
      ),
    );
  }

  void showDlnaCastDialog() {
    Get.dialog(LiveDlnaPage(datasource: controller.selectedStreamUrl));
  }
}

class FavoriteFloatingButton extends StatelessWidget {
  const FavoriteFloatingButton({
    Key? key,
    required this.room,
  }) : super(key: key);

  final LiveRoom room;

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsService>();
    return settings.isFavorite(room)
        ? FloatingActionButton(
            elevation: 2,
            backgroundColor: Theme.of(context).cardColor,
            tooltip: S.of(context).unfollow,
            onPressed: () => settings.removeRoom(room),
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
            onPressed: () => settings.addRoom(room),
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
                  style: Theme.of(context).textTheme.bodySmall,
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
