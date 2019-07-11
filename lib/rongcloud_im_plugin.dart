import 'dart:async';

import 'package:flutter/services.dart';
import 'package:rongcloud_im_plugin/conversation.dart';
import 'package:rongcloud_im_plugin/message.dart';
import 'message_factory.dart';
import 'rc_common_define.dart';
import 'message_content.dart';

class RongcloudImPlugin {
  static final MethodChannel _channel = const MethodChannel('rongcloud_im_plugin');

  static void init(String appkey) {
    _channel.invokeMethod(RCMethodKey.Init,appkey);
  }
  static void config(Map conf) {
    _channel.invokeMethod(RCMethodKey.Config,conf);
  }
  static Future<int> connect(String token) async {
    final int code = await _channel.invokeMethod(RCMethodKey.Connect,token);
    return code;
  }

  static void disconnect(bool needPush) {
    _channel.invokeMethod(RCMethodKey.Disconnect,needPush);
  }

  /// 此方法只针对iOS生效
  static void updateCurrentUserInfo(String userId,String name,String portraitUrl) {
    Map map = {"userId":userId,"name":name,"portraitUrl":portraitUrl};
    _channel.invokeMethod(RCMethodKey.SetCurrentUserInfo,map);
  }

  static Future<Message> sendMessage(int conversationType,String targetId,MessageContent content) async{
    String jsonStr = content.encode();
    String objName = content.getObjectName();
    Map map = {'conversationType':conversationType,'targetId':targetId,"content":jsonStr,"objectName":objName};
    Map resultMap = await _channel.invokeMethod(RCMethodKey.SendMessage,map);
    if(resultMap == null) {
      return null;
    }
    String messageString = resultMap["message"];
    Message msg = MessageFactory.instance.string2Message(messageString);
    return msg;
  }

  static Future<List> getHistoryMessage(int conversationType,String targetId,int messageId,int count) async {
    Map map = {'conversationType':conversationType,'targetId':targetId,"messageId":messageId,"count":count};
    List list = await _channel.invokeMethod(RCMethodKey.GetHistoryMessage,map);
    if(list == null) {
      return null;
    }
    List msgList = new List();
    for(String msgStr in list) {
        Message msg = MessageFactory.instance.string2Message(msgStr);
        msgList.add(msg);
    }
    return msgList;
  }

  static Future<List> getConversationList() async {
    List list = await _channel.invokeMethod(RCMethodKey.GetConversationList);
    if(list == null) {
      return null;
    }
    List conList = new List();
    for(String conStr in list) {
      Conversation con = MessageFactory.instance.string2Conversation(conStr);
      conList.add(con);
    }
    return conList;
  }

  static Future<bool> clearMessagesUnreadStatus(int conversationType,String targetId) async {
    Map map = {'conversationType':conversationType,'targetId':targetId};
    bool rc = await _channel.invokeMethod(RCMethodKey.ClearMessagesUnreadStatus,map);
    return rc;
  }

  static void joinChatRoom(String targetId,int messageCount) {
    Map map = {"targetId":targetId,"messageCount":messageCount};
    _channel.invokeMethod(RCMethodKey.JoinChatRoom,map);
  }

  static void quitChatRoom(String targetId) {
    Map map = {"targetId":targetId};
    _channel.invokeMethod(RCMethodKey.QuitChatRoom,map);
  }

  // memeberCount 最大 20
  static Future getChatRoomInfo(String targetId,int memeberCount,int memberOrder) async {
    if(memeberCount > 20) {
      memeberCount = 20;
    }
    Map map = {"targetId":targetId,"memeberCount":memeberCount,"memberOrder":memberOrder};
    Map resultMap = await _channel.invokeMethod(RCMethodKey.GetChatRoomInfo,map);
    return MessageFactory.instance.map2ChatRoomInfo(resultMap);
  }

  static void refreshUserInfo(String userId,String name,String portraitUrl) {
    Map map = {'userId':userId,'name':name,'portraitUrl':portraitUrl};
    _channel.invokeMethod(RCMethodKey.RefreshUserInfo,map);
  }

  static void setServerInfo(String naviServer,String fileServer) {
    Map map = {"naviServer":naviServer,"fileServer":fileServer};
    _channel.invokeMethod(RCMethodKey.SetServerInfo,map);
  }

  static void setRCNativeMethodCallHandler(Future<dynamic> handler(MethodCall call)) {
    _channel.setMethodCallHandler(handler);
//    _channel.setMethodCallHandler((MethodCall call) {
//      switch (call.method) {
//        case RCMethodCallBackKey.SendMessage:
//          if(onMessageSend != null) {
//            Map arg = call.arguments;
//            Message msg = null;
//            int code = -1;
//            onMessageSend(msg,code);
//          }
//          break;
//
//
//      }
//    });
  }

  /// 返回一个[Map] {"code":...,"messages":...,"isRemaining":...}
  /// code:是否获取成功
  /// messages:获取到的历史消息数组,
  /// isRemaining:是否还有剩余消息 YES 表示还有剩余，NO 表示无剩余
  ///
  /// [conversationType]  会话类型
  ///
  /// [targetId]          聊天室的会话ID
  ///
  /// [recordTime]        起始的消息发送时间戳，毫秒
  ///
  /// [count]             需要获取的消息数量， 0 < count <= 200
  ///
  /// 此方法从服务器端获取之前的历史消息，但是必须先开通历史消息云存储功能。
  /// 例如，本地会话中有10条消息，您想拉取更多保存在服务器的消息的话，recordTime应传入最早的消息的发送时间戳，count传入1~20之间的数值。
  static void getRemoteHistoryMessages(int conversationType, String targetId, int recordTime, int count) {

    Map map = {'conversationType':conversationType, 'targetId':targetId, 'recordTime':recordTime, 'count':count};
    _channel.invokeMethod(RCMethodCallBackKey.GetRemoteHistoryMessages,map);
  }

  /// 插入一条收到的消息
  ///
  /// [conversationType]
  static void insertIncomingMessage(int conversationType, String targetId, String senderUserId, int receivedStatus, MessageContent content, int sendTime, Function (Message msg,int code) finished) async {
    String jsonStr = content.encode();
    String objName = content.getObjectName();
    Map map = {"conversationType":conversationType, "targetId":targetId, "senderUserId":senderUserId, "rececivedStatus":receivedStatus, "objectName":objName, "content":jsonStr, "sendTime":sendTime};
    Map msgMap = await _channel.invokeMethod(RCMethodKey.InsertIncomingMessage,map);
    String msgString = msgMap["message"];
    int code = msgMap["code"];
    Message message = MessageFactory.instance.string2Message(msgString);
    if (finished != null) {
      finished(message,code);
    }
  }

  static void insertOutgoingMessage(int conversationType, String targetId, int sendStatus, MessageContent content, int sendTime, Function (Message msg,int code) finished) async {
    String jsonStr = content.encode();
    String objName = content.getObjectName();
    Map map = {"conversationType":conversationType, "targetId":targetId, "sendStatus":sendStatus, "objectName":objName, "content":jsonStr, "sendTime":sendTime};
    Map msgMap = await _channel.invokeMethod(RCMethodKey.InsertOutgoingMessage,map);
    String msgString = msgMap["message"];
    Message message = MessageFactory.instance.string2Message(msgString);
    int code = msgMap["code"];
    if (finished != null) {
      finished(message,code);
    }
  }

//  static void Function (Message msg, int code) onMessageSend;

  static void getTotalUnreadCount(Function (int count,int code) finished) async {
    Map map = await _channel.invokeMethod(RCMethodKey.GetTotalUnreadCount);
    if(finished != null) {
      finished(map["count"],map["code"]);
    }
  }

  static void getUnreadCount(int conversationType, String targetId, Function (int count, int code) finished) async {
    Map map = {"conversationType":conversationType, "targetId":targetId};
    Map unreadMap = await _channel.invokeMethod(RCMethodKey.GetUnreadCountTargetId,map);
    if(finished != null) {
      finished(unreadMap["count"],unreadMap["code"]);
    }
  }

  static void getUnreadCountConversationTypeList(List conversationTypeList, bool isContain, Function (int count, int code) finished) async {
    Map map = {"conversationTypeList":conversationTypeList,"isContain":isContain};
    Map unreadMap = await _channel.invokeMethod(RCMethodKey.GetUnreadCountConversationTypeList,map);
    if (finished != null) {
      finished(unreadMap["count"],unreadMap["code"]);
    }
  }

}