import 'message_content.dart';
import 'dart:convert' show json;
import 'dart:developer' as developer;

//小视频消息
//小视频消息使用必须在融云开发者后台进行开通
class SightMessage extends MessageContent {
  static const String objectName = "RC:SightMsg";

  String localPath; //本地路径
  String remoteUrl; //远端路径
  String content; //缩略图内容
  int duration; //时长
  String extra; //额外数据
  int size = 0;
  String mThumbUri; //缩略图地址
  String mName = "";
  int mSize;

  /// [localPath] 本地路径，Android 必须以 file:// 开头
  ///
  /// [duration] 视频时长，单位 秒
  static SightMessage obtain(String localPath, int duration) {
    SightMessage msg = new SightMessage();
    msg.localPath = localPath;
    msg.duration = duration;
    return msg;
  }

  @override
  void decode(String jsonStr) {
    if (jsonStr == null || jsonStr == "") {
      developer.log("Flutter SightMessage deocde error: no content",
          name: "RongIMClient.SightMessage");
      return;
    }
    Map map = json.decode(jsonStr.toString());
    this.mName = map["name"];
    var size = map["size"] != null ? map["size"] : 0;
    if (size is String) {
      this.mSize = int.parse(size);
    } else {
      this.mSize = size;
    }
    this.localPath = map["localPath"];
    this.remoteUrl = map["sightUrl"];
    this.content = map["content"];
    this.mThumbUri = map["thumbUri"];
    var d = map["duration"];
    if (d is String) {
      this.duration = int.parse(d);
    } else {
      this.duration = d;
    }
    this.extra = map["extra"];
    Map userMap = map["user"];
    super.decodeUserInfo(userMap);
    Map menthionedMap = map["mentionedInfo"];
    super.decodeMentionedInfo(menthionedMap);
    this.destructDuration = map["burnDuration"];
  }

  @override
  String encode() {
    Map map = {"duration": this.duration, "extra": this.extra};
    if (this.size > 0) {
      map["size"] = this.size;
    }
    if (this.content != null) {
      map["content"] = this.content;
    }
    if (this.localPath != null) {
      map["localPath"] = this.localPath;
    } else {
      map["localPath"] = "";
    }
    if (this.remoteUrl != null) {
      map["sightUrl"] = this.remoteUrl;
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
    if (this.destructDuration != null && this.destructDuration > 0) {
      map["burnDuration"] = this.destructDuration;
    }
    return json.encode(map);
  }

  @override
  String conversationDigest() {
    return "小视频";
  }

  @override
  String getObjectName() {
    return objectName;
  }
}
