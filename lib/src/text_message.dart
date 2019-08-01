import 'message_content.dart';
import 'dart:convert' show json;

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
    if(jsonStr == null) {
      print("[RC-Flutter-IM] Flutter TextMessage deocde error: no content");
      return;
    }
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

}