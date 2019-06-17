// 会话类型
class RCConversationType {
  static const int Private = 1;
  static const int Group = 3;
}

//method list
class RCMethodKey {
  static const String Init = 'init';
  static const String Config = 'config';
  static const String Connect = 'connect';
  static const String PushToConversationList = 'pushToConversationList';
  static const String PushToConversation = 'pushToConversation';
  static const String RefrechUserInfo = 'refreshUserInfo';
  static const String SendMessage = 'sendMessage';
}

//callback list //native 会触发此方法
class RCMethodCallBackKey {
  static const String SendMessage = 'sendMessageCallBack';
  static const String RefrechUserInfo = 'refreshUserInfoCallBack';
  static const String ReceiveMessage = 'receiveMessageCallBack';
}
