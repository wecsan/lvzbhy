import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hot_live/common/index.dart';

import 'controller.dart';
import 'widgets/area_card.dart';

class AreasPage extends StatefulWidget {
  const AreasPage({Key? key}) : super(key: key);

  @override
  State<AreasPage> createState() => _AreasPageState();
}

class _AreasPageState extends State<AreasPage> with TickerProviderStateMixin {
  late AreasProvider provider = Provider.of<AreasProvider>(context);
  late TabController tabController;

  static const Map<String, String> names = {
    'bilibili': '哔哩',
    'douyu': '斗鱼',
    'huya': '虎牙',
  };

  @override
  Widget build(BuildContext context) {
    tabController =
        TabController(length: provider.areaList.length, vsync: this);
    return Scaffold(
      appBar: AppBar(
        title: DropdownButton(
          underline: Container(),
          borderRadius: BorderRadius.circular(15),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: Theme.of(context)
              .textTheme
              .headline6
              ?.copyWith(fontWeight: FontWeight.w600),
          value: provider.platform,
          items: provider.platforms
              .map((e) => DropdownMenuItem(value: e, child: Text(names[e]!)))
              .toList(),
          onChanged: (String? value) {
            provider.setPlatform(value ?? 'bilibili');
          },
        ),
        bottom: provider.labelList.isEmpty
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
                tabs: provider.labelList
                    .map<Widget>((e) => Tab(text: e))
                    .toList(),
              ),
      ),
      body: TabBarView(
        controller: tabController,
        children: provider.areaList
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
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1280
        ? 9
        : (screenWidth > 960 ? 7 : (screenWidth > 640 ? 5 : 3));

    return widget.areaList.isNotEmpty
        ? MasonryGridView.count(
            padding: const EdgeInsets.all(5),
            controller: ScrollController(),
            crossAxisCount: crossAxisCount,
            itemCount: widget.areaList.length,
            // physics: (const BouncingScrollPhysics()),
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
