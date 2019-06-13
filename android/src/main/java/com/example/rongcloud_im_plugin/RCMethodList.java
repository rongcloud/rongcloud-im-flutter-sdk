package com.example.rongcloud_im_plugin;

public class RCMethodList {
    //method list
    static String MethodKeyInit = "init";
    static String MethodKeyConfig = "config";
    static String MethodKeyConnect = "connect";
    static String MethodKeyPushToConversationList = "pushToConversationList";
    static String MethodKeyPushToConversation = "pushToConversation";
    static String MethodKeyRefrechUserInfo = "refreshUserInfo";
    static String MethodKeySendMessage = "sendMessage";

    //callback method list，以下方法是有 native 代码触发，有 flutter 处理
    static String MethodCallBackKeyRefrechUserInfo = "refreshUserInfoCallBack";
}
