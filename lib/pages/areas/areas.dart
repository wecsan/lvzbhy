import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hot_live/model/livearea.dart';
import 'package:hot_live/widgets/area_card.dart';
import 'package:hot_live/provider/areas_provider.dart';
import 'package:hot_live/widgets/keep_alive_wrapper.dart';
import 'package:hot_live/widgets/empty_view.dart';
import 'package:provider/provider.dart';

class AreasPage extends StatefulWidget {
  const AreasPage({Key? key}) : super(key: key);

  @override
  State<AreasPage> createState() => _AreasPageState();
}

class _AreasPageState extends State<AreasPage> with TickerProviderStateMixin {
  late AreasProvider provider = Provider.of<AreasProvider>(context);
  late TabController tabController =
      TabController(length: provider.labelList.length, vsync: this);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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

class AreaGridView extends StatefulWidget {
  const AreaGridView({Key? key, required this.areaList}) : super(key: key);

  final List<AreaInfo> areaList;

  @override
  State<AreaGridView> createState() => _AreaGridViewState();
}

class _AreaGridViewState extends State<AreaGridView> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1280
        ? 12
        : (screenWidth > 960 ? 9 : (screenWidth > 640 ? 6 : 3));

    return widget.areaList.isNotEmpty
        ? KeepAliveWrapper(
            child: MasonryGridView.count(
              padding: const EdgeInsets.all(5),
              controller: ScrollController(),
              crossAxisCount: crossAxisCount,
              itemCount: widget.areaList.length,
              // physics: (const BouncingScrollPhysics()),
              itemBuilder: (context, index) =>
                  AreaCard(area: widget.areaList[index]),
            ),
          )
        : const EmptyView(
            icon: Icons.area_chart_outlined,
            title: 'No Area Found',
            subtitle: 'Click the button below\nto switch platform',
          );
  }
}
