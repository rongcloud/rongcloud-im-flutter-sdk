import 'dart:convert' show json;
import 'message_content.dart';

class VoiceMessage extends MessageContent {

  static const String objectName = "RC:HQVCMsg";

  int duration;
  String extra;
  String content;
  String localPath;
  Uri remoteUri;


  @override
  void decode(String jsonStr) {
    Map map = json.decode(jsonStr.toString());
    this.content = map["content"];
    this.duration = map["duration"];
    this.extra = map["extra"];
    this.localPath = map["extra"];
    this.remoteUri = map["extra"];
  }

  @override
  String encode() {
    Map map = {"localPath":this.localPath,"duration":this.duration,"extra":this.extra,"localPath":this.localPath,"localPath":this.remoteUri};
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