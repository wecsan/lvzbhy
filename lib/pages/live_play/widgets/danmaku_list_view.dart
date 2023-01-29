import 'package:flutter/rendering.dart';
import 'package:hot_live/common/index.dart';

class DanmakuListView extends StatefulWidget {
  final RoomInfo room;
  final DanmakuStream danmakuStream;

  const DanmakuListView({
    Key? key,
    required this.room,
    required this.danmakuStream,
  }) : super(key: key);

  @override
  State<DanmakuListView> createState() => DanmakuListViewState();
}

class DanmakuListViewState extends State<DanmakuListView>
    with AutomaticKeepAliveClientMixin<DanmakuListView> {
  final List<DanmakuInfo> _danmakuList = [];
  final ScrollController _scrollController = ScrollController();
  bool _scrollHappen = false;

  @override
  void initState() {
    super.initState();
    _danmakuList.add(DanmakuInfo("系统信息", "欢迎进入${widget.room.nick}的直播间"));
    widget.danmakuStream.listen((info) {
      setState(() => _danmakuList.add(info));
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollHappen) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.linearToEaseOut,
    );
  }

  bool _userScrollAction(UserScrollNotification notification) {
    if (notification.direction == ScrollDirection.forward) {
      setState(() => _scrollHappen = true);
    } else if (notification.direction == ScrollDirection.reverse) {
      final pos = _scrollController.position;
      if (pos.maxScrollExtent - pos.pixels <= 100) {
        setState(() => _scrollHappen = false);
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    super.build(context);
    return Stack(
      children: [
        NotificationListener<UserScrollNotification>(
          onNotification: _userScrollAction,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _danmakuList.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final danmaku = _danmakuList[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                alignment: Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "${danmaku.name}: ",
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              ?.copyWith(fontSize: 13.5),
                        ),
                        TextSpan(
                          text: danmaku.action.isEmpty
                              ? danmaku.msg
                              : "${danmaku.action} ${danmaku.count} 个 ${danmaku.msg}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_scrollHappen)
          Positioned(
            left: 12,
            bottom: 12,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.arrow_downward_rounded),
              label: const Text('回到底部'),
              onPressed: () {
                setState(() => _scrollHappen = false);
                _scrollToBottom();
              },
            ),
          )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
