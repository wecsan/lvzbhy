import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:pure_live/modules/popular/popular_grid_controller.dart';

import '../../common/core/sites.dart';

class PopularController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  int index = 0;

  PopularController() {
    tabController = TabController(
      length: Sites.supportSites.length,
      vsync: this,
    );
    tabController.animation?.addListener(() {
      var currentIndex = (tabController.animation?.value ?? 0).round();
      if (index == currentIndex) {
        return;
      }

      index = currentIndex;
      var controller =
          Get.find<PopularGridController>(tag: Sites.supportSites[index].id);

      if (controller.list.isEmpty && !controller.pageEmpty.value) {
        controller.onRefresh();
      }
    });
  }

  @override
  void onInit() {
    for (var site in Sites.supportSites) {
      Get.put(
        PopularGridController(site),
        tag: site.id,
      );
    }
    super.onInit();
  }
}
