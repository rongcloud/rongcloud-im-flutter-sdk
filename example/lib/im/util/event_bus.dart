typedef void EventCallback(arg);

//事件总线
class EventBus {
  factory EventBus() => _getInstance()!;

  static EventBus? get instance => _getInstance();
  static EventBus? _instance;

  EventBus._internal() {
    // 初始化
  }

  static EventBus? _getInstance() {
    if (_instance == null) {
      _instance = new EventBus._internal();
    }
    return _instance;
  }

  Map<String, List> _events = new Map();

  //设置事件监听，当有人调用 commit ，并且 eventKey 一样的时候会触发此方法
  void addListener(String eventKey, EventCallback callback) {
    List? callbacks = _events[eventKey];
    if (callbacks == null) {
      callbacks = [];
    }
    callbacks.add(callback);
    _events[eventKey] = callbacks;
  }

  //移除监听
  void removeListener(String eventKey) {
    _events.remove(eventKey);
  }

  //提交事件
  void commit(String eventKey, Object? arg) {
    List? callbacks = _events[eventKey];
    if (callbacks != null) {
      callbacks.forEach((callback) {
        callback(arg);
      });
    }
  }
}

class EventKeys {
  static const String ConversationPageDispose = "ConversationPageDispose";
  static const String ReceiveMessage = "ReceiveMessage";
  static const String ReceiveReadReceipt = "ReceiveReadReceipt";
  static const String ReceiveReceiptRequest = "ReceiveReceiptRequest";
  static const String ReceiveReceiptResponse = "ReceiveReceiptResponse";
  static const String LongPressUserPortrait = "LongPressUserPortrait";
  static const String UpdateNotificationQuietStatus = "UpdateNotificationQuietStatus";
  static const String ForwardMessageEnd = "ForwardMessageEnd";
  static const String BurnMessage = "BurnMessage";
  static const String BlockMessage = "BlockMessage";
}
