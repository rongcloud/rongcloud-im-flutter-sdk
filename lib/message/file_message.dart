import 'dart:convert';

import 'message_content.dart';

class FileMessage extends MessageContent {
  static const String objectName = "RC:FileMsg";
  int mSize;
  String mType; //后缀名，默认是 bin
  int progress;
  String localPath;
  String mMediaUrl;
  String extra = "";
  String mName = "";

  /// [localPath] 本地路径，Android 必须以 file:// 开头
  static FileMessage obtain(String localPath) {
    FileMessage msg = new FileMessage();
    msg.localPath = localPath;
    return msg;
  }

  @override
  void decode(String jsonStr) {
    Map map = json.decode(jsonStr);
    this.mName = map["name"];
    this.mType = map["type"];
    this.mSize = map["size"];
    this.localPath = map["localPath"];
    this.extra = map["extra"];
    this.mMediaUrl = map["fileUrl"];
    Map userMap = map["user"];
    super.decodeUserInfo(userMap);
    Map menthionedMap = map["mentionedInfo"];
    super.decodeMentionedInfo(menthionedMap);
  }

  @override
  String encode() {
    Map map = {"extra": this.extra, "type": mType, "name": mName, "size": mSize};
    if (this.localPath != null) {
      map["localPath"] = this.localPath;
    } else {
      map["localPath"] = "";
    }
    if (mMediaUrl != null && mMediaUrl.length > 0) {
      map['fileUrl'] = mMediaUrl;
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
    return "文件";
  }

  @override
  String getObjectName() {
    return objectName;
  }
}
