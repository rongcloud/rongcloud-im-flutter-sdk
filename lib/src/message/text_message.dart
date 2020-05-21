import 'message_content.dart';
import 'dart:convert' show json;
import 'dart:developer' as developer;

class TextMessage extends MessageContent {
  static const String objectName = "RC:TxtMsg";

  String content;
  String extra;

  /// [content] 文本内容
  static TextMessage obtain(String content) {
    TextMessage msg = new TextMessage();
    msg.content = content;
    return msg;
  }

  @override
  void decode(String jsonStr) {
    if (jsonStr == null) {
      developer.log("Flutter TextMessage deocde error: no content",
          name: "RongIMClient.TextMessage");
      return;
    }
    Map map = json.decode(jsonStr.toString());
    this.content = map["content"];
    this.extra = map["extra"];
    Map userMap = map["user"];
    super.decodeUserInfo(userMap);
    Map menthionedMap = map["mentionedInfo"];
    super.decodeMentionedInfo(menthionedMap);
    this.destructDuration = map["burnDuration"];
  }

  @override
  String encode() {
    Map map = {"content": this.content, "extra": this.extra};
    if (this.sendUserInfo != null) {
      Map userMap = super.encodeUserInfo(this.sendUserInfo);
      map["user"] = userMap;
    }
    if (this.mentionedInfo != null) {
      Map mentionedMap = super.encodeMentionedInfo(this.mentionedInfo);
      map["mentionedInfo"] = mentionedMap;
    }
    if (this.destructDuration != null && this.destructDuration > 0) {
      map["burnDuration"] = this.destructDuration;
    }
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
}
