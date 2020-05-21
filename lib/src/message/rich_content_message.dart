import 'message_content.dart';
import 'dart:convert' show json;
import 'dart:developer' as developer;

/// 图文消息
class RichContentMessage extends MessageContent {
  static const String objectName = "RC:ImgTextMsg";

  String title;
  String digest;
  String imageURL;
  String url;
  String extra;

  /// [content] 文本内容
  static RichContentMessage obtain(String title, String digest, String imageURL,
      {String url = '', String extra = ''}) {
    RichContentMessage msg = new RichContentMessage();
    msg.title = title;
    msg.digest = digest;
    msg.imageURL = imageURL;
    msg.url = url;
    msg.extra = extra;
    return msg;
  }

  @override
  void decode(String jsonStr) {
    if (jsonStr == null) {
      developer.log("Flutter TextMessage deocde error: no content",
          name: "RongIMClient.RichContentMessage");
      return;
    }
    Map map = json.decode(jsonStr.toString());
    this.imageURL = map["imageUri"];
    this.extra = map["extra"];
    this.digest = map["content"];
    this.title = map["title"];
    this.url = map["url"];
    Map userMap = map["user"];
    super.decodeUserInfo(userMap);
    Map menthionedMap = map["mentionedInfo"];
    super.decodeMentionedInfo(menthionedMap);
    // this.destructDuration = map["burnDuration"];
  }

  @override
  String encode() {
    Map map = {
      "imageUri": this.imageURL,
      "extra": this.extra,
      "content": this.digest,
      "title": this.title,
      "url": this.url
    };
    if (this.sendUserInfo != null) {
      Map userMap = super.encodeUserInfo(this.sendUserInfo);
      map["user"] = userMap;
    }
    if (this.mentionedInfo != null) {
      Map mentionedMap = super.encodeMentionedInfo(this.mentionedInfo);
      map["mentionedInfo"] = mentionedMap;
    }
    // if (this.destructDuration != null && this.destructDuration > 0) {
    //   map["burnDuration"] = this.destructDuration;
    // }
    return json.encode(map);
  }

  @override
  String conversationDigest() {
    return "图文";
  }

  @override
  String getObjectName() {
    return objectName;
  }
}
