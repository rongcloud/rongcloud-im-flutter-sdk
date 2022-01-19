import 'package:flutter/material.dart';

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

  Map<String, Map<Widget, EventCallback>> _events = new Map();

  //设置事件监听，当有人调用 commit ，并且 eventKey 一样的时候会触发此方法
  void addListener(String eventKey, Widget widget, EventCallback callback) {
    Map<Widget, EventCallback>? callbacks = _events[eventKey];
    if (callbacks == null) {
      callbacks = Map();
    }
    callbacks[widget] = callback;

    _events[eventKey] = callbacks;
  }

  //移除监听
  void removeListener(String eventKey, Widget widget) {
    // _events.remove(eventKey);
    Map<Widget, EventCallback>? callbacks = _events[eventKey];
    if (callbacks != null) {
      callbacks.remove(widget);
    }
  }

  //提交事件
  void commit(String eventKey, Object? arg) {
    Map<Widget, EventCallback>? callbacks = _events[eventKey];
    if (callbacks != null) {
      callbacks.values.forEach((callback) {
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
  static const String ClearMessage = "clearMessage";
}
