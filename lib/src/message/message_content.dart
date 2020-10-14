import '../common_define.dart';

class MessageContent implements MessageCoding, MessageContentView {
  // 消息内容中携带的发送者的用户信息
  UserInfo sendUserInfo;
  // 消息中的 @ 提醒信息
  MentionedInfo mentionedInfo;
  // 焚烧时间，默认是 0，0 代表该消息非阅后即焚消息。
  int destructDuration = 0;
  @override
  void decode(String jsonStr) {
    // TODO: implement decode
  }

  @override
  String encode() {
    // TODO: implement encode
    return null;
  }

  @override
  String conversationDigest() {
    // TODO: implement conversationDigest
    return null;
  }

  @override
  String getObjectName() {
    return null;
  }

  void decodeUserInfo(Map userMap) {
    if (userMap == null) {
      return;
    }
    UserInfo userInfo = new UserInfo();
    userInfo.userId = userMap["id"];
    userInfo.name = userMap["name"];
    userInfo.portraitUri = userMap["portrait"];
    userInfo.extra = userMap["extra"];
    this.sendUserInfo = userInfo;
  }

  Map encodeUserInfo(UserInfo userInfo) {
    Map userMap = new Map();
    if (userInfo != null) {
      if (userInfo.userId != null) {
        userMap["id"] = userInfo.userId;
      }
      if (userInfo.name != null) {
        userMap["name"] = userInfo.name;
      }
      if (userInfo.portraitUri != null) {
        userMap["portrait"] = userInfo.portraitUri;
      }
      if (userInfo.extra != null) {
        userMap["extra"] = userInfo.extra;
      }
    }
    return userMap;
  }

  void decodeMentionedInfo(Map mentionedMap) {
    if (mentionedMap == null) {
      return;
    }
    MentionedInfo mentionedInfo = new MentionedInfo();
    mentionedInfo.type = mentionedMap["type"];
    if (mentionedInfo.type == RCMentionedType.Users) {
      if (mentionedMap["userIdList"] == null) {
        return;
      }
      List<String> userIdList =
          new List<String>.from(mentionedMap["userIdList"]);
      mentionedInfo.userIdList = userIdList;
    }
    mentionedInfo.mentionedContent = mentionedMap["mentionedContent"];
    this.mentionedInfo = mentionedInfo;
  }

  Map encodeMentionedInfo(MentionedInfo mentionedInfo) {
    Map mentionedMap = new Map();
    if (mentionedInfo != null) {
      if (mentionedInfo.type != null) {
        mentionedMap["type"] = mentionedInfo.type;
      }
      if (mentionedInfo.type == RCMentionedType.Users &&
          mentionedInfo.userIdList != null) {
        mentionedMap["userIdList"] = mentionedInfo.userIdList;
      }
      if (mentionedInfo.mentionedContent != null) {
        mentionedMap["mentionedContent"] = mentionedInfo.mentionedContent;
      }
    }
    return mentionedMap;
  }
}

class MessageCoding {
  String encode() {
    return null;
  }

  void decode(String jsonStr) {}
  String getObjectName() {
    return null;
  }
}

class MessageContentView {
  String conversationDigest() {
    return null;
  }
}

class UserInfo {
  String userId;
  String name;
  String portraitUri;
  String extra;
}

// 消息中的 @ 提醒信息
class MentionedInfo {
  // @ 提醒的类型，参见枚举 [RCMentionedType]
  int /*RCMentionedType*/ type;
  // @ 的用户 ID 列表，如果 type 是 @ 所有人，则可以传 nil
  List<String> userIdList;
  // 包含 @ 提醒的消息，建议用做本地通知和远程推送显示的内容
  String mentionedContent;
}
