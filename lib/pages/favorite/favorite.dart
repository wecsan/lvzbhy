import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ice_live_viewer/pages/settings.dart';
import 'package:ice_live_viewer/utils/keepalivewrapper.dart';

import 'package:ice_live_viewer/model/liveroom.dart';
import 'package:ice_live_viewer/provider/favorite_provider.dart';
import 'package:ice_live_viewer/widgets/room_card.dart';
import 'package:provider/provider.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FavoriteProvider provider = Provider.of<FavoriteProvider>(context);
    TextEditingController addLinkController = TextEditingController();
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "FAVORITES",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          provider.isHideOffline == false
              ? IconButton(
                  onPressed: () => provider.hideOfflineRooms(),
                  tooltip: 'Hide Offline Rooms',
                  icon: const Icon(Icons.remove_circle_outline_rounded))
              : IconButton(
                  onPressed: () => provider.showOfflineRooms(),
                  tooltip: 'Show Offline Rooms',
                  icon: const Icon(Icons.add_circle_outline_rounded)),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: RoomGridView(screenWidth: screenWidth, favoritePod: provider),
      floatingActionButton: FavoriteAddButton(
          controller: addLinkController, roomsProvider: provider),
    );
  }
}

class RoomGridView extends StatelessWidget {
  const RoomGridView(
      {Key? key, required this.screenWidth, required this.favoritePod})
      : super(key: key);

  final double screenWidth;
  final FavoriteProvider favoritePod;

  @override
  Widget build(BuildContext context) {
    if (favoritePod.roomsList.isNotEmpty) {
      return KeepAliveWrapper(
        child: MasonryGridView.count(
            padding: const EdgeInsets.all(5),
            controller: ScrollController(),
            crossAxisCount: screenWidth > 1280
                ? 4
                : (screenWidth > 960 ? 3 : (screenWidth > 640 ? 2 : 1)),
            itemCount: favoritePod.roomsList.length,
            //physics: (const BouncingScrollPhysics()),
            itemBuilder: (context, index) {
              RoomInfo room = favoritePod.roomsList[index];
              return RoomCard(
                room: room,
                onLongPress: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text(room.title),
                          content: Text('RoomId' +
                              room.roomId +
                              '\nLiveStatus: ' +
                              room.liveStatus.name +
                              '\ncover' +
                              room.cover +
                              '\n' +
                              room.cdnMultiLink.toString()),
                          actions: [
                            TextButton(
                              onPressed: () {
                                favoritePod.removeRoom(room);
                                return Navigator.pop(context);
                              },
                              child: const Text("Remove"),
                            ),
                            TextButton(
                              onPressed: () {
                                favoritePod.moveToTop(room);
                                return Navigator.pop(context);
                              },
                              child: const Text("Move to top"),
                            ),
                          ],
                        )),
              );
            }),
      );
    } else {
      return const RoomEmptyView();
    }
  }
}

class RoomEmptyView extends StatelessWidget {
  const RoomEmptyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.post_add_rounded,
            size: 144,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 32),
          Text.rich(
              TextSpan(children: [
                TextSpan(
                    text: "No Favorites\n\n",
                    style: Theme.of(context).textTheme.headlineLarge),
                TextSpan(
                    text: "Click the button below\nto add live link",
                    style: Theme.of(context).textTheme.headline3),
              ]),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class FavoriteAddButton extends StatelessWidget {
  const FavoriteAddButton({
    Key? key,
    required this.controller,
    required this.roomsProvider,
  }) : super(key: key);

  final TextEditingController controller;
  final FavoriteProvider roomsProvider;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Add your link"),
              content: TextField(controller: controller),
              actions: [
                TextButton(
                    onPressed: () {
                      roomsProvider.addRoomLink(controller.text);
                      Navigator.pop(context);
                    },
                    child: const Text("Add")),
              ],
            );
          },
        );
      },
      child: const Icon(Icons.add),
    );
  }
}
