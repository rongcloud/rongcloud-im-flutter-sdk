// 会话类型 RCConversationType
const int RCConversationTypePrivate = 1;
const int RCConversationTypeGroup   = 3;

//method list
const String MethodKeyInit = 'init';
const String MethodKeyConfig = 'config';
const String MethodKeyConnect = 'connect';
const String MethodKeyPushToConversationList = 'pushToConversationList';
const String MethodKeyPushToConversation = 'pushToConversation';
const String MethodKeyRefrechUserInfo = 'refreshUserInfo';
const String MethodKeySendMessage = 'sendMessage';

//callback method list，以下方法是有 native 代码触发，由 flutter 处理
const String MethodCallBackKeyFetchUserInfo = 'fetchUserInfo';
