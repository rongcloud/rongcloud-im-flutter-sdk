import 'dart:convert' show json;
import 'message_content.dart';

class VoiceMessage extends MessageContent {

  static const String objectName = "RC:HQVCMsg";

  int duration;
  String extra;
  String content;
  String localPath;
  Uri remoteUri;

  ///构造方法
  ///
  /// localPath 本地路径，必须以 file:// 开头
  ///
  /// duration 语音时长，单位 秒
  VoiceMessage(String localPath,int duration) {
    this.localPath = localPath;
    this.duration = duration;
  }

  @override
  void decode(String jsonStr) {
    if(jsonStr == null) {
      print("[RC-Flutter-IM] Flutter VoiceMessage deocde error: no content");
      return;
    }
    Map map = json.decode(jsonStr.toString());
    this.content = map["content"];
    this.duration = map["duration"];
    this.extra = map["extra"];
    this.localPath = map["localPath"];
    this.remoteUri = map["remoteUrl"];
  }

  @override
  String encode() {
    Map map = {"content":this.content,"duration":this.duration,"extra":this.extra,"localPath":this.localPath,"remoteUrl":this.remoteUri};
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