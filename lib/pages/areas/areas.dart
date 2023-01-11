import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ice_live_viewer/model/livearea.dart';
import 'package:ice_live_viewer/provider/areas_provider.dart';
import 'package:ice_live_viewer/utils/keepalivewrapper.dart';
import 'package:ice_live_viewer/widgets/empty_view.dart';
import 'package:provider/provider.dart';

import 'areas_room.dart';

class AreasPage extends StatefulWidget {
  const AreasPage({Key? key}) : super(key: key);

  @override
  State<AreasPage> createState() => _AreasPageState();
}

class _AreasPageState extends State<AreasPage> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AreasProvider provider = Provider.of<AreasProvider>(context);
    tabController =
        TabController(length: provider.labelList.length, vsync: this);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AREAS',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                provider.platform.toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
        ],
        bottom: provider.labelList.isEmpty
            ? const PreferredSize(
                child: SizedBox(height: 0),
                preferredSize: Size.fromHeight(0),
              )
            : TabBar(
                controller: tabController,
                isScrollable: true,
                labelPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                labelColor: Theme.of(context).textTheme.bodyText1!.color,
                unselectedLabelColor: Theme.of(context).disabledColor,
                labelStyle: Theme.of(context).textTheme.labelLarge,
                indicatorColor: Theme.of(context).primaryColor,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: provider.labelList.map<Widget>((e) => Text(e)).toList(),
              ),
      ),
      body: TabBarView(
        controller: tabController,
        children: provider.areaList
            .map<Widget>((e) => AreaGridView(areaList: e))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: provider.platforms
                      .map<Widget>(
                        (e) => ListTile(
                          title: Text(e.toUpperCase()),
                          trailing: provider.platform == e
                              ? const Icon(Icons.check_circle_rounded)
                              : const SizedBox(height: 0),
                          onTap: () {
                            provider.setPlatform(e);
                            tabController = TabController(
                              initialIndex: 0,
                              length: provider.labelList.length,
                              vsync: this,
                            );
                            Navigator.of(context).pop();
                          },
                        ),
                      )
                      .toList(),
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

class AreaGridView extends StatelessWidget {
  const AreaGridView({Key? key, required this.areaList}) : super(key: key);

  final List<AreaInfo> areaList;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return areaList.isNotEmpty
        ? KeepAliveWrapper(
            child: MasonryGridView.count(
              padding: const EdgeInsets.all(5),
              controller: ScrollController(),
              crossAxisCount: screenWidth > 1280
                  ? 10
                  : (screenWidth > 960 ? 8 : (screenWidth > 640 ? 5 : 3)),
              itemCount: areaList.length,
              // physics: (const BouncingScrollPhysics()),
              itemBuilder: (context, index) => AreaCard(area: areaList[index]),
            ),
          )
        : const EmptyView(
            icon: Icons.area_chart_outlined,
            title: 'No Area Found',
            subtitle: 'Click the button below\nto switch platform',
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
