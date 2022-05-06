//
//  RCIMFlutterDefine.h
//  RongCloud
//
//  Created by Sin on 2019/6/5.
//
static NSString *RCMethodKeyInit = @"init";
static NSString *RCMethodKeyConnect = @"connect";
static NSString *RCMethodKeyDisconnect = @"disconnect";
static NSString *RCMethodKeyConfig = @"config";
static NSString *RCMethodKeySendMessage = @"sendMessage";
static NSString *RCMethodKeyRefreshUserInfo = @"refreshUserInfo";
static NSString *RCMethodKeyJoinChatRoom = @"joinChatRoom";
static NSString *RCMethodKeyJoinExistChatRoom = @"joinExistChatRoom";
static NSString *RCMethodKeyQuitChatRoom = @"quitChatRoom";
static NSString *RCMethodKeyGetHistoryMessage = @"getHistoryMessage";
static NSString *RCMethodKeyGetHistoryMessages = @"getHistoryMessages";
static NSString *RCMethodKeyGetMessages = @"GetMessages";
static NSString *RCMethodKeyGetMessage = @"GetMessage";
static NSString *RCMethodKeyGetConversationList = @"getConversationList";
static NSString *RCMethodKeyGetConversationListByPage = @"getConversationListByPage";
static NSString *RCMethodKeyGetConversation = @"GetConversation";
static NSString *RCMethodKeyGetChatRoomInfo = @"getChatRoomInfo";
static NSString *RCMethodKeyClearMessagesUnreadStatus = @"clearMessagesUnreadStatus";
static NSString *RCMethodKeySetServerInfo = @"setServerInfo";
static NSString *RCMethodKeySetCurrentUserInfo = @"setCurrentUserInfo";
static NSString *RCMethodKeyInsertIncomingMessage = @"insertIncomingMessage";
static NSString *RCMethodKeyInsertOutgoingMessage = @"insertOutgoingMessage";
static NSString *RCMethodKeyBatchInsertMessage = @"BatchInsertMessage";
static NSString *RCMethodKeyGetTotalUnreadCount = @"getTotalUnreadCount";
static NSString *RCMethodKeyGetUnreadCountTargetId = @"getUnreadCountTargetId";
static NSString *RCMethodKeyGetUnreadCountConversationTypeList = @"getUnreadCountConversationTypeList";
static NSString *RCMethodKeySetConversationNotificationStatus = @"setConversationNotificationStatus";
static NSString *RCMethodKeyGetConversationNotificationStatus = @"getConversationNotificationStatus";
static NSString *RCMethodKeyRemoveConversation = @"RemoveConversation";
static NSString *RCMethodKeyGetBlockedConversationList = @"getBlockedConversationList";
static NSString *RCMethodKeySetConversationToTop = @"setConversationToTop";
static NSString *RCMethodKeyGetTopConversationList = @"getTopConversationList";
static NSString *RCMethodKeyDeleteMessages = @"DeleteMessages";
static NSString *RCMethodKeyDeleteMessageByIds = @"DeleteMessageByIds";
static NSString *RCMethodKeyAddToBlackList = @"AddToBlackList";
static NSString *RCMethodKeyRemoveFromBlackList = @"RemoveFromBlackList";
static NSString *RCMethodKeyGetBlackListStatus = @"GetBlackListStatus";
static NSString *RCMethodKeyGetBlackList = @"GetBlackList";
static NSString *RCMethodKeySendReadReceiptMessage = @"SendReadReceiptMessage";
static NSString *RCMethodKeySendReadReceiptRequest = @"SendReadReceiptRequest";
static NSString *RCMethodKeySendReadReceiptResponse = @"SendReadReceiptResponse";
static NSString *RCMethodKeyClearHistoryMessages = @"ClearHistoryMessages";
static NSString *RCMethodKeyRecallMessage = @"recallMessage";
static NSString *RCMethodKeySyncConversationReadStatus = @"syncConversationReadStatus";
static NSString *RCMethodKeyGetTextMessageDraft = @"getTextMessageDraft";
static NSString *RCMethodKeySaveTextMessageDraft = @"saveTextMessageDraft";
static NSString *RCMethodKeySearchConversations = @"searchConversations";
static NSString *RCMethodKeySearchMessages = @"searchMessages";
static NSString *RCMethodKeySendTypingStatus = @"sendTypingStatus";
static NSString *RCMethodKeyDownloadMediaMessage = @"downloadMediaMessage";
static NSString *RCMethodKeySetNotificationQuietHours = @"setNotificationQuietHours";
static NSString *RCMethodKeyRemoveNotificationQuietHours = @"removeNotificationQuietHours";
static NSString *RCMethodKeyGetNotificationQuietHours = @"getNotificationQuietHours";
static NSString *RCMethodKeyGetUnreadMentionedMessages = @"getUnreadMentionedMessages";
static NSString *RCMethodKeySendDirectionalMessage = @"sendDirectionalMessage";
static NSString *RCMethodKeyMessageBeginDestruct = @"messageBeginDestruct";
static NSString *RCMethodKeyMessageStopDestruct = @"messageStopDestruct";
static NSString *RCMethodKeySetReconnectKickEnable = @"setReconnectKickEnable";
static NSString *RCMethodKeyGetConnectionStatus = @"getConnectionStatus";
static NSString *RCMethodKeyCancelDownloadMediaMessage = @"cancelDownloadMediaMessage";
static NSString *RCMethodKeyGetRemoteChatRoomHistoryMessages = @"getRemoteChatRoomHistoryMessages";
static NSString *RCMethodKeyGetMessageByUId = @"getMessageByUId";
static NSString *RCMethodKeyDeleteRemoteMessages = @"deleteRemoteMessages";
static NSString *RCMethodKeyClearMessages = @"clearMessages";
static NSString *RCMethodKeySetMessageExtra = @"setMessageExtra";
static NSString *RCMethodKeySetMessageReceivedStatus = @"setMessageReceivedStatus";
static NSString *RCMethodKeySetMessageSentStatus = @"setMessageSentStatus";
static NSString *RCMethodKeyClearConversations = @"clearConversations";
static NSString *RCMethodKeyGetDeltaTime = @"getDeltaTime";
static NSString *RCMethodKeySetOfflineMessageDuration = @"setOfflineMessageDuration";
static NSString *RCMethodKeyGetOfflineMessageDuration = @"getOfflineMessageDuration";
static NSString *RCMethodKeyGetFirstUnreadMessage = @"getFirstUnreadMessage";
static NSString *RCMethodKeySendIntactMessage = @"sendIntactMessage";
static NSString *RCMethodKeyUpdateMessageExpansion = @"updateMessageExpansion";
static NSString *RCMethodKeyRemoveMessageExpansionForKey = @"removeMessageExpansionForKey";
static NSString *RCMethodKeyImageCompressConfig = @"imageCompressConfig";
static NSString *RCMethodKeyTypingUpdateSeconds = @"typingUpdateSeconds";
static NSString *RCMethodKeyAddTag = @"addTag";
static NSString *RCMethodKeyRemoveTag = @"removeTag";
static NSString *RCMethodKeyUpdateTag = @"updateTag";
static NSString *RCMethodKeyGetTags = @"getTags";
static NSString *RCMethodKeyAddConversationsToTag = @"addConversationsToTag";
static NSString *RCMethodKeyRemoveConversationsFromTag = @"removeConversationsFromTag";
static NSString *RCMethodKeyRemoveTagsFromConversation = @"removeTagsFromConversation";
static NSString *RCMethodKeyGetTagsFromConversation = @"getTagsFromConversation";
static NSString *RCMethodKeyGetConversationsFromTagByPage = @"getConversationsFromTagByPage";
static NSString *RCMethodKeyGetUnreadCountByTag = @"getUnreadCountByTag";
static NSString *RCMethodKeySetConversationToTopInTag = @"setConversationToTopInTag";
static NSString *RCMethodKeyGetConversationTopStatusInTag = @"getConversationTopStatusInTag";
static NSString *RCMethodKeySetAndroidPushConfig = @"setAndroidPushConfig";
static NSString *RCMethodKeySetStatisticServer = @"setStatisticServer";

// 聊天室状态存储
static NSString *RCMethodKeySetChatRoomEntry = @"SetChatRoomEntry";
static NSString *RCMethodKeyForceSetChatRoomEntry = @"ForceSetChatRoomEntry";
static NSString *RCMethodKeyGetChatRoomEntry = @"GetChatRoomEntry";
static NSString *RCMethodKeyGetAllChatRoomEntries = @"GetAllChatRoomEntries";
static NSString *RCMethodKeyRemoveChatRoomEntry = @"RemoveChatRoomEntry";
static NSString *RCMethodKeyForceRemoveChatRoomEntry = @"ForceRemoveChatRoomEntry";
static NSString *RCMethodKeySetChatRoomEntries = @"SetChatRoomEntries";
static NSString *RCMethodKeyRemoveChatRoomEntries = @"RemoveChatRoomEntries";

// 超级群相关内容
static NSString *RCUltraGroup = @"RCUltraGroup";

static NSString *RCUltraGroupSyncReadStatus = @"RCUltraGroup-SyncReadStatus";
static NSString *RCUltraGroupOnReadTimeReceived = @"RCUltraGroup-onReadTimeReceived";

static NSString *RCUltraGroupGetConversationListForAllChannel = @"RCUltraGroup-GetConversationListForAllChannel";
static NSString *RCUltraGroupGetUnreadMentionedCount = @"RCUltraGroup-GetUnreadMentionedCount";

static NSString *RCUltraGroupSendTypingStatus = @"RCUltraGroup-SendTypingStatus";
static NSString *RCUltraGroupOnTypingStatusChanged = @"RCUltraGroup-onTypingStatusChanged";

static NSString *RCUltraGroupDeleteMessagesForAllChannel = @"RCUltraGroup-DeleteMessagesForAllChannel";
static NSString *RCUltraGroupDeleteMessages = @"RCUltraGroup-DeleteMessages";
static NSString *RCUltraGroupDeleteRemoteMessages = @"RCUltraGroup-DeleteRemoteMessages";
static NSString *RCUltraGroupGetBatchRemoteMessages = @"RCUltraGroup-GetBatchRemoteMessages";

static NSString *RCUltraGroupOnMessageModified = @"RCUltraGroup-onMessageModified";
static NSString *RCUltraGroupModifyMessage = @"RCUltraGroup-ModifyMessage";

static NSString *RCUltraGroupUpdateMessageExpansion = @"RCUltraGroup-UpdateMessageExpansion";
static NSString *RCUltraGroupOnMessageExpansionUpdated = @"RCUltraGroup-onMessageExpansionUpdated";
static NSString *RCUltraGroupRemoveMessageExpansion = @"RCUltraGroup-RemoveMessageExpansion";

static NSString *RCUltraGroupRecallMessage = @"RCUltraGroup-RecallMessage";
static NSString *RCUltraGroupOnMessageRecalled = @"RCUltraGroup-onMessageRecalled";

static NSString *RCUltraGroupSetNotificationQuietHoursLevel = @"RCUltraGroup-SetNotificationQuietHoursLevel";
static NSString *RCUltraGroupGetNotificationQuietHoursLevel = @"RCUltraGroup-GetNotificationQuietHoursLevel";
static NSString *RCUltraGroupSetConversationChannelNotificationLevel = @"RCUltraGroup-SetConversationChannelNotificationLevel";
static NSString *RCUltraGroupGetConversationChannelNotificationLevel = @"RCUltraGroup-GetConversationChannelNotificationLevel";
static NSString *RCUltraGroupSetConversationTypeNotificationLevel = @"RCUltraGroup-SetConversationTypeNotificationLevel";
static NSString *RCUltraGroupGetConversationTypeNotificationLevel = @"RCUltraGroup-GetConversationTypeNotificationLevel";
static NSString *RCUltraGroupSetConversationDefaultNotificationLevel = @"RCUltraGroup-SetConversationDefaultNotificationLevel";
static NSString *RCUltraGroupGetConversationDefaultNotificationLevel = @"RCUltraGroup-GetConversationDefaultNotificationLevel";
static NSString *RCUltraGroupSetConversationChannelDefaultNotificationLevel = @"RCUltraGroup-SetConversationChannelDefaultNotificationLevel";
static NSString *RCUltraGroupGetConversationChannelDefaultNotificationLevel = @"RCUltraGroup-GetConversationChannelDefaultNotificationLevel";
static NSString *RCUltraGroupGetUltraGroupUnreadCount = @"RCUltraGroup-GetUltraGroupUnreadCount";
static NSString *RCUltraGroupGetUltraGroupAllUnreadCount = @"RCUltraGroup-GetUltraGroupAllUnreadCount";
static NSString *RCUltraGroupGetUltraGroupAllUnreadMentionedCount = @"RCUltraGroup-GetUltraGroupAllUnreadMentionedCount";
static NSString *RCUltraGroupConversationListDidSync = @"RCUltraGroup-ConversationListDidSync";


//callback iOS 通知 flutter
static NSString *RCMethodCallBackKeySendMessage = @"sendMessageCallBack";
static NSString *RCMethodCallBackKeyRefreshUserInfo = @"refreshUserInfoCallBack";
static NSString *RCMethodCallBackKeyReceiveMessage = @"receiveMessageCallBack";
static NSString *RCMethodCallBackKeyJoinChatRoom = @"joinChatRoomCallBack";
static NSString *RCMethodCallBackKeyQuitChatRoom = @"quitChatRoomCallBack";
static NSString *RCMethodCallBackKeyOnChatRoomReset = @"onChatRoomResetCallBack";
static NSString *RCMethodCallBackKeyOnChatRoomDestroyed = @"onChatRoomDestroyedCallBack";
static NSString *RCMethodCallBackKeyChatRoomKVDidSync = @"chatRoomKVDidSyncCallBack";
static NSString *RCMethodCallBackKeyChatRoomKVDidUpdate = @"chatRoomKVDidUpdateCallBack";
static NSString *RCMethodCallBackKeyChatRoomKVDidRemove = @"chatRoomKVDidRemoveCallBack";
static NSString *RCMethodCallBackKeyUploadMediaProgress = @"uploadMediaProgressCallBack";
static NSString *RCMethodCallBackKeyGetRemoteHistoryMessages = @"getRemoteHistoryMessagesCallBack";
static NSString *RCMethodCallBackKeyConnectionStatusChange = @"ConnectionStatusChangeCallBack";
static NSString *RCMethodCallBackKeySendDataToFlutter = @"SendDataToFlutterCallBack";
static NSString *RCMethodCallBackKeyReceiveReadReceipt = @"ReceiveReadReceiptCallBack";
static NSString *RCMethodCallBackKeyReceiptRequest = @"ReceiptRequestCallBack";
static NSString *RCMethodCallBackKeyReceiptResponse = @"ReceiptResponseCallBack";
static NSString *RCMethodCallBackKeyTypingStatusChanged = @"TypingStatusChangedCallBack";
static NSString *RCMethodCallBackKeyDownloadMediaMessage = @"DownloadMediaMessageCallBack";
static NSString *RCMethodCallBackKeyRecallMessage = @"RecallMessageCallBack";
static NSString *RCMethodCallBackKeyDestructMessage = @"DestructMessageCallBack";
static NSString *RCMethodCallBackKeyMessageExpansionDidUpdate = @"MessageExpansionDidUpdateCallBack";
static NSString *RCMethodCallBackKeyMessageExpansionDidRemove = @"MessageExpansionDidRemoveCallBack";
static NSString *RCMethodCallBackDatabaseOpened = @"DatabaseOpenedCallBack";
static NSString *RCMethodCallBackOnTagChanged = @"onTagChanged";
static NSString *RCMethodCallBackOnMessageBlocked = @"onMessageBlocked";
