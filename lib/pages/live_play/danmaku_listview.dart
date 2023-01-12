import 'package:flutter/material.dart';
import 'package:hot_live/api/danmaku/danmaku_stream.dart';
import 'package:hot_live/model/danmaku.dart';
import 'package:hot_live/model/liveroom.dart';

class DanmakuListView extends StatefulWidget {
  final RoomInfo room;
  final DanmakuStream danmakuStream;

  const DanmakuListView({
    Key? key,
    required this.room,
    required this.danmakuStream,
  }) : super(key: key);

  @override
  State<DanmakuListView> createState() => _DanmakuListViewState();
}

class _DanmakuListViewState extends State<DanmakuListView>
    with AutomaticKeepAliveClientMixin<DanmakuListView> {
  final List<DanmakuInfo> _danmakuList = [];
  final ScrollController _scrollController = ScrollController();

  _scrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<DanmakuInfo>(
      stream: widget.danmakuStream.stream,
      builder: (context, snapshot) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        if (snapshot.hasData) _danmakuList.add(snapshot.data!);

        return ListView.builder(
          controller: _scrollController,
          itemCount: _danmakuList.length,
          padding: const EdgeInsets.only(left: 5, top: 2, right: 5),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final danmaku = _danmakuList[index];
            return Container(
              padding: const EdgeInsets.all(5),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: " ${danmaku.name} : ",
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text: danmaku.action.isEmpty
                          ? danmaku.msg
                          : "${danmaku.action} ${danmaku.count} 个 ${danmaku.msg}",
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
