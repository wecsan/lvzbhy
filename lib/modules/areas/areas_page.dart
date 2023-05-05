import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:pure_live/common/index.dart';

import 'areas_controller.dart';
import 'widgets/area_card.dart';

class AreasPage extends GetView<AreasController> {
  const AreasPage({Key? key}) : super(key: key);

  bool get showAction => Get.size.width <= 480;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        scrolledUnderElevation: 0,
        leading: showAction ? const MenuButton() : null,
        actions: showAction ? [const SearchButton()] : null,
        title: TabBar(
          controller: controller.tabController,
          isScrollable: true,
          labelStyle:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          labelPadding: const EdgeInsets.symmetric(horizontal: 12),
          indicatorSize: TabBarIndicatorSize.label,
          tabs: Sites.supportSites.map((e) => Tab(text: e.name)).toList(),
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: Sites.supportSites
            .map((e) => AreaGridView(
                  labels: controller.data[e.id]!['labels'],
                  areas: controller.data[e.id]!['areas'],
                ))
            .toList(),
      ),
    );
  }
}

class AreaGridView extends StatefulWidget {
  const AreaGridView({Key? key, required this.labels, required this.areas})
      : super(key: key);

  final List<String> labels;
  final List<List<LiveArea>> areas;

  @override
  State<AreaGridView> createState() => _AreaGridViewState();
}

class _AreaGridViewState extends State<AreaGridView>
    with SingleTickerProviderStateMixin {
  late TabController tabController =
      TabController(length: widget.labels.length, vsync: this);

  int get crossAxisCount {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1280
        ? 9
        : (screenWidth > 960 ? 7 : (screenWidth > 640 ? 5 : 3));
    return crossAxisCount;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: tabController,
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: widget.labels.map<Widget>((e) => Tab(text: e)).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children:
                widget.areas.map<Widget>((e) => buildAreasView(e)).toList(),
          ),
        ),
      ],
    );
  }

  Widget buildAreasView(List<LiveArea> area) {
    return widget.areas.isNotEmpty
        ? MasonryGridView.count(
            padding: const EdgeInsets.all(5),
            controller: ScrollController(),
            crossAxisCount: crossAxisCount,
            itemCount: area.length,
            itemBuilder: (context, index) => AreaCard(area: area[index]),
          )
        : EmptyView(
            icon: Icons.area_chart_outlined,
            title: S.of(context).empty_areas_title,
            subtitle: S.of(context).empty_areas_subtitle,
          );
  }
}
