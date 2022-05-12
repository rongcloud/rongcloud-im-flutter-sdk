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
    static String MethodKeyJoinExistChatRoom = "joinExistChatRoom";
    static String MethodKeyQuitChatRoom = "quitChatRoom";
    static String MethodKeyGetHistoryMessage ="getHistoryMessage";
    static String MethodKeyGetHistoryMessages ="getHistoryMessages";
    static String MethodKeyGetMessage ="getMessage";
    static String MethodKeyGetMessages = "GetMessages";
    static String MethodKeyGetConversationList ="getConversationList";
    static String MethodKeyGetConversationListByPage ="getConversationListByPage";
    static String MethodKeyGetConversation ="getConversation";
    static String MethodKeyGetChatRoomInfo ="getChatRoomInfo";
    static String MethodKeyClearMessagesUnreadStatus ="clearMessagesUnreadStatus";
    static String MethodKeySetServerInfo ="setServerInfo";
    static String MethodKeySetCurrentUserInfo = "setCurrentUserInfo";
    static String MethodKeyInsertIncomingMessage = "insertIncomingMessage";
    static String MethodKeyInsertOutgoingMessage = "insertOutgoingMessage";
    static String MethodKeyBatchInsertMessage = "BatchInsertMessage";
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
    static String MethodKeySetAndroidPushConfig = "setAndroidPushConfig";
    static String MethodKeySetStatisticServer = "setStatisticServer";
    static String MethodKeyCancelSendMediaMessage = "cancelSendMediaMessage";

    // 消息扩展
    static String MethodKeyUpdateMessageExpansion = "updateMessageExpansion";
    static String MethodKeyRemoveMessageExpansionForKey = "removeMessageExpansionForKey";

    static String RCUltraGroup = "RCUltraGroup";
    static String RCUltraGroupSyncReadStatus = "RCUltraGroup-SyncReadStatus";
    static String RCUltraGroupGetConversationListForAllChannel = "RCUltraGroup-GetConversationListForAllChannel";
    static String RCUltraGroupGetUnreadMentionedCount = "RCUltraGroup-GetUnreadMentionedCount";
    static String RCUltraGroupSendTypingStatus = "RCUltraGroup-SendTypingStatus";
    static String RCUltraGroupDeleteMessagesForAllChannel = "RCUltraGroup-DeleteMessagesForAllChannel";
    static String RCUltraGroupDeleteMessages = "RCUltraGroup-DeleteMessages";
    static String RCUltraGroupDeleteRemoteMessages = "RCUltraGroup-DeleteRemoteMessages";
    static String RCUltraGroupModifyMessage = "RCUltraGroup-ModifyMessage";
    static String RCUltraGroupUpdateMessageExpansion = "RCUltraGroup-UpdateMessageExpansion";
    static String RCUltraGroupRemoveMessageExpansion = "RCUltraGroup-RemoveMessageExpansion";
    static String RCUltraGroupRecallMessage = "RCUltraGroup-RecallMessage";
    static String RCUltraGroupGetBatchRemoteMessages = "RCUltraGroup-GetBatchRemoteMessages";

    static String RCUltraGroupOnMessageRecalled = "RCUltraGroup-onMessageRecalled";
    static String RCUltraGroupOnMessageExpansionUpdated = "RCUltraGroup-onMessageExpansionUpdated";
    static String RCUltraGroupOnReadTimeReceived = "RCUltraGroup-onReadTimeReceived";
    static String RCUltraGroupOnMessageModified = "RCUltraGroup-onMessageModified";
    static String RCUltraGroupOnTypingStatusChanged = "RCUltraGroup-onTypingStatusChanged";

    static String RCUltraGroupGetNotificationQuietHoursLevel = "RCUltraGroup-GetNotificationQuietHoursLevel";
    static String RCUltraGroupSetConversationChannelNotificationLevel = "RCUltraGroup-SetConversationChannelNotificationLevel";
    static String RCUltraGroupSetNotificationQuietHoursLevel = "RCUltraGroup-SetNotificationQuietHoursLevel";
    static String RCUltraGroupGetConversationChannelNotificationLevel = "RCUltraGroup-GetConversationChannelNotificationLevel";
    static String RCUltraGroupSetConversationTypeNotificationLevel = "RCUltraGroup-SetConversationTypeNotificationLevel";
    static String RCUltraGroupGetConversationTypeNotificationLevel = "RCUltraGroup-GetConversationTypeNotificationLevel";
    static String RCUltraGroupSetConversationDefaultNotificationLevel = "RCUltraGroup-SetConversationDefaultNotificationLevel";
    static String RCUltraGroupGetConversationDefaultNotificationLevel = "RCUltraGroup-GetConversationDefaultNotificationLevel";
    static String RCUltraGroupSetConversationChannelDefaultNotificationLevel = "RCUltraGroup-SetConversationChannelDefaultNotificationLevel";
    static String RCUltraGroupGetConversationChannelDefaultNotificationLevel = "RCUltraGroup-GetConversationChannelDefaultNotificationLevel";
    static String RCUltraGroupGetUltraGroupUnreadCount = "RCUltraGroup-GetUltraGroupUnreadCount";
    static String RCUltraGroupGetUltraGroupAllUnreadCount = "RCUltraGroup-GetUltraGroupAllUnreadCount";
    static String RCUltraGroupGetUltraGroupAllUnreadMentionedCount = "RCUltraGroup-GetUltraGroupAllUnreadMentionedCount";
    static String RCUltraGroupSetConversationNotificationLevel = "RCUltraGroup-SetConversationNotificationLevel";
    static String RCUltraGroupGetConversationNotificationLevel = "RCUltraGroup-GetConversationNotificationLevel";

    static String RCUltraGroupConversationListDidSync = "RCUltraGroup-ConversationListDidSync";

    //会话标签
    static String MethodKeyAddTag = "addTag";
    static String MethodKeyRemoveTag = "removeTag";
    static String MethodKeyUpdateTag = "updateTag";
    static String MethodKeyGetTags = "getTags";
    static String MethodKeyGetConversationTopStatusInTag = "getConversationTopStatusInTag";
    static String MethodKeySetConversationToTopInTag = "setConversationToTopInTag";
    static String MethodKeyGetUnreadCountByTag = "getUnreadCountByTag";
    static String MethodKeyGetConversationsFromTagByPage = "getConversationsFromTagByPage";
    static String MethodKeyGetTagsFromConversation = "getTagsFromConversation";
    static String MethodKeyRemoveTagsFromConversation = "removeTagsFromConversation";
    static String MethodKeyRemoveConversationsFromTag = "removeConversationsFromTag";
    static String MethodKeyAddConversationsToTag = "addConversationsToTag";



    //聊天室存储
    static String MethodKeySetChatRoomEntry = "SetChatRoomEntry";
    static String MethodKeyForceSetChatRoomEntry = "ForceSetChatRoomEntry";
    static String MethodKeyGetChatRoomEntry = "GetChatRoomEntry";
    static String MethodKeyGetAllChatRoomEntries = "GetAllChatRoomEntries";
    static String MethodKeyRemoveChatRoomEntry = "RemoveChatRoomEntry";
    static String MethodKeyForceRemoveChatRoomEntry = "ForceRemoveChatRoomEntry";
    static String MethodKeySetChatRoomEntries = "SetChatRoomEntries";
    static String MethodKeyRemoveChatRoomEntries = "RemoveChatRoomEntries";



    //callback method list，以下方法是有 native 代码触发，有 flutter 处理
    static String MethodCallBackKeySendMessage = "sendMessageCallBack";
    static String MethodCallBackKeyRefreshUserInfo = "refreshUserInfoCallBack";
    static String MethodCallBackKeyReceiveMessage = "receiveMessageCallBack";
    static String MethodCallBackKeyJoinChatRoom = "joinChatRoomCallBack";
    static String MethodCallBackKeyQuitChatRoom = "quitChatRoomCallBack";
    static String MethodCallBackKeyChatRoomReset = "onChatRoomResetCallBack";
    static String MethodCallBackKeyChatRoomDestroyed = "onChatRoomDestroyedCallBack";
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
    static String MethodCallBackDatabaseOpened = "DatabaseOpenedCallBack";
    static String MethodCallBackTagChanged ="onTagChanged";
    static String MethodCallBackConversationTagChanged = "ConversationTagChangedCallBack";
    static String MethodCallBackMessageBlocked = "onMessageBlocked";

}
