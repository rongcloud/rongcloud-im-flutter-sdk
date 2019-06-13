import 'dart:core';

import 'message.dart';
import 'message_content.dart';

class MessageFactory extends Object {
  factory MessageFactory() =>_getInstance();
  static MessageFactory get instance => _getInstance();
  static MessageFactory _instance;
  MessageFactory._internal() {
    // 初始化
  }
  static MessageFactory _getInstance() {
    if (_instance == null) {
      _instance = new MessageFactory._internal();
    }
    return _instance;
  }

  Message map2Message(Map map) {
    Message message = new Message();
    return message;
  }

  Map message2Map(Message message) {
    Map map = new Map();
    return map;
  }
  
  MessageContent map2MessageContent(Map map) {
    MessageContent content = new MessageContent();
    return content;
  }

  Map messageContent2Map(MessageContent content) {
    Map map = new Map();
    return map;
  }
}