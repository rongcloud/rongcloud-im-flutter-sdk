import 'dart:convert' show json;
import 'message_content.dart';
import 'dart:developer' as developer;

class VoiceMessage extends MessageContent {
  static const String objectName = "RC:HQVCMsg";

  String localPath;
  String remoteUrl;
  int duration;
  String extra;

  /// [localPath] 本地路径，Android 必须以 file:// 开头
  ///
  /// [duration] 语音时长，单位 秒
  static VoiceMessage obtain(String localPath, int duration) {
    VoiceMessage msg = new VoiceMessage();
    msg.localPath = localPath;
    msg.duration = duration;
    return msg;
  }

  @override
  void decode(String jsonStr) {
    if (jsonStr == null) {
      developer.log("Flutter VoiceMessage deocde error: no content",
          name: "RongIMClient.VoiceMessage");
      return;
    }
    Map map = json.decode(jsonStr.toString());
    this.localPath = map["localPath"];
    this.remoteUrl = map["remoteUrl"];
    this.duration = map["duration"];
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
    if (this.localPath != null) {
      map["localPath"] = this.localPath;
    } else {
      map["localPath"] = "";
    }
    if (this.remoteUrl != null) {
      map["remoteUrl"] = this.remoteUrl;
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
    return "语音";
  }

  @override
  String getObjectName() {
    return objectName;
  }
}
