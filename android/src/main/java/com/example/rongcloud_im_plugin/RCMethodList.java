package com.example.rongcloud_im_plugin;

public class RCMethodList {
    //method list
    static String MethodKeyInit = "init";
    static String MethodKeyConfig = "config";
    static String MethodKeyConnect = "connect";
    static String MethodKeyDisconnect = "disconnect";
    static String MethodKeySendMessage = "sendMessage";
    static String MethodKeyRefrechUserInfo = "refreshUserInfo";
    static String MethodKeyJoinChatRoom = "joinChatRoom";
    static String MethodKeyQuitChatRoom = "quitChatRoom";
    static String MethodKeyGetHistoryMessage ="getHistoryMessage";
    static String MethodKeyGetConversationList ="getConversationList";
    static String MethodKeyGetChatRoomInfo ="getChatRoomInfo";
    static String MethodKeyClearMessagesUnreadStatus ="clearMessagesUnreadStatus";
    static String MethodKeySetServerInfo ="setServerInfo";
    static String MethodKeySetCurrentUserInfo = "setCurrentUserInfo";
    static String MethodKeyInsertIncomingMessage = "insertIncomingMessage";
    static String MethodKeyInsertOutgoingMessage = "insertOutgoingMessage";
    static String MethodKeyGetTotalUnreadCount = "getTotalUnreadCount";
    static String MethodKeyGetUnreadCountTargetId = "getUnreadCountTargetId";
    static String MethodKeyGetUnreadCountConversationTypeList = "getUnreadCountConversationTypeList";
    static String MethodKeySetConversationNotificationStatus = "setConversationNotificationStatus";
    static String MethodKeyGetConversationNotificationStatus = "getConversationNotificationStatus";



    //callback method list，以下方法是有 native 代码触发，有 flutter 处理
    static String MethodCallBackKeySendMessage = "sendMessageCallBack";
    static String MethodCallBackKeyRefrechUserInfo = "refreshUserInfoCallBack";
    static String MethodCallBackKeyReceiveMessage = "receiveMessageCallBack";
    static String MethodCallBackKeyJoinChatRoom = "joinChatRoomCallBack";
    static String MethodCallBackKeyQuitChatRoom = "quitChatRoomCallBack";
    static String MethodCallBackKeyUploadMediaProgress = "uploadMediaProgressCallBack";
    static String MethodCallBackKeygetRemoteHistoryMessages = "getRemoteHistoryMessagesCallBack";
    static String MethodCallBackKeyConnectionStatusChange = "ConnectionStatusChangeCallBack";

}
