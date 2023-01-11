import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class OnLoadingFooter extends StatelessWidget {
  const OnLoadingFooter({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomFooter(
      builder: (context, mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = const Text("pull up load");
        } else if (mode == LoadStatus.failed) {
          body = const Text("Load Failed! Drag Retry!");
        } else if (mode == LoadStatus.noMore) {
          body = const Text("No more Data");
        } else if (mode == LoadStatus.canLoading) {
          body = const Text("release to load");
        } else {
          body = const CupertinoActivityIndicator();
        }
        return SizedBox(
          height: 55.0,
          child: Center(child: body),
        );
      },
    );
  }
}
