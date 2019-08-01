import 'dart:convert' show json;
import 'message_content.dart';

class VoiceMessage extends MessageContent {

  static const String objectName = "RC:HQVCMsg";

  String localPath;
  String remoteUrl;
  int duration;
  String extra;

  /// [localPath] 本地路径，Android 必须以 file:// 开头
  ///
  /// [duration] 语音时长，单位 秒
  static VoiceMessage build(String localPath,int duration) {
    VoiceMessage msg = new VoiceMessage();
    msg.localPath = localPath;
    msg.duration = duration;
    return msg;
  }

  @override
  void decode(String jsonStr) {
    if(jsonStr == null) {
      print("[RC-Flutter-IM] Flutter VoiceMessage deocde error: no content");
      return;
    }
    Map map = json.decode(jsonStr.toString());
    this.localPath = map["localPath"];
    this.remoteUrl = map["remoteUrl"];
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
}