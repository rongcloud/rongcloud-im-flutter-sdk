import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'dart:convert' show json;

//app 层的测试消息
class TestMessage extends MessageContent {
  static const String objectName = "RCD:TstMsg";

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
}