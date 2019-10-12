import 'message_content.dart';
import 'dart:convert' show json;

//小视频消息
//小视频消息使用必须在融云开发者后台进行开通
class SightMessage extends MessageContent {
  static const String objectName = "RC:SightMsg";

  String localPath;
  String remoteUrl;
  int duration;
  String extra;

  /// [localPath] 本地路径，Android 必须以 file:// 开头
  ///
  /// [duration] 视频时长，单位 秒
  static SightMessage obtain(String localPath,int duration) {
    SightMessage msg = new SightMessage();
    msg.localPath = localPath;
    msg.duration = duration;
    return msg;
  }

  @override
  void decode(String jsonStr) {
    if(jsonStr == null || jsonStr == "") {
      print("[RC-Flutter-IM] Flutter SightMessage deocde error: no content");
      return;
    }
    Map map = json.decode(jsonStr.toString());
    this.localPath = map["localPath"];
    this.remoteUrl = map["remoteUrl"];
    this.duration =  int.parse(map["duration"]);
    this.extra = map["extra"];
  }

  @override
  String encode() {
    Map map = {"localPath":this.localPath,"duration":this.duration,"extra":this.extra};
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