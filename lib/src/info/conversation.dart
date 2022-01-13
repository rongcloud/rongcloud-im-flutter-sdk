import '../message/message_content.dart';

class Conversation {
  int? conversationType;
  String? targetId;
  String? channelId;
  int? unreadMessageCount;
  int? receivedStatus;
  int? sentStatus;
  int? sentTime;
  bool? isTop;
  String? objectName;
  String? senderUserId;
  int? latestMessageId;
  MessageContent? latestMessageContent;
  int? mentionedCount; // 会话中@消息的个数
  String? draft; //会话草稿内容
  int? blockStatus; // 会话是否是免打扰状态
  int? receivedTime;

  //如果 content 为 null ，说明消息内容本身未被 flutter 层正确解析，则消息内容会保存到该 map 中
  Map? originContentMap;
}
