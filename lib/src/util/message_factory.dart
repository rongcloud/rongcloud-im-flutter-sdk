import 'dart:convert' show json;
import 'dart:core';
import 'dart:developer' as developer;

import 'package:rongcloud_im_plugin/src/info/tag_info.dart';

import '../../rongcloud_im_plugin.dart';
import '../util/type_util.dart';

class MessageFactory extends Object {
  factory MessageFactory() => _getInstance()!;

  static MessageFactory? get instance => _getInstance();
  static MessageFactory? _instance;

  MessageFactory._internal() {
    // 初始化
  }

  static MessageFactory? _getInstance() {
    if (_instance == null) {
      _instance = new MessageFactory._internal();
    }
    return _instance;
  }

  ConversationTagInfo? string2ConversationTagInfo(String tagInfoJsonStr) {
    if (TypeUtil.isEmptyString(tagInfoJsonStr)) {
      return null;
    }
    Map map = json.decode(tagInfoJsonStr);
    return map2ConversationTagInfo(map);
  }

  ConversationTagInfo map2ConversationTagInfo(Map map) {
    ConversationTagInfo conversationTagInfo = new ConversationTagInfo();
    conversationTagInfo.isTop = map["isTop"];
    String? jsonTagStr = map["tagInfo"];
    conversationTagInfo.tagInfo = string2TagInfo(jsonTagStr);
    return conversationTagInfo;
  }

  TagInfo? string2TagInfo(String? tagJsonStr) {
    if (TypeUtil.isEmptyString(tagJsonStr)) {
      return null;
    }
    Map map = json.decode(tagJsonStr!);
    return map2TagInfo(map);
  }

  TagInfo map2TagInfo(Map map) {
    TagInfo tagInfo = new TagInfo();
    tagInfo.tagId = map["tagId"];
    tagInfo.tagName = map["tagName"];
    tagInfo.count = map["count"];
    tagInfo.timestamp = map["timestamp"];
    return tagInfo;
  }

  Message? string2Message(String? msgJsonStr) {
    if (TypeUtil.isEmptyString(msgJsonStr)) {
      return null;
    }
    Map map = json.decode(msgJsonStr!);
    return map2Message(map);
  }

  Conversation? string2Conversation(String? conJsonStr) {
    if (TypeUtil.isEmptyString(conJsonStr)) {
      return null;
    }
    Map map = json.decode(conJsonStr!);
    return map2Conversation(map);
  }

  ChatRoomInfo map2ChatRoomInfo(Map map) {
    ChatRoomInfo chatRoomInfo = new ChatRoomInfo();
    chatRoomInfo.targetId = map["targetId"];
    chatRoomInfo.memberOrder = map["memberOrder"];
    chatRoomInfo.totalMemeberCount = map["totalMemeberCount"];
    List memList = [];
    for (Map memMap in map["memberInfoList"]) {
      memList.add(map2ChatRoomMemberInfo(memMap));
    }
    chatRoomInfo.memberInfoList = memList;
    return chatRoomInfo;
  }

  ChatRoomMemberInfo map2ChatRoomMemberInfo(Map map) {
    ChatRoomMemberInfo chatRoomMemberInfo = new ChatRoomMemberInfo();
    chatRoomMemberInfo.userId = map["userId"];
    chatRoomMemberInfo.joinTime = map["joinTime"];
    return chatRoomMemberInfo;
  }

  Message map2Message(Map map) {
    Message message = new Message();
    message.conversationType = map["conversationType"];
    message.targetId = map["targetId"];
    message.messageId = map["messageId"];
    message.messageDirection = map["messageDirection"];
    message.senderUserId = map["senderUserId"];
    message.receivedStatus = map["receivedStatus"];
    message.sentStatus = map["sentStatus"];
    message.sentTime = map["sentTime"];
    message.objectName = map["objectName"];
    message.messageUId = map["messageUId"];
    message.extra = map["extra"];
    message.canIncludeExpansion = map["canIncludeExpansion"];
    message.expansionDic = map["expansionDic"];
    Map? messageConfigMap = map["messageConfig"];
    if (messageConfigMap != null) {
      MessageConfig messageConfig = MessageConfig();
      messageConfig.disableNotification = messageConfigMap["disableNotification"];
      message.messageConfig = messageConfig;
    }
    Map? messagePushConfigMap = map["messagePushConfig"];
    if (messagePushConfigMap != null) {
      message.messagePushConfig = MessagePushConfig();
      message.messagePushConfig!.pushTitle = messagePushConfigMap["pushTitle"];
      message.messagePushConfig!.pushContent = messagePushConfigMap["pushContent"];
      message.messagePushConfig!.pushData = messagePushConfigMap["pushData"];
      message.messagePushConfig!.forceShowDetailContent = messagePushConfigMap["forceShowDetailContent"];
      Map? androidConfigMap = messagePushConfigMap["androidConfig"];
      if (androidConfigMap != null) {
        AndroidConfig androidConfig = AndroidConfig();
        androidConfig.notificationId = androidConfigMap["notificationId"];
        androidConfig.channelIdMi = androidConfigMap["channelIdMi"];
        androidConfig.channelIdHW = androidConfigMap["channelIdHW"];
        androidConfig.channelIdOPPO = androidConfigMap["channelIdOPPO"];
        androidConfig.typeVivo = androidConfigMap["typeVivo"];
        message.messagePushConfig!.androidConfig = androidConfig;
      }
      Map? iOSConfigMap = messagePushConfigMap["iOSConfig"];
      if (iOSConfigMap != null) {
        IOSConfig iosConfig = IOSConfig();
        iosConfig.thread_id = iOSConfigMap["thread_id"];
        iosConfig.apns_collapse_id = iOSConfigMap["apns_collapse_id"];
        message.messagePushConfig!.iOSConfig = iosConfig;
      }
      message.messagePushConfig!.disablePushTitle = messagePushConfigMap["disablePushTitle"];
      message.messagePushConfig!.templateId = messagePushConfigMap["templateId"];
    }
    Map? readReceiptMap = map["readReceiptInfo"];
    if (readReceiptMap != null) {
      ReadReceiptInfo readReceiptInfo = ReadReceiptInfo();
      readReceiptInfo.isReceiptRequestMessage = readReceiptMap["isReceiptRequestMessage"];
      readReceiptInfo.hasRespond = readReceiptMap["hasRespond"];
      readReceiptInfo.userIdList = readReceiptMap["userIdList"];
      message.readReceiptInfo = readReceiptInfo;
    }
    String? contenStr = map["content"];
    MessageContent? content = string2MessageContent(contenStr, message.objectName);
    if (contenStr == null || contenStr == "") {
      developer.log(message.objectName! + ":该消息内容为空，可能该消息没有在原生 SDK 中注册", name: "RongIMClient.MessageFactory");
      return message;
    }
    if (content != null) {
      message.content = content;
    } else {
      developer.log("${message.objectName}:该消息不能被解析!消息内容被保存在 Message.originContentMap 中",
          name: "RongIMClient.MessageFactory");
      Map? map = json.decode(contenStr.toString());
      message.originContentMap = map;
    }
    return message;
  }

  Conversation map2Conversation(Map map) {
    Conversation con = new Conversation();
    con.conversationType = map["conversationType"];
    con.targetId = map["targetId"];
    con.channelId = map["channelId"];
    con.unreadMessageCount = map["unreadMessageCount"];
    con.receivedStatus = map["receivedStatus"];
    con.sentStatus = map["sentStatus"];
    con.sentTime = map["sentTime"];
    con.isTop = map["isTop"];
    con.objectName = map["objectName"];
    con.senderUserId = map["senderUserId"];
    con.latestMessageId = map["latestMessageId"];
    con.mentionedCount = map["mentionedCount"];
    con.draft = map["draft"];
    con.blockStatus = map["blockStatus"];
    con.receivedTime = map["receivedTime"];

    String? contenStr = map["content"];
    MessageContent? content = string2MessageContent(contenStr, con.objectName);
    if (content != null) {
      con.latestMessageContent = content;
    } else {
      if (contenStr == null || contenStr.length <= 0) {
        developer.log("该会话没有消息 type:" + con.conversationType.toString() + " targetId:" + con.targetId!,
            name: "RongIMClient.MessageFactory");
      } else {
        developer.log(con.objectName! + ":该消息不能被解析!消息内容被保存在 Conversation.originContentMap 中",
            name: "RongIMClient.MessageFactory");
        Map? map = json.decode(contenStr.toString());
        con.originContentMap = map;
      }
    }
    return con;
  }

  MessageContent? string2MessageContent(String? contentS, String? objectName) {
    MessageContent? content;
    if (RongIMClient.messageDecoders.isNotEmpty && RongIMClient.messageDecoders.containsKey(objectName)) {
      return RongIMClient.messageDecoders[objectName!]!(contentS);
    }
    return content;
  }

  Map conversationIdentifier2Map(ConversationIdentifier? identifier) {
    Map map = new Map();
    if (identifier == null) {
      return map;
    }
    map["conversationType"] = identifier.conversationType;
    map["targetId"] = identifier.targetId;
    return map;
  }

  Map messageContent2Map(MessageContent content) {
    Map map = new Map();
    return map;
  }

  Map message2Map(Message message) {
    Map map = new Map();
    map["conversationType"] = message.conversationType;
    map["targetId"] = message.targetId ?? "";
    map["messageId"] = message.messageId;
    map["messageDirection"] = message.messageDirection;
    map["senderUserId"] = message.senderUserId ?? "";
    map["receivedStatus"] = message.receivedStatus;
    map["sentStatus"] = message.sentStatus;
    map["sentTime"] = message.sentTime ?? 0;
    map["objectName"] = message.objectName ?? "";
    map["messageUId"] = message.messageUId ?? "";
    if (message.content != null) {
      map["content"] = message.content!.encode();
    }
    map["extra"] = message.extra ?? "";
    map["canIncludeExpansion"] = message.canIncludeExpansion ?? false;
    map["expansionDic"] = message.expansionDic;
    if (message.messageConfig != null) {
      Map messageConfig = Map();
      messageConfig["disableNotification"] = message.messageConfig!.disableNotification ?? false;
      map["messageConfig"] = messageConfig;
    }
    if (message.messagePushConfig != null) {
      Map messagePushConfig = Map();
      messagePushConfig["pushTitle"] = message.messagePushConfig!.pushTitle ?? "";
      messagePushConfig["pushContent"] = message.messagePushConfig!.pushContent ?? "";
      messagePushConfig["pushData"] = message.messagePushConfig!.pushData ?? "";
      messagePushConfig["forceShowDetailContent"] = message.messagePushConfig!.forceShowDetailContent ?? false;
      messagePushConfig["disablePushTitle"] = message.messagePushConfig!.disablePushTitle ?? false;
      messagePushConfig["templateId"] = message.messagePushConfig!.templateId ?? "";
      if (message.messagePushConfig!.androidConfig != null) {
        Map androidConfig = Map();
        androidConfig["notificationId"] = message.messagePushConfig!.androidConfig!.notificationId ?? "";
        androidConfig["channelIdMi"] = message.messagePushConfig!.androidConfig!.channelIdMi ?? "";
        androidConfig["channelIdHW"] = message.messagePushConfig!.androidConfig!.channelIdHW ?? "";
        androidConfig["channelIdOPPO"] = message.messagePushConfig!.androidConfig!.channelIdOPPO ?? "";
        androidConfig["typeVivo"] = message.messagePushConfig!.androidConfig!.typeVivo ?? "";
        messagePushConfig["androidConfig"] = androidConfig;
      }
      if (message.messagePushConfig!.iOSConfig != null) {
        Map iOSConfig = Map();
        iOSConfig["thread_id"] = message.messagePushConfig!.iOSConfig!.thread_id ?? "";
        iOSConfig["apns_collapse_id"] = message.messagePushConfig!.iOSConfig!.apns_collapse_id ?? "";
        messagePushConfig["iOSConfig"] = iOSConfig;
      }
      map["messagePushConfig"] = messagePushConfig;
    }
    if (message.readReceiptInfo != null) {
      Map readReceiptMap = Map();
      readReceiptMap["isReceiptRequestMessage"] = message.readReceiptInfo!.isReceiptRequestMessage;
      readReceiptMap["hasRespond"] = message.readReceiptInfo!.hasRespond;
      readReceiptMap["userIdList"] = message.readReceiptInfo!.userIdList;
      map["readReceiptInfo"] = readReceiptMap;
    }

    return map;
  }

  TypingStatus? string2TypingStatus(String statusJsonStr) {
    if (TypeUtil.isEmptyString(statusJsonStr)) {
      return null;
    }
    Map map = json.decode(statusJsonStr);
    return map2TypingStatus(map);
  }

  TypingStatus map2TypingStatus(Map map) {
    TypingStatus status = new TypingStatus();
    status.userId = map["userId"];
    status.typingContentType = map["typingContentType"];
    status.sentTime = map["sentTime"];
    return status;
  }

  SearchConversationResult? string2SearchConversationResult(String resultStr) {
    if (TypeUtil.isEmptyString(resultStr)) {
      return null;
    }
    Map map = json.decode(resultStr);
    return map2SearchConversationResult(map);
  }

  SearchConversationResult map2SearchConversationResult(Map map) {
    SearchConversationResult result = new SearchConversationResult();
    result.mConversation = string2Conversation(map["mConversation"]);
    result.mMatchCount = map["mMatchCount"];
    return result;
  }

  Map pushConfig2Map(PushConfig pushConfig) {
    Map map = new Map();
    map["enableHWPush"] = pushConfig.enableHWPush;
    map["enableFCM"] = pushConfig.enableFCM;
    map["enableVivoPush"] = pushConfig.enableVivoPush;
    map["miAppId"] = pushConfig.miAppId;
    map["miAppKey"] = pushConfig.miAppKey;
    map["mzAppId"] = pushConfig.mzAppId;
    map["mzAppKey"] = pushConfig.mzAppKey;
    map["oppoAppKey"] = pushConfig.oppoAppKey;
    map["oppoAppSecret"] = pushConfig.oppoAppSecret;
    return map;
  }
}
