import 'rc_status_define.dart';
import 'message_content.dart';
import 'dart:convert' show json;

class VoiceMessage extends MessageContent {
  static const String objectName = "RC:VcMsg";

  String localPath;
  int duration;//语音时长，单位 s
  String extra;
  String content;//base 64 字符串

  @override
  void decode(String jsonStr) {
    Map map = json.decode(jsonStr.toString());
    this.content = map["content"];
    this.duration = map["duration"];
    this.extra = map["extra"];
  }

  @override
  String encode() {
    Map map = {"localPath":this.localPath,"duration":this.duration,"extra":this.extra};
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

  static int persistentFlag() {
    return RCMessagePersistentFlag.IsPersisted | RCMessagePersistentFlag.IsCounted;
  }
}