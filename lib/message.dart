import 'message_content.dart';

class Message extends Object {
  int conversationType;
  String targetId;
  int messageId;
  int messageDirection;
  String senderUserId;
  int receivedStatus;
  int sentStatus;
  int sentTime;
  String objectName;
  MessageContent content;
  String messageUId;
  
  //如果消息本身未被正确解析，那么会保存到该 map 中
  Map originContentMap;
}