import 'package:flutter/cupertino.dart';
import 'package:hot_live/common/index.dart';
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
          body = Text(S.of(context).loading_idle);
        } else if (mode == LoadStatus.failed) {
          body = Text(S.of(context).loading_failed);
        } else if (mode == LoadStatus.noMore) {
          body = Text(S.of(context).loading_nomore);
        } else if (mode == LoadStatus.canLoading) {
          body = Text(S.of(context).loading_canload);
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
