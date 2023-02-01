import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hot_live/common/index.dart';
import 'package:hot_live/pages/index.dart';

import 'widgets/area_card.dart';

class AreasPage extends StatefulWidget {
  const AreasPage({Key? key}) : super(key: key);

  @override
  State<AreasPage> createState() => _AreasPageState();
}

class _AreasPageState extends State<AreasPage> with TickerProviderStateMixin {
  late AreasProvider provider = Provider.of<AreasProvider>(context);
  late TabController tabController;

  bool get showAction => MediaQuery.of(context).size.width > 640;

  @override
  Widget build(BuildContext context) {
    tabController = TabController(length: provider.labels.length, vsync: this);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        scrolledUnderElevation: 0,
        title: DefaultTabController(
          initialIndex: provider.platformIndex,
          length: provider.platformAreas.length,
          child: TabBar(
            isScrollable: true,
            labelColor: Theme.of(context).colorScheme.onBackground,
            labelStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            unselectedLabelColor: Theme.of(context).disabledColor,
            labelPadding: const EdgeInsets.symmetric(horizontal: 12),
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: provider.platformAreas.values
                .map((value) => Tab(text: value.name))
                .toList(),
            onTap: (index) => provider
                .changePlatform(provider.platformAreas.keys.toList()[index]),
          ),
        ),
        leading: showAction
            ? null
            : IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchPage()),
                  );
                },
                icon: const Icon(CustomIcons.search),
              ),
        actions: showAction
            ? null
            : [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()),
                    );
                  },
                  icon: const Icon(Icons.settings),
                ),
                const SizedBox(width: 4),
              ],
        bottom: provider.labels.isEmpty
            ? const PreferredSize(
                child: SizedBox(height: 0),
                preferredSize: Size.fromHeight(0),
              )
            : TabBar(
                controller: tabController,
                isScrollable: true,
                labelColor: Theme.of(context).colorScheme.onBackground,
                unselectedLabelColor: Theme.of(context).disabledColor,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: Theme.of(context).colorScheme.primary,
                tabs: provider.labels.map<Widget>((e) => Tab(text: e)).toList(),
              ),
      ),
      body: TabBarView(
        controller: tabController,
        children: provider.areas
            .map<Widget>((e) => AreaGridView(areaList: e))
            .toList(),
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
  int get crossAxisCount {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1280
        ? 9
        : (screenWidth > 960 ? 7 : (screenWidth > 640 ? 5 : 3));
    return crossAxisCount;
  }

  @override
  Widget build(BuildContext context) {
    return widget.areaList.isNotEmpty
        ? MasonryGridView.count(
            padding: const EdgeInsets.all(5),
            controller: ScrollController(),
            crossAxisCount: crossAxisCount,
            itemCount: widget.areaList.length,
            itemBuilder: (context, index) =>
                AreaCard(area: widget.areaList[index]),
          )
        : EmptyView(
            icon: Icons.area_chart_outlined,
            title: S.of(context).empty_areas_title,
            subtitle: S.of(context).empty_areas_subtitle,
          );
  }
}
