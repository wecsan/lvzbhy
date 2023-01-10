import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ice_live_viewer/model/livearea.dart';
import 'package:ice_live_viewer/utils/http/httpapi.dart';
import 'package:ice_live_viewer/utils/keepalivewrapper.dart';

import 'areas_room.dart';

class AreasPage extends StatefulWidget {
  const AreasPage({Key? key}) : super(key: key);

  @override
  State<AreasPage> createState() => _AreasPageState();
}

class _AreasPageState extends State<AreasPage> with TickerProviderStateMixin {
  TabController? tabController;
  List<List<AreaInfo>> areaList = [];
  int labelIndex = 0;
  String platform = 'bilibili';

  @override
  void initState() {
    super.initState();
    _onLoading();
  }

  Future<void> _onLoading() async {
    areaList.clear();
    areaList = await HttpApi.getAreaList(platform);
    tabController = TabController(length: areaList.length, vsync: this);
    setState(() {});
  }

  void _changePlatform(String name) async {
    platform = name;
    tabController!.dispose();
    await _onLoading();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AREAS',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        bottom: areaList.isEmpty
            ? const PreferredSize(
                child: SizedBox(height: 0),
                preferredSize: Size.fromHeight(0),
              )
            : TabBar(
                controller: tabController,
                isScrollable: true,
                labelPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Theme.of(context).hintColor,
                labelStyle: Theme.of(context).textTheme.labelLarge,
                indicatorColor: Theme.of(context).primaryColor,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: areaList.map((e) => Text(e[0].typeName)).toList(),
                onTap: (value) {
                  setState(() => labelIndex = value);
                },
              ),
      ),
      body: areaList.isNotEmpty
          ? MasonryGridView.count(
              padding: const EdgeInsets.all(5),
              controller: ScrollController(),
              crossAxisCount: screenWidth > 1280
                  ? 10
                  : (screenWidth > 960 ? 8 : (screenWidth > 640 ? 5 : 3)),
              itemCount: areaList[labelIndex].length,
              // physics: (const BouncingScrollPhysics()),
              itemBuilder: (context, index) => AreaCard(
                area: areaList[labelIndex][index],
              ),
            )
          : const AreaEmptyView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('Bilibili'),
                      onTap: () => _changePlatform("bilibili"),
                    ),
                    ListTile(
                      title: const Text('Douyu'),
                      onTap: () => _changePlatform("douyu"),
                    ),
                    ListTile(
                      title: const Text('Huya'),
                      onTap: () => _changePlatform("huya"),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.video_collection_rounded),
      ),
    );
  }
}

class AreaEmptyView extends StatelessWidget {
  const AreaEmptyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.live_tv_rounded,
            size: 144,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 32),
          Text.rich(
              TextSpan(children: [
                TextSpan(
                    text: "No Area Found\n\n",
                    style: Theme.of(context).textTheme.headlineLarge),
                TextSpan(
                    text: "Click the button below\nto switch platform",
                    style: Theme.of(context).textTheme.headline3),
              ]),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class AreaCard extends StatelessWidget {
  const AreaCard({
    Key? key,
    required this.area,
  }) : super(key: key);

  final AreaInfo area;

  void onTap(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AreasRoomPage(area: area)),
    );
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Card(
                margin: const EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                clipBehavior: Clip.antiAlias,
                color: Theme.of(context).focusColor,
                elevation: 0,
                child: Image.network(
                  area.areaPic,
                  fit: BoxFit.fill,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Text(
                      'Cover\nNot Found',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              dense: true,
              title: Text(
                area.areaName,
                maxLines: 1,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    area.typeName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                  Text(
                    area.platform,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }
}
