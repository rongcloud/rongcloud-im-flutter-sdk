//method list
class RCMethodKey {
  static const String Init = 'init';
  static const String Config = 'config';
  static const String Connect = 'connect';
  static const String Disconnect = 'disconnect';
  static const String SendMessage = 'sendMessage';
  static const String RefreshUserInfo = 'refreshUserInfo';
  static const String JoinChatRoom = 'joinChatRoom';
  static const String QuitChatRoom = 'quitChatRoom';
  static const String GetHistoryMessage = 'getHistoryMessage';
  static const String GetHistoryMessages = 'getHistoryMessages';
  static const String GetMessage = 'GetMessage';
  static const String GetConversationList = 'getConversationList';
  static const String GetConversationListByPage = 'getConversationListByPage';
  static const String GetConversation = 'GetConversation';
  static const String GetChatRoomInfo = 'getChatRoomInfo';
  static const String ClearMessagesUnreadStatus = 'clearMessagesUnreadStatus';
  static const String SetServerInfo = 'setServerInfo';
  static const String SetCurrentUserInfo = 'setCurrentUserInfo';
  static const String InsertIncomingMessage = 'insertIncomingMessage';
  static const String InsertOutgoingMessage = 'insertOutgoingMessage';
  static const String GetTotalUnreadCount = 'getTotalUnreadCount';
  static const String GetUnreadCountTargetId = 'getUnreadCountTargetId';
  static const String GetUnreadCountConversationTypeList =
      'getUnreadCountConversationTypeList';
  static const String SetConversationNotificationStatus =
      'setConversationNotificationStatus';
  static const String GetConversationNotificationStatus =
      'getConversationNotificationStatus';
  static const String RemoveConversation = 'RemoveConversation';
  static const String GetBlockedConversationList = 'getBlockedConversationList';
  static const String SetConversationToTop = 'setConversationToTop';
  static const String GetTopConversationList = 'getTopConversationList';
  static const String DeleteMessages = 'DeleteMessages';
  static const String DeleteMessageByIds = 'DeleteMessageByIds';
  static const String AddToBlackList = 'AddToBlackList';
  static const String RemoveFromBlackList = 'RemoveFromBlackList';
  static const String GetBlackListStatus = 'GetBlackListStatus';
  static const String GetBlackList = 'GetBlackList';
  static const String SendReadReceiptMessage = 'SendReadReceiptMessage';
  static const String SendReadReceiptRequest = 'SendReadReceiptRequest';
  static const String SendReadReceiptResponse = 'SendReadReceiptResponse';
  static const String ClearHistoryMessages = 'ClearHistoryMessages';
  static const String RecallMessage = 'recallMessage';
  static const String GetTextMessageDraft = 'getTextMessageDraft';
  static const String SaveTextMessageDraft = 'saveTextMessageDraft';
  static const String SyncConversationReadStatus = 'syncConversationReadStatus';
  static const String SearchConversations = 'searchConversations';
  static const String SearchMessages = 'searchMessages';
  static const String SendTypingStatus = 'sendTypingStatus';
  static const String DownloadMediaMessage = 'downloadMediaMessage';
  static const String SetNotificationQuietHours = 'setNotificationQuietHours';
  static const String RemoveNotificationQuietHours =
      'removeNotificationQuietHours';
  static const String GetNotificationQuietHours = 'getNotificationQuietHours';
  static const String GetUnreadMentionedMessages = 'getUnreadMentionedMessages';
  static const String SendDirectionalMessage = 'sendDirectionalMessage';
  static const String SaveMediaToPublicDir = 'saveMediaToPublicDir';
  static const String ForwardMessageByStep = 'forwardMessageByStep';
  static const String MessageBeginDestruct = 'messageBeginDestruct';
  static const String MessageStopDestruct = 'messageStopDestruct';
  static const String DeleteRemoteMessages = 'deleteRemoteMessages';
  static const String ClearMessages = 'clearMessages';
  static const String SetMessageExtra = 'setMessageExtra';
  static const String SetMessageReceivedStatus = 'setMessageReceivedStatus';
  static const String SetMessageSentStatus = 'setMessageSentStatus';
  static const String ClearConversations = 'clearConversations';
  static const String GetDeltaTime = 'getDeltaTime';
  static const String SetOfflineMessageDuration = 'setOfflineMessageDuration';
  static const String GetOfflineMessageDuration = 'getOfflineMessageDuration';
  static const String SetReconnectKickEnable = 'setReconnectKickEnable';
  static const String GetConnectionStatus = 'getConnectionStatus';
  static const String CancelDownloadMediaMessage = 'cancelDownloadMediaMessage';
  static const String GetRemoteChatRoomHistoryMessages =
      'getRemoteChatRoomHistoryMessages';
  static const String GetMessageByUId = 'getMessageByUId';
  static const String GetFirstUnreadMessage = 'getFirstUnreadMessage';
  static const String SendIntactMessage = 'sendIntactMessage';

  // 聊天室状态存储
  static const String SetChatRoomEntry = 'SetChatRoomEntry';
  static const String ForceSetChatRoomEntry = 'ForceSetChatRoomEntry';
  static const String GetChatRoomEntry = 'GetChatRoomEntry';
  static const String GetAllChatRoomEntries = 'GetAllChatRoomEntries';
  static const String RemoveChatRoomEntry = 'RemoveChatRoomEntry';
  static const String ForceRemoveChatRoomEntry = 'ForceRemoveChatRoomEntry';

  // 消息扩展
  static const String UpdateMessageExpansion = 'updateMessageExpansion';
  static const String RemoveMessageExpansionForKey =
      'removeMessageExpansionForKey';
}

//callback list //native 会触发此方法
class RCMethodCallBackKey {
  static const String SendMessage = 'sendMessageCallBack';
  static const String RefreshUserInfo = 'refreshUserInfoCallBack';
  static const String ReceiveMessage = 'receiveMessageCallBack';
  static const String JoinChatRoom = 'joinChatRoomCallBack';
  static const String QuitChatRoom = 'quitChatRoomCallBack';
  static const String ChatRoomKVDidSync = 'chatRoomKVDidSyncCallBack';
  static const String ChatRoomKVDidUpdate = 'chatRoomKVDidUpdateCallBack';
  static const String ChatRoomKVDidRemove = 'chatRoomKVDidRemoveCallBack';
  static const String UploadMediaProgress = 'uploadMediaProgressCallBack';
  static const String GetRemoteHistoryMessages =
      'getRemoteHistoryMessagesCallBack';
  static const String ConnectionStatusChange = 'ConnectionStatusChangeCallBack';
  static const String SendDataToFlutter = 'SendDataToFlutterCallBack';
  static const String ReceiveReadReceipt = 'ReceiveReadReceiptCallBack';
  static const String ReceiptRequest = 'ReceiptRequestCallBack';
  static const String ReceiptResponse = 'ReceiptResponseCallBack';
  static const String TypingStatusChanged = 'TypingStatusChangedCallBack';
  static const String DownloadMediaMessage = 'DownloadMediaMessageCallBack';
  static const String RecallMessage = 'RecallMessageCallBack';
  static const String DestructMessage = 'DestructMessageCallBack';
  static const String MessageExpansionDidUpdate = 'MessageExpansionDidUpdateCallBack';
  static const String MessageExpansionDidRemove = 'MessageExpansionDidRemoveCallBack';
}
