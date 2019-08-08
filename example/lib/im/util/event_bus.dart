typedef void EventCallback(arg);

class EventBus {
  factory EventBus() => _getInstance();
  static EventBus get instance => _getInstance();
  static EventBus _instance;
  EventBus._internal() {
    // 初始化
  }
  static EventBus _getInstance() {
    if (_instance == null) {
      _instance = new EventBus._internal();
    }
    return _instance;
  }

  Map<String,EventCallback> _events = new Map();


  void addlistener(String eventKey,EventCallback callback) {
    if(eventKey == null || callback == null) return;
    _events[eventKey] = callback;
  }

  void removelistener(String eventKey) {
    if(eventKey == null) return;
    _events.remove(eventKey);
  }

  void commit(String eventKey,Object arg) {
    if(eventKey == null) return;
    EventCallback callback = _events[eventKey];
    if(callback != null) {
      callback(arg);
    }
  }
}

class EventKeys {
  static const String ConversationPageDispose = "ConversationPageDispose";
}