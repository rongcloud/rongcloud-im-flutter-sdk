import 'message_content.dart';
import 'dart:convert' show json;
import 'dart:developer' as developer;

//Gif消息
class GifMessage extends MessageContent {
  static const String objectName = "RC:GIFMsg";

  String localPath; //本地路径
  String remoteUrl; //远端路径
  int width; //GIF 图的宽
  int height; //GIF 图的高
  int gifDataSize; //GIF 图的大小
  String name; //名字
  String extra; //GIF 消息的附加信息

  /// 根据 localPath 构建 GifMessage
  /// [localPath] 本地路径，Android 必须以 file:// 开头
  static GifMessage obtain(String localPath, {int width = 0, int height = 0}) {
    GifMessage msg = new GifMessage();
    msg.localPath = localPath;
    msg.width = width;
    msg.height = height;
    return msg;
  }

  @override
  void decode(String jsonStr) {
    if (jsonStr == null || jsonStr == "") {
      developer.log("Flutter GifMessage deocde error: no content",
          name: "RongIMClient.GifMessage");
      return;
    }
    Map map = json.decode(jsonStr.toString());
    this.localPath = map["localPath"];
    this.remoteUrl = map["remoteUrl"];
    // this.gifImageData = map["gifImageData"];
    this.width = map["width"];
    this.height = map["height"];
    this.name = map["name"];
    this.extra = map["extra"];
    this.gifDataSize = map["gifDataSize"];
    Map userMap = map["user"];
    super.decodeUserInfo(userMap);
    Map menthionedMap = map["mentionedInfo"];
    super.decodeMentionedInfo(menthionedMap);
    this.destructDuration = map["burnDuration"];
  }

  @override
  String encode() {
    Map map = {"localPath": this.localPath, "extra": this.extra};
    if (this.width != null) {
      map["width"] = this.width;
    }
    if (this.height != null) {
      map["height"] = this.height;
    }
    if (this.name != null) {
      map["name"] = this.name;
    }
    if (this.gifDataSize != null) {
      map["gifDataSize"] = this.gifDataSize;
    }
    if (this.sendUserInfo != null) {
      Map userMap = super.encodeUserInfo(this.sendUserInfo);
      map["user"] = userMap;
    }
    if (this.mentionedInfo != null) {
      Map mentionedMap = super.encodeMentionedInfo(this.mentionedInfo);
      map["mentionedInfo"] = mentionedMap;
    }
    if (this.remoteUrl != null && this.remoteUrl.isNotEmpty) {
      map["remoteUrl"] = this.remoteUrl;
    }
    if (this.destructDuration != null && this.destructDuration > 0) {
      map["burnDuration"] = this.destructDuration;
    }
    return json.encode(map);
  }

  @override
  String conversationDigest() {
    return "动图";
  }

  @override
  String getObjectName() {
    return objectName;
  }
}
