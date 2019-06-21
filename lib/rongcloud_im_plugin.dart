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

  static void updateCurrentUserInfo(String userId,String name,String portraitUrl) {
    refreshUserInfo(userId, name, portraitUrl);
  }

  static Future<Map> sendMessage(int conversationType,String targetId,MessageContent content) async{
    String jsonStr = content.encode();
    String objName = content.getObjectName();
    Map map = {'conversationType':conversationType,'targetId':targetId,"content":jsonStr,"objectName":objName};
    return _channel.invokeMethod(RCMethodKey.SendMessage,map);
  }

  static Future<List> getHistoryMessage(int conversationType,String targetId,int messageId,int count) async {
    Map map = {'conversationType':conversationType,'targetId':targetId,"messageId":messageId,"count":count};
    List list = await _channel.invokeMethod(RCMethodKey.GetHistoryMessage,map);
    List msgList = new List();
    for(String msgStr in list) {
        Message msg = MessageFactory.instance.string2Message(msgStr);
        msgList.add(msg);
    }
    return msgList;
  }

  static Future<List> getConversationList() async {
    List list = await _channel.invokeMethod(RCMethodKey.GetConversationList);
    List conList = new List();
    for(String conStr in list) {
      Conversation con = MessageFactory.instance.string2Conversation(conStr);
      conList.add(con);
    }
    return conList;
  }

  static void joinChatRoom(String targetId,int messageCount) {
    Map map = {"targetId":targetId,"messageCount":messageCount};
    _channel.invokeMethod(RCMethodKey.JoinChatRoom,map);
  }

  static void quitChatRoom(String targetId) {
    Map map = {"targetId":targetId};
    _channel.invokeMethod(RCMethodKey.QuitChatRoom,map);
  }

  static void pushToConversationList(List conTypes) {
    _channel.invokeMethod(RCMethodKey.PushToConversationList,conTypes);
  }

  static void pushToConversation(int conversationType,String targetId) {
    Map map = {'conversationType':conversationType,'targetId':targetId};
    _channel.invokeMethod(RCMethodKey.PushToConversation,map);
  }

  static void refreshUserInfo(String userId,String name,String portraitUrl) {
    Map map = {'userId':userId,'name':name,'portraitUrl':portraitUrl};
    _channel.invokeMethod(RCMethodKey.RefrechUserInfo,map);
  }

  static void setRCNativeMethodCallHandler(Future<dynamic> handler(MethodCall call)) {
    _channel.setMethodCallHandler(handler);
  }

}