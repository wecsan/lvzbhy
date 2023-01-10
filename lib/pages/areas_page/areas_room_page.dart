import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ice_live_viewer/model/livearea.dart';
import 'package:ice_live_viewer/model/liveroom.dart';
import 'package:ice_live_viewer/utils/http/bilibili.dart';
import 'package:ice_live_viewer/utils/keepalivewrapper.dart';
import 'package:ice_live_viewer/widgets/room_card.dart';

class AreasRoomPage extends StatefulWidget {
  const AreasRoomPage({Key? key, required this.area}) : super(key: key);

  final AreaInfo area;

  @override
  State<AreasRoomPage> createState() => _AreasRoomPageState();
}

class _AreasRoomPageState extends State<AreasRoomPage> {
  List<RoomInfo> roomsList = [];
  int pageIndex = 1;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    roomsList = await BilibiliApi.getAreaRooms(widget.area, pageIndex);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text(widget.area.areaName)),
      body: KeepAliveWrapper(
        child: MasonryGridView.count(
          padding: const EdgeInsets.all(5),
          controller: ScrollController(),
          crossAxisCount: screenWidth > 1280
              ? 8
              : (screenWidth > 960 ? 6 : (screenWidth > 640 ? 4 : 2)),
          itemCount: roomsList.length,
          // physics: (const BouncingScrollPhysics()),
          itemBuilder: (context, index) =>
              RoomCard(room: roomsList[index], dense: true),
        ),
      ),
    );
  }
}
