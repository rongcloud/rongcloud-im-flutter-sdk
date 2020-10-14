// 会话类型
class RCConversationType {
  static const int Private = 1;
  static const int Group = 3;
  static const int ChatRoom = 4;
  static const int System = 6;
}

//消息发送状态
class RCSentStatus {
  static const int Sending = 10; //发送中
  static const int Failed = 20; //发送失败
  static const int Sent = 30; //发送成功
  static const int Received = 40; //对方已接收
  static const int Read = 50; //对方已阅读
}

//消息方向
class RCMessageDirection {
  static const int Send = 1;
  static const int Receive = 2;
}

//消息接收状态
class RCReceivedStatus {
  static const int Unread = 0; //未读
  static const int Read = 1; //已读
  static const int Listened = 2; //已听，语音消息
  static const int Downloaded = 4; //已下载
  static const int Retrieved = 8; //已经被其他登录的多端收取过
  static const int MultipleReceive = 16; //被多端同时收取
}

//回调状态
class RCOperationStatus {
  static const int Success = 0;
  static const int Failed = 1;
}

//消息免打扰状态
class RCConversationNotificationStatus {
  static const int DoNotDisturb = 0; //免打扰
  static const int Notify = 1; //新消息通知
}

//聊天室成员顺序
class RCChatRoomMemberOrder {
  static const int Asc = 1; //升序，最早加入
  static const int Desc = 2; //降序，最晚加入
}

//用户黑名单状态
class RCBlackListStatus {
  static const int In = 0; //在黑名单中
  static const int NotIn = 1; //不在黑名单中
}

//@ 提醒的类型
class RCMentionedType {
  static const int All = 1; //@所有人
  static const int Users = 2; //@部分指定用户
}

class RCConnectionStatus {
  static const int Connected = 0; //连接成功
  static const int Connecting = 1; //连接中
  static const int KickedByOtherClient = 2; //该账号在其他设备登录，导致当前设备掉线
  static const int NetworkUnavailable = 3; //网络不可用
  static const int TokenIncorrect = 4; //token 非法，此时无法连接 im，需重新获取 token
  static const int UserBlocked = 5; //用户被封禁
  static const int DisConnected = 6; //用户主动断开
  static const int Suspend = 13; // 连接暂时挂起（多是由于网络问题导致），SDK 会在合适时机进行自动重连
  static const int Timeout =
      14; // 自动连接超时，SDK 将不会继续连接，用户需要做超时处理，再自行调用 connectWithToken 接口进行连接
}

///错误码
///
///iOS 参考 [RCStatusDefine.h] 的枚举 [RCConnectErrorCode] 和 [RCErrorCode]
///Android 参考 [RongIMClient.java] 的枚举 [ErrorCode]
class RCErrorCode {
  ///成功
  static const int Success = 0;

  ///已被对方加入黑名单
  static const int RejectedByBlackList = 405;

  ///发送消息频率过高，1秒最多允许发送5条消息
  static const int SendMsgOverfrequency = 20604;

  ///不在该群组中
  static const int NotInGroup = 22406;

  ///在群组中被禁言
  static const int ForbiddenInGroup = 22408;

  ///不在该聊天室中
  static const int NotInChatRoom = 23406;

  ///在聊天室中被禁言
  static const int ForbiddenInChatRoom = 23408;

  ///AppKey 错误
  static const int AppKeyError = 31002;

  ///token 无效，需要获取新的 token 连接 IM
  ///一般有已下两种原因
  ///一是token错误，请您检查客户端初始化使用的AppKey和您服务器获取token使用的AppKey是否一致；
  ///二是token过期，是因为您在开发者后台设置了token过期时间，您需要请求您的服务器重新获取token并再次用新的token建立连接。
  static const int TokenIncorrect = 31004;

  /// AppKey 与 Token 不匹配，需要获取新的 token 连接 IM
  /// 原因同 [TokenIncorrect]
  static const int NotAuthrorized = 31005;

  /// AppKey 被封禁或者已删除，请检查 AppKey 是否正确
  static const int AppBlockedOrDeleted = 31008;

  /// 用户被封禁，请检查 Token 是否正确以及对应的 UserId 是否被封禁
  static const int UserBlocked = 31009;

  /// 被其他端踢掉线
  static const int KickByOtherClient = 31010;

  /// SDK 没有初始化，使用任何 SDK 接口前必须先调用 init 接口
  static const int ClientNotInit = 33001;

  /// 非法参数，请检查调用接口传入的参数
  static const int InvalidParameter = 33003;

  /// 历史消息云存储功能未开通
  static const int RoamingServiceUnAvailable = 33007;

  /// 小视频消息时长超限，最长 10s
  static const int SightMessageDurationLimitExceed = 34002;
}

class RCSaveMediaType {
  static const String IMAGE = 'image';
  static const String VIDEO = 'video';
}

class RCTimestampOrder {
  /// 降序, 按照时间戳从大到小
  static const int RC_Timestamp_Desc = 0;

  /// 升序, 按照时间戳从小到大
  static const int RC_Timestamp_Asc = 1;
}
