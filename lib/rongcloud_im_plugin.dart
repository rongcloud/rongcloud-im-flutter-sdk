import 'dart:async';

import 'package:flutter/services.dart';
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

  static void updateCurrentUserInfo(String userId,String name,String portraitUrl) {
    refreshUserInfo(userId, name, portraitUrl);
  }

  static void sendMessage(int conversationType,String targetId,MessageContent content) {
    Map cMap = content.encode();
    String objName = content.getObjectName();
    Map map = {'conversationType':conversationType,'targetId':targetId,"content":cMap,"objectName":objName};
    _channel.invokeMethod(RCMethodKey.SendMessage,map);
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