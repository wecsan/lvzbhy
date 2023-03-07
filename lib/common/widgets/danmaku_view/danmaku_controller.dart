import 'models/danmaku_item.dart';
import 'models/danmaku_option.dart';

class DanmakuController {
  DanmakuController();

  bool _running = true;

  /// 是否运行中
  /// 可以调用pause()暂停弹幕
  bool get running => _running;
  set running(e) {
    _running = e;
  }

  Function(List<DanmakuItem>)? onAddItems;
  Function(DanmakuOption)? onUpdateOption;
  Function? onPause;
  Function? onResume;
  Function? onClear;

  setListener(
    Function(List<DanmakuItem>) onAddItems,
    Function(DanmakuOption) onUpdateOption,
    Function onPause,
    Function onResume,
    Function onClear,
  ) {
    this.onAddItems = onAddItems;
    this.onUpdateOption = onUpdateOption;
    this.onPause = onPause;
    this.onResume = onResume;
    this.onClear = onClear;
  }

  DanmakuOption _option = DanmakuOption();
  DanmakuOption get option => _option;
  set option(e) {
    _option = e;
  }

  /// 暂停弹幕
  void pause() {
    onPause?.call();
  }

  /// 继续弹幕
  void resume() {
    onResume?.call();
  }

  /// 清空弹幕
  void clear() {
    onClear?.call();
  }

  /// 添加弹幕
  void addItems(List<DanmakuItem> item) {
    onAddItems?.call(item);
  }

  void updateOption(DanmakuOption option) {
    onUpdateOption?.call(option);
  }
}
