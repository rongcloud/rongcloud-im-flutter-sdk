import 'dart:core';

import 'package:rongcloud_im_plugin/image_message.dart';

import 'message.dart';
import 'message_content.dart';
import 'text_message.dart';
import 'conversation.dart';
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

  Message string2Message(String msgJsonStr) {
    Map map = json.decode(msgJsonStr);
    return map2Message(map);
  }

  Conversation string2Conversation(String conJsonStr) {
    Map map = json.decode(conJsonStr);
    return map2Conversation(map);
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
      print(message.objectName+":该消息不能被解析!消息内容被保存在 Message.originContentMap 中");
      Map map = json.decode(contenStr.toString());
      message.originContentMap = map;
    }
    return message;
  }

  Conversation map2Conversation(Map map) {
    Conversation con = new Conversation();
    con.conversationType = map["conversationType"];
    con.targetId = map["targetId"];
    con.unreadMessageCount = map["unreadMessageCount"];
    con.receivedStatus = map["receivedStatus"];
    con.sentStatus = map["sentStatus"];
    con.sentTime = map["sentTime"];
    con.objectName = map["objectName"];
    con.senderUserId = map["senderUserId"];
    con.latestMessageId = map["latestMessageId"];

    String contenStr = map["content"];
    MessageContent content = string2MessageContent(contenStr,con.objectName);
    if(content != null) {
      con.latestMessageContent = content;
    }else {
      print(con.objectName+":该消息不能被解析!消息内容被保存在 Conversation.originContentMap 中");
      Map map = json.decode(contenStr.toString());
      con.originContentMap = map;
    }
    return con;
  }
  
  MessageContent string2MessageContent(String contentS,String objectName) {
    MessageContent content = null;
    if(objectName == TextMessage.objectName) {
      content = new TextMessage();
      content.decode(contentS);
    }else if(objectName == ImageMessage.objectName) {
      content = new ImageMessage();
      content.decode(contentS);
    }
    return content;
  }


  Map messageContent2Map(MessageContent content) {
    Map map = new Map();
    return map;
  }
}