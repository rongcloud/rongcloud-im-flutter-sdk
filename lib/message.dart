import 'message_content.dart';

class Message extends Object {
  int conversationType;//会话类型 参见 RCConversationType
  String targetId;//会话 id
  int messageId;//messageId ，本地数据库的自增 id
  int messageDirection;//消息方向 参见 RCMessageDirection
  String senderUserId;//发送者 id
  int receivedStatus;//消息接收状态 参见 RCReceivedStatus
  int sentStatus;//消息发送状态 参见 RCSentStatus
  int sentTime;//发送时间，unix 时间戳，单位毫秒
  String objectName;//消息 objName
  MessageContent content;//消息内容
  String messageUId;//消息 UID，全网唯一 Id
  
  //如果 content 为 null ，说明消息内容本身未被 flutter 层正确解析，则消息内容会保存到该 map 中
  Map originContentMap;
}