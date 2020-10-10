package io.rong.flutter.imlib;

public class RCMethodList {
    //method list
    static String MethodKeyInit = "init";
    static String MethodKeyConfig = "config";
    static String MethodKeyConnect = "connect";
    static String MethodKeyDisconnect = "disconnect";
    static String MethodKeySendMessage = "sendMessage";
    static String MethodKeyRefreshUserInfo = "refreshUserInfo";
    static String MethodKeyJoinChatRoom = "joinChatRoom";
    static String MethodKeyQuitChatRoom = "quitChatRoom";
    static String MethodKeyGetHistoryMessage ="getHistoryMessage";
    static String MethodKeyGetHistoryMessages ="getHistoryMessages";
    static String MethodKeyGetMessage ="getMessage";
    static String MethodKeyGetConversationList ="getConversationList";
    static String MethodKeyGetConversationListByPage ="getConversationListByPage";
    static String MethodKeyGetConversation ="getConversation";
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
    static String MethodKeyRemoveConversation = "RemoveConversation";
    static String MethodKeyGetBlockedConversationList = "getBlockedConversationList";
    static String MethodKeySetConversationToTop = "setConversationToTop";
    static String MethodKeyGetTopConversationList = "getTopConversationList";
    static String MethodKeyDeleteMessages = "DeleteMessages";
    static String MethodKeyDeleteMessageByIds = "DeleteMessageByIds";
    static String MethodKeyAddToBlackList = "AddToBlackList";
    static String MethodKeyRemoveFromBlackList = "RemoveFromBlackList";
    static String MethodKeyGetBlackListStatus = "GetBlackListStatus";
    static String MethodKeyGetBlackList = "GetBlackList";
    static String MethodKeySendReadReceiptMessage = "SendReadReceiptMessage";
    static String MethodKeySendReadReceiptRequest = "SendReadReceiptRequest";
    static String MethodKeySendReadReceiptResponse = "SendReadReceiptResponse";
    static String MethodKeyRecallMessage = "recallMessage";
    static String MethodKeyGetTextMessageDraft = "getTextMessageDraft";
    static String MethodKeySaveTextMessageDraft = "saveTextMessageDraft";
    static String MethodKeyClearHistoryMessages = "ClearHistoryMessages";
    static String MethodKeySyncConversationReadStatus = "syncConversationReadStatus";
    static String MethodKeySearchConversations = "searchConversations";
    static String MethodKeySearchMessages = "searchMessages";
    static String MethodKeySendTypingStatus = "sendTypingStatus";
    static String MethodKeyDownloadMediaMessage = "downloadMediaMessage";
    static String MethodKeySetNotificationQuietHours = "setNotificationQuietHours";
    static String MethodKeyRemoveNotificationQuietHours = "removeNotificationQuietHours";
    static String MethodKeyGetNotificationQuietHours = "getNotificationQuietHours";
    static String MethodKeyGetUnreadMentionedMessages = "getUnreadMentionedMessages";
    static String MethodKeySendDirectionalMessage = "sendDirectionalMessage";
    static String MethodKeySaveMediaToPublicDir = "saveMediaToPublicDir";
    static String MethodKeyForwardMessageByStep = "forwardMessageByStep";
    static String MethodKeyMessageBeginDestruct = "messageBeginDestruct";
    static String MethodKeyMessageStopDestruct = "messageStopDestruct";
    static String MethodKeyDeleteRemoteMessages = "deleteRemoteMessages";
    static String MethodKeyClearMessages = "clearMessages";
    static String MethodKeySetMessageExtra = "setMessageExtra";
    static String MethodKeySetMessageReceivedStatus = "setMessageReceivedStatus";
    static String MethodKeySetMessageSentStatus = "setMessageSentStatus";
    static String MethodKeyClearConversations = "clearConversations";
    static String MethodKeyGetDeltaTime = "getDeltaTime";
    static String MethodKeySetOfflineMessageDuration = "setOfflineMessageDuration";
    static String MethodKeyGetOfflineMessageDuration = "getOfflineMessageDuration";
    static String MethodKeySetReconnectKickEnable = "setReconnectKickEnable";
    static String MethodKeyGetConnectionStatus = "getConnectionStatus";
    static String MethodKeyCancelDownloadMediaMessage = "cancelDownloadMediaMessage";
    static String MethodKeyGetRemoteChatRoomHistoryMessages = "getRemoteChatRoomHistoryMessages";
    static String MethodKeyGetMessageByUId = "getMessageByUId";
    static String MethodKeyGetFirstUnreadMessage = "getFirstUnreadMessage";
    static String MethodKeySendIntactMessage = "sendIntactMessage";
    // 消息扩展
    static String MethodKeyUpdateMessageExpansion = "updateMessageExpansion";
    static String MethodKeyRemoveMessageExpansionForKey = "removeMessageExpansionForKey";




    //聊天室存储
    static String MethodKeySetChatRoomEntry = "SetChatRoomEntry";
    static String MethodKeyForceSetChatRoomEntry = "ForceSetChatRoomEntry";
    static String MethodKeyGetChatRoomEntry = "GetChatRoomEntry";
    static String MethodKeyGetAllChatRoomEntries = "GetAllChatRoomEntries";
    static String MethodKeyRemoveChatRoomEntry = "RemoveChatRoomEntry";
    static String MethodKeyForceRemoveChatRoomEntry = "ForceRemoveChatRoomEntry";



    //callback method list，以下方法是有 native 代码触发，有 flutter 处理
    static String MethodCallBackKeySendMessage = "sendMessageCallBack";
    static String MethodCallBackKeyRefreshUserInfo = "refreshUserInfoCallBack";
    static String MethodCallBackKeyReceiveMessage = "receiveMessageCallBack";
    static String MethodCallBackKeyJoinChatRoom = "joinChatRoomCallBack";
    static String MethodCallBackKeyQuitChatRoom = "quitChatRoomCallBack";
    static String MethodCallBackKeyUploadMediaProgress = "uploadMediaProgressCallBack";
    static String MethodCallBackKeygetRemoteHistoryMessages = "getRemoteHistoryMessagesCallBack";
    static String MethodCallBackKeyConnectionStatusChange = "ConnectionStatusChangeCallBack";
    static String MethodCallBackKeySendDataToFlutter = "SendDataToFlutterCallBack";
    static String MethodCallBackKeyReceiveReadReceipt = "ReceiveReadReceiptCallBack";
    static String MethodCallBackKeyReceiptRequest = "ReceiptRequestCallBack";
    static String MethodCallBackKeyReceiptResponse = "ReceiptResponseCallBack";
    static String MethodCallBackKeyTypingStatus ="TypingStatusChangedCallBack";
    static String MethodCallBackKeyDownloadMediaMessage = "DownloadMediaMessageCallBack";
    static String MethodCallBackRecallMessage = "RecallMessageCallBack";
    static String MethodCallBackDestructMessage = "DestructMessageCallBack";
    static String MethodCallBackChatRoomKVDidSync = "chatRoomKVDidSyncCallBack";
    static String MethodCallBackChatRoomKVDidUpdate = "chatRoomKVDidUpdateCallBack";
    static String MethodCallBackChatRoomKVDidRemove = "chatRoomKVDidRemoveCallBack";
    static String MethodCallBackMessageExpansionDidUpdate = "MessageExpansionDidUpdateCallBack";
    static String MethodCallBackMessageExpansionDidRemove = "MessageExpansionDidRemoveCallBack";

}
