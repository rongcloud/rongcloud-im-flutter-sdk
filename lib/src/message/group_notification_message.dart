import 'message_content.dart';
import 'dart:convert' show json;
import 'dart:developer' as developer;

class GroupNotificationMessage extends MessageContent {
  static const String objectName = "RC:GrpNtf";

  /// 创建群
  static const String GROUP_OPERATION_CREATE = 'Create';

  /// 新成员加入群
  static const String GROUP_OPERATION_ADD = "Add";

  /// 解散群。
  static const String GROUP_OPERATION_DISMISS = "Dismiss";

  /// 成员退出群。
  static const String GROUP_OPERATION_QUIT = "Quit";

  /// 成员被管理员踢出。
  static const String GROUP_OPERATION_KICKED = "Kicked";

  /// 群组重命名。
  static const String GROUP_OPERATION_RENAME = "Rename";

  /// 群组公告变更。
  static const String GROUP_OPERATION_BULLETIN = "Bulletin";

  /// 操作人 UserId，可以为空;
  String operatorUserId;

  /// 操作名，对应 GroupOperationXxxx，或任意字符串。
  String operation;

  /// 被操做人 UserId 或者操作数据（如改名后的名称）。
  String data;

  ///操作信息，可以为空，如：你被 xxx 踢出了群。
  String message;

  /// 附加信息。
  String extra;

  @override
  String encode() {
    Map map = {
      "operatorUserId": this.operation,
      "operation": this.operation,
    };
    if (data != null && data.isNotEmpty) {
      map["data"] = data;
    }
    if (message != null && message.isNotEmpty) {
      map["message"] = message;
    }
    if (extra != null && extra.isNotEmpty) {
      map["extra"] = extra;
    }
    if (this.sendUserInfo != null) {
      Map userMap = super.encodeUserInfo(this.sendUserInfo);
      map["user"] = userMap;
    } else {
      map["user"] = {};
    }
    if (this.mentionedInfo != null) {
      Map mentionedMap = super.encodeMentionedInfo(this.mentionedInfo);
      map["mentionedInfo"] = mentionedMap;
    }
    return json.encode(map);
  }

  @override
  String conversationDigest() {
    return '[群组通知]';
  }

  @override
  void decode(String jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) {
      developer.log("Flutter GroupNotificationMessage deocde error: no content",
          name: "RongIMClient.GroupNotificationMessage");
      return;
    }
    Map map = json.decode(jsonStr.toString());
    this.operatorUserId = map["operatorUserId"];
    this.operation = map["operation"];
    this.data = map["data"];
    this.message = map["message"];
    this.extra = map["extra"];
    Map userMap = map["user"];
    super.decodeUserInfo(userMap);
    Map menthionedMap = map["mentionedInfo"];
    super.decodeMentionedInfo(menthionedMap);
  }

  @override
  String getObjectName() {
    return objectName;
  }
}
