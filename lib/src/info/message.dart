import '../message/message_content.dart';

class Message extends Object {
  int conversationType; //会话类型 参见 RCConversationType
  String targetId; //会话 id
  int messageId; //messageId ，本地数据库的自增 id
  int messageDirection; //消息方向 参见 RCMessageDirection
  String senderUserId; //发送者 id
  int receivedStatus; //消息接收状态 参见 RCReceivedStatus
  int sentStatus; //消息发送状态 参见 RCSentStatus
  int sentTime; //发送时间，unix 时间戳，单位毫秒
  String objectName; //消息 objName
  MessageContent content; //消息内容
  String messageUId; //消息 UID，全网唯一 Id
  String extra; // 扩展信息
  bool canIncludeExpansion; // 消息是否可以包含扩展信息
  Map expansionDic; // 消息扩展信息列表

  ReadReceiptInfo readReceiptInfo; //阅读回执状态
  MessageConfig messageConfig; // 消息配置
  MessagePushConfig messagePushConfig; // 推送配置

  //如果 content 为 null ，说明消息内容本身未被 flutter 层正确解析，则消息内容会保存到该 map 中
  Map originContentMap;

  String toString() {
    return "messageId:$messageId messageUId:$messageUId objectName:$objectName conversationType:$conversationType targetId:$targetId  conversationType:$conversationType messageDirection:$messageDirection senderUserId:$senderUserId receivedStatus:$receivedStatus sentStatus:$sentStatus sentTime:$sentTime content:${content.encode()}";
  }
}

class ReadReceiptInfo extends Object {
  bool isReceiptRequestMessage; //是否需要回执消息
  bool hasRespond; //是否已经发送回执
  Map userIdList; //发送回执的用户ID列表
}

class MessageConfig extends Object {
  bool disableNotification; //是否关闭通知，true 为关闭通知，false 为打开通知，默认为 false
}

class MessagePushConfig extends Object {
  String pushTitle; //推送标题
  String pushContent; //推送内容
  String pushData; //远程推送附加信息
  bool forceShowDetailContent; //是否强制显示通知详情
  IOSConfig iOSConfig; //iOS 平台相关配置
  AndroidConfig androidConfig; //Android 平台相关配置
  bool disablePushTitle; //通知栏是否屏蔽通知标题
  String templateId; //推送模板 ID
}

class IOSConfig extends Object{
  String thread_id; //iOS 平台通知栏分组 ID
  String apns_collapse_id; //iOS 平台通知覆盖 ID
}

class AndroidConfig extends Object{
  String notificationId; // Android 平台 Push 唯一标识
  String channelIdMi; // 小米推送平台渠道 ID
  String channelIdHW; // 华为推送平台渠道 ID
  String channelIdOPPO; // OPPO 推送平台渠道 ID
  String typeVivo; // VIVO 推送平台推送类型 ,目前可选值"0"(运营消息); "1"(系统消息)
}