import 'package:get/get.dart';
import 'package:pure_live/common/index.dart';

class AreasController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  int index = 0;

  AreasController() {
    tabController = TabController(
      length: Sites.supportSites.length,
      vsync: this,
    );
  }

  Map<String, Map> data = {};

  @override
  void onInit() async {
    for (var site in Sites.supportSites) {
      var areas = await site.liveSite.getAreaList();
      var lables = areas.map<String>((e) => e.first.typeName).toList();
      data[site.id] = {
        'labels': lables,
        'areas': areas,
      };
    }
    super.onInit();
  }
}
