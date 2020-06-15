import 'message_content.dart';
import 'dart:convert' show json;
import 'dart:developer' as developer;

class RecallNotificationMessage extends MessageContent {
  static const String objectName = "RC:RcNtf";

  String mOperatorId; //发起撤回消息的用户id
  int mRecallTime; //撤回的时间（毫秒）
  String mOriginalObjectName; //原消息的消息类型名
  bool mAdmin; //是否是管理员操作
  bool mDelete; //是否删除
  String recallContent; //撤回的文本消息的内容
  int recallActionTime; //撤回消息的发送时间

  @override
  void decode(String jsonStr) {
    if (jsonStr == null && jsonStr.isEmpty) {
      developer.log(
          "Flutter RecallNotificationMessage deocde error: no content",
          name: "RongIMClient.RecallNotificationMessage");
      return;
    }
    Map map = json.decode(jsonStr.toString());
    this.mOperatorId = map["operatorId"];
    this.mRecallTime = map["recallTime"];
    this.mOriginalObjectName = map["originalObjectName"];
    this.mAdmin = map["admin"];
    this.mDelete = map["delete"];
    this.recallContent = map["recallContent"];
    this.recallActionTime =
        map["recallActionTime"] != null ? map["recallActionTime"] : 0;
    Map userMap = map["user"];
    super.decodeUserInfo(userMap);
    Map menthionedMap = map["mentionedInfo"];
    super.decodeMentionedInfo(menthionedMap);
  }

  @override
  String encode() {
    Map map = {
      "mOperatorId": this.mOperatorId,
      "mRecallTime": this.mRecallTime,
      "mOriginalObjectName": this.mOriginalObjectName,
      "mAdmin": this.mAdmin,
      "mDelete": this.mDelete,
      "recallContent": this.recallContent,
    };

    if (this.recallActionTime != null) {
      map["recallActionTime"] = this.recallActionTime;
    }
    if (this.sendUserInfo != null) {
      Map userMap = super.encodeUserInfo(this.sendUserInfo);
      map["user"] = userMap;
    } else {
      map["user"] = [];
    }
    if (this.mentionedInfo != null) {
      Map mentionedMap = super.encodeMentionedInfo(this.mentionedInfo);
      map["mentionedInfo"] = mentionedMap;
    }
    return json.encode(map);
  }

  @override
  String conversationDigest() {
    return "撤回了一条消息";
  }

  @override
  String getObjectName() {
    return objectName;
  }
}
