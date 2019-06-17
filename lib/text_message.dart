import 'rc_status_define.dart';
import 'message_content.dart';
import 'dart:convert' show json;

class TextMessage extends MessageContent {
  static const String objectName = "RC:TxtMsg";

  String content;
  String extra;
  @override
  void decode(String jsonStr) {
    Map map = json.decode(jsonStr.toString());
    this.content = map["content"];
    this.extra = map["extra"];
  }

  @override
  String encode() {
    Map map = {"content":this.content,"extra":this.extra};
    return json.encode(map);
  }

  @override
  String conversationDigest() {
    return content;
  }

  @override
  String getObjectName() {
    return objectName;
  }

  static int persistentFlag() {
    return RCMessagePersistentFlag.IsPersisted | RCMessagePersistentFlag.IsCounted;
  }
}