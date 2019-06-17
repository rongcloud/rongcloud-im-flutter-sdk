import 'dart:core';

import 'message.dart';
import 'message_content.dart';
import 'text_message.dart';
import 'dart:convert' show json;

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
    message.conversationType = map["conversationType"];
    message.targetId = map["targetId"];
    message.messageId = map["messageId"];
    message.messageDirection = map["messageDirection"];
    message.senderUserId = map["senderUserId"];
    message.receivedStatus = map["receivedStatus"];
    message.sentStatus = map["sentStatus"];
    message.sentTime = map["sentTime"];
    message.objectName = map["objectName"];
    message.messageUId = map["messageUId"];
    String contenStr = map["content"];
    MessageContent content = string2MessageContent(contenStr,message.objectName);
    if(content != null) {
      message.content = content;
    }else {
      print(message.objectName+":该消息不能被解析!!!");
      Map map = json.decode(contenStr.toString());
      message.originContentMap = map;
    }
    return message;
  }

  Map message2Map(Message message) {
    Map map = new Map();
    return map;
  }
  
  MessageContent string2MessageContent(String contentS,String objectName) {
    MessageContent content = null;
    if(objectName == TextMessage.objectName) {
      content = new TextMessage();
      content.decode(contentS);
    }
    return content;
  }


  Map messageContent2Map(MessageContent content) {
    Map map = new Map();
    return map;
  }
}