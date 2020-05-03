import 'dart:convert' show json;

import 'message_content.dart';

class ImageMessage extends MessageContent {
  static const String objectName = "RC:ImgMsg";

  String localPath;
  String extra;
  String content;
  String imageUri;
  String mThumbUri; //缩略图地址

  /// [localPath] 本地路径，Android 必须以 file:// 开头
  static ImageMessage obtain(String localPath) {
    ImageMessage msg = new ImageMessage();
    msg.localPath = localPath;
    return msg;
  }

  @override
  void decode(String jsonStr) {
    Map map = json.decode(jsonStr.toString());
    this.localPath = map["localPath"];
    this.content = map["content"];
    this.imageUri = map["imageUri"];
    this.mThumbUri = map["thumbUri"];
    this.extra = map["extra"];
    Map userMap = map["user"];
    super.decodeUserInfo(userMap);
    Map menthionedMap = map["mentionedInfo"];
    super.decodeMentionedInfo(menthionedMap);
  }

  @override
  String encode() {
    Map map = {"extra": this.extra};
    if (this.content != null) {
      map["content"] = this.content;
    }
    if (this.localPath != null) {
      map["localPath"] = this.localPath;
    } else {
      map["localPath"] = "";
    }
    if (this.imageUri != null) {
      map["imageUri"] = this.imageUri;
    }
    if (this.mThumbUri != null) {
      map["thumbUri"] = this.mThumbUri;
    }
    if (this.sendUserInfo != null) {
      Map userMap = super.encodeUserInfo(this.sendUserInfo);
      map["user"] = userMap;
    }
    if (this.mentionedInfo != null) {
      Map mentionedMap = super.encodeMentionedInfo(this.mentionedInfo);
      map["mentionedInfo"] = mentionedMap;
    }
    return json.encode(map);
  }

  @override
  String conversationDigest() {
    return "图片";
  }

  @override
  String getObjectName() {
    return objectName;
  }
}
