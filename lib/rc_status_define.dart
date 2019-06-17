//消息存储标识
class RCMessagePersistentFlag {
  static const int None = 0;
  static const int IsPersisted = 1;
  static const int IsCounted = 3;
  static const int Status = 16;
}

//消息发送状态
class RCMessageSentStatus {
  static const int Sending = 10;//发送中
  static const int Failed = 20;//发送失败
  static const int Sent = 30;//发送成功
}