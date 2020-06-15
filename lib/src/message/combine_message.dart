import 'dart:convert';
import 'message_content.dart';
import 'dart:developer' as developer;

class CombineMessage extends MessageContent {
  static const String objectName = "RC:CombineMsg";
  String title = "";
  // 这两个参数用来拼装默认消息的标题
  // 区分合并消息是在群聊里还是单聊里
  int conversationType;
  // 单聊里最多有两个,群聊不记录
  List<String> nameList;
  // 默认消息的内容
  List<String> summaryList;
  String localPath;
  String mMediaUrl;
  String extra = "";
  String mName = "";

  static CombineMessage obtain(String localPath) {
    CombineMessage msg = new CombineMessage();
    msg.localPath = localPath;
    // 会话类型默认是私聊
    msg.conversationType = 1;
    return msg;
  }

  @override
  String encode() {
    Map map = {
      "title": title,
      "name": mName,
      "localPath": localPath,
      "remoteUrl": mMediaUrl,
      "extra": extra,
      "conversationType": conversationType,
      "nameList": nameList,
      "summaryList": summaryList
    };
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
  void decode(String jsonStr) {
    if (jsonStr == null || jsonStr == "") {
      developer.log("Flutter CombineMessage deocde error: no content",
          name: "RongIMClient.CombineMessage");
      return;
    }
    Map map = json.decode(jsonStr);
    this.title = map["title"];
    this.mName = map["name"];
    this.mMediaUrl = map["remoteUrl"];
    this.localPath = map["localPath"];
    this.conversationType = map["conversationType"];
    if (map["nameList"] != null) {
      this.nameList = List<String>.from(map["nameList"]);
    } else {
      this.nameList = List();
    }

    this.summaryList = List<String>.from(map["summaryList"]);
    this.extra = map["extra"];
    Map userMap = map["user"];
    super.decodeUserInfo(userMap);
    Map menthionedMap = map["mentionedInfo"];
    super.decodeMentionedInfo(menthionedMap);
    this.destructDuration = map["burnDuration"];
  }

  @override
  String conversationDigest() {
    return "[聊天记录]";
  }

  @override
  String getObjectName() {
    return objectName;
  }
}
