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
static NSString *RCMethodKeyQuitChatRoom = @"quitChatRoom";
static NSString *RCMethodKeyGetHistoryMessage = @"getHistoryMessage";
static NSString *RCMethodKeyGetMessage = @"GetMessage";
static NSString *RCMethodKeyGetConversationList = @"getConversationList";
static NSString *RCMethodKeyGetConversation = @"GetConversation";
static NSString *RCMethodKeyGetChatRoomInfo = @"getChatRoomInfo";
static NSString *RCMethodKeyClearMessagesUnreadStatus = @"clearMessagesUnreadStatus";
static NSString *RCMethodKeySetServerInfo = @"setServerInfo";
static NSString *RCMethodKeySetCurrentUserInfo = @"setCurrentUserInfo";
static NSString *RCMethodKeyInsertIncomingMessage = @"insertIncomingMessage";
static NSString *RCMethodKeyInsertOutgoingMessage = @"insertOutgoingMessage";
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


//callback iOS 通知 flutter
static NSString *RCMethodCallBackKeySendMessage = @"sendMessageCallBack";
static NSString *RCMethodCallBackKeyRefreshUserInfo = @"refreshUserInfoCallBack";
static NSString *RCMethodCallBackKeyReceiveMessage = @"receiveMessageCallBack";
static NSString *RCMethodCallBackKeyJoinChatRoom = @"joinChatRoomCallBack";
static NSString *RCMethodCallBackKeyQuitChatRoom = @"quitChatRoomCallBack";
static NSString *RCMethodCallBackKeyUploadMediaProgress = @"uploadMediaProgressCallBack";
static NSString *RCMethodCallBackKeyGetRemoteHistoryMessages = @"getRemoteHistoryMessagesCallBack";
static NSString *RCMethodCallBackKeyConnectionStatusChange = @"ConnectionStatusChangeCallBack";
static NSString *RCMethodCallBackKeySendDataToFlutter = @"SendDataToFlutterCallBack";




