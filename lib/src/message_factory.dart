import 'dart:core';
import 'dart:convert' show json;

import '../rongcloud_im_plugin.dart';
import 'message.dart';
import 'conversation.dart';
import 'chatroom_info.dart';

import 'message_content.dart';
import 'text_message.dart';
import 'image_message.dart';
import 'voice_message.dart';
import 'sight_message.dart';

import 'util/type_util.dart';
import 'recall_notification_message.dart';

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
    if(TypeUtil.isEmptyString(msgJsonStr)) {
      return null;
    }
    Map map = json.decode(msgJsonStr);
    return map2Message(map);
  }

  Conversation string2Conversation(String conJsonStr) {
    if(TypeUtil.isEmptyString(conJsonStr)) {
      return null;
    }
    Map map = json.decode(conJsonStr);
    return map2Conversation(map);
  }

  ChatRoomInfo map2ChatRoomInfo(Map map) {
    ChatRoomInfo chatRoomInfo = new ChatRoomInfo();
    chatRoomInfo.targetId = map["targetId"];
    chatRoomInfo.memberOrder = map["memberOrder"];
    chatRoomInfo.totalMemeberCount = map["totalMemeberCount"];
    List memList = new List();
    for(Map memMap in map["memberInfoList"]) {
        memList.add(map2ChatRoomMemberInfo(memMap));
    }
    chatRoomInfo.memberInfoList = memList;
    return chatRoomInfo;
  }

  ChatRoomMemberInfo map2ChatRoomMemberInfo(Map map) {
    ChatRoomMemberInfo chatRoomMemberInfo = new ChatRoomMemberInfo();
    chatRoomMemberInfo.userId = map["userId"];
    chatRoomMemberInfo.joinTime = map["joinTime"];
    return chatRoomMemberInfo;
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
    Map readReceiptMap = map["readReceiptInfo"];
    if (readReceiptMap != null) {
      ReadReceiptInfo readReceiptInfo = ReadReceiptInfo();
      readReceiptInfo.isReceiptRequestMessage = readReceiptMap["isReceiptRequestMessage"];
      readReceiptInfo.hasRespond = readReceiptMap["hasRespond"];
      readReceiptInfo.userIdList = readReceiptMap["userIdList"];
      message.readReceiptInfo = readReceiptInfo;
    }
    String contenStr = map["content"];
    MessageContent content = string2MessageContent(contenStr,message.objectName);
    if(contenStr == null || contenStr == "") {
      print(message.objectName+":该消息内容为空，可能该消息没有在原生 SDK 中注册");
      return message;
    }
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
    con.isTop = map["isTop"];
    con.objectName = map["objectName"];
    con.senderUserId = map["senderUserId"];
    con.latestMessageId = map["latestMessageId"];
    con.mentionedCount = map["mentionedCount"];
    con.draft = map["draft"];

    String contenStr = map["content"];
    MessageContent content = string2MessageContent(contenStr,con.objectName);
    if(content != null) {
      con.latestMessageContent = content;
    }else {
      if(contenStr == null || contenStr.length <=0) {
        print("该会话没有消息 type:"+con.conversationType.toString() +" targetId:"+con.targetId);
      }else {
        print(con.objectName+":该消息不能被解析!消息内容被保存在 Conversation.originContentMap 中");
        Map map = json.decode(contenStr.toString());
        con.originContentMap = map;
      }
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
    }else if(objectName == VoiceMessage.objectName) {
      content = new VoiceMessage();
      content.decode(contentS);
    }else if(objectName == SightMessage.objectName) {
      content = new SightMessage();
      content.decode(contentS);
    }else if(objectName == RecallNotificationMessage.objectName){
      content = new RecallNotificationMessage();
      content.decode(contentS);
    }else if(objectName == ChatroomKVNotificationMessage.objectName){
      content = new ChatroomKVNotificationMessage();
      content.decode(contentS);
    }else if(objectName == FileMessage.objectName){
      content = new FileMessage();
    }else if(objectName == RichContentMessage.objectName){
      content = new RichContentMessage();
      content.decode(contentS);
    }
    return content;
  }


  Map messageContent2Map(MessageContent content) {
    Map map = new Map();
    return map;
  }

  Map message2Map(Message message) {
    Map map = new Map();
    map["conversationType"] = message.conversationType;
    map["targetId"] = message.targetId;
    map["messageId"] = message.messageId;
    map["messageDirection"] = message.messageDirection;
    map["senderUserId"] = message.senderUserId;
    map["receivedStatus"] =  message.receivedStatus;
    map["sentStatus"] = message.sentStatus;
    map["sentTime"] =  message.sentTime;
    map["objectName"] =  message.objectName;
    map["messageUId"] = message.messageUId;
    if(message.content!=null){
      map["content"] = message.content.encode();
    }
    return map;
  }

  TypingStatus string2TypingStatus(String statusJsonStr) {
    if(TypeUtil.isEmptyString(statusJsonStr)) {
      return null;
    }
    Map map = json.decode(statusJsonStr);
    return map2TypingStatus(map);
  }

  TypingStatus map2TypingStatus(Map map) {
    TypingStatus status = new TypingStatus();
    status.userId = map["userId"];
    status.typingContentType = map["typingContentType"];
    status.sentTime = map["sentTime"];
    return status;
  }

  SearchConversationResult string2SearchConversationResult(String resultStr){
    if(TypeUtil.isEmptyString(resultStr)) {
      return null;
    }
    Map map = json.decode(resultStr);
    return map2SearchConversationResult(map);
  }

  SearchConversationResult map2SearchConversationResult(Map map) {
    SearchConversationResult result = new SearchConversationResult();
    result.mConversation = string2Conversation(map["mConversation"]) ;
    result.mMatchCount = map["mMatchCount"];
    return result;
  }
}