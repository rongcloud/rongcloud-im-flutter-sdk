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
  String messageUid;
}