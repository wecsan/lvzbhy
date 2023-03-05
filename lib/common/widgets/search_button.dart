import 'package:get/get.dart';
import 'package:pure_live/common/index.dart';

import '../../routes/app_pages.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => Get.toNamed(AppPages.search),
          icon: const Icon(CustomIcons.search),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
