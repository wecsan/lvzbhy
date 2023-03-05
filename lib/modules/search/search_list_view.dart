import 'package:cached_network_image/cached_network_image.dart';

import 'package:get/get.dart';
import 'package:pure_live/common/index.dart';
import 'package:pure_live/modules/search/search_list_controller.dart';
import 'package:pure_live/routes/app_pages.dart';

class SearchListView extends StatelessWidget {
  final String tag;

  const SearchListView(this.tag, {Key? key}) : super(key: key);

  SearchListController get controller =>
      Get.find<SearchListController>(tag: tag);

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.list.isNotEmpty
        ? ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(8),
            itemCount: controller.list.length,
            itemBuilder: (context, index) {
              final room = controller.list[index];
              return OwnerCard(room: room);
            })
        : EmptyView(
            icon: Icons.live_tv_rounded,
            title: S.of(context).empty_search_title,
            subtitle: S.of(context).empty_search_subtitle,
          ));
  }
}

class OwnerCard extends StatefulWidget {
  const OwnerCard({Key? key, required this.room}) : super(key: key);

  final LiveRoom room;

  @override
  State<OwnerCard> createState() => _OwnerCardState();
}

class _OwnerCardState extends State<OwnerCard> {
  SettingsService settings = Get.find<SettingsService>();

  void _onTap(BuildContext context) async {
    AppPages.toLivePlay(widget.room);
  }

  @override
  Widget build(BuildContext context) {
    final followedStyle = Theme.of(context)
        .textTheme
        .labelLarge
        ?.copyWith(color: Theme.of(context).colorScheme.error);

    return Card(
      child: ListTile(
        onTap: () => _onTap(context),
        leading: CircleAvatar(
          foregroundImage: widget.room.avatar.isNotEmpty
              ? CachedNetworkImageProvider(widget.room.avatar)
              : null,
          radius: 20,
          backgroundColor: Theme.of(context).disabledColor,
        ),
        title: Text(
          widget.room.nick,
          maxLines: 1,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "${widget.room.platform} - ${widget.room.area}",
          maxLines: 1,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: settings.isFavorite(widget.room)
            ? ElevatedButton(
                onPressed: () => settings.removeRoom(widget.room),
                child: Text(S.of(context).followed, style: followedStyle),
              )
            : ElevatedButton(
                onPressed: () => settings.addRoom(widget.room),
                child: Text(S.of(context).follow),
              ),
      ),
    );
  }
}
