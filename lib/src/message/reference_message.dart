import 'dart:convert' show json;
import 'dart:developer' as developer;

import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import '../util/message_factory.dart';
import 'message_content.dart';

//Gif消息
class ReferenceMessage extends MessageContent {
  static const String objectName = "RC:ReferenceMsg";

  String? content; //引用文本
  String? referMsgUserId; //被引用消息的发送者 ID
  MessageContent? referMsg; //被引用消息体
  String? extra; //引用消息的附加信息

  @override
  void decode(String? jsonStr) {
    if (jsonStr == null || jsonStr == "") {
      developer.log("Flutter ReferenceMessage deocde error: no content", name: "RongIMClient.ReferenceMessage");
      return;
    }
    Map? map = json.decode(jsonStr);
    if (map == null) {
      developer.log("Flutter ReferenceMessage deocde error: no right content", name: "RongIMClient.ReferenceMessage");
      return;
    }
    this.content = map["content"];
    this.referMsgUserId = map["referMsgUserId"];
    Map? messageMap = map["referMsg"];
    String messageStr = json.encode(messageMap);
    String? objectName = map["objName"];
    this.referMsg = MessageFactory.instance!.string2MessageContent(messageStr, objectName);
    this.extra = map["extra"];
    Map? userMap = map["user"];
    super.decodeUserInfo(userMap);
    Map? menthionedMap = map["mentionedInfo"];
    super.decodeMentionedInfo(menthionedMap);
    this.destructDuration = map["burnDuration"];
  }

  @override
  String encode() {
    Map map = Map();
    if (this.content != null) {
      map["content"] = this.content;
    }
    if (this.referMsgUserId != null) {
      map["referMsgUserId"] = this.referMsgUserId;
    }
    if (messageInfoWithContent() != null) {
      Map? messageMap = messageInfoWithContent();
      map["referMsg"] = messageMap;
    }
    if (this.referMsg?.getObjectName() != null) {
      map["objName"] = this.referMsg!.getObjectName();
    }
    if (this.extra != null) {
      map["extra"] = this.extra;
    }
    if (this.sendUserInfo != null) {
      Map userMap = super.encodeUserInfo(this.sendUserInfo);
      map["user"] = userMap;
    }
    if (this.mentionedInfo != null) {
      Map mentionedMap = super.encodeMentionedInfo(this.mentionedInfo);
      map["mentionedInfo"] = mentionedMap;
    }
    if (this.destructDuration != null && this.destructDuration! > 0) {
      map["burnDuration"] = this.destructDuration;
    }
    return json.encode(map);
  }

  @override
  String? conversationDigest() {
    return this.content;
  }

  @override
  String getObjectName() {
    return objectName;
  }

  Map? messageInfoWithContent() {
    MessageContent? content = this.referMsg;
    Map? map = Map();
    if (content != null) {
      switch (content.getObjectName()) {
        case "RC:TxtMsg":
          TextMessage textMsg = content as TextMessage;
          map = json.decode(textMsg.encode());
          break;
        case "RC:ImgMsg":
          ImageMessage imageMsg = content as ImageMessage;
          map = json.decode(imageMsg.encode());
          break;
        case "RC:FileMsg":
          FileMessage fileMsg = content as FileMessage;
          map = json.decode(fileMsg.encode());
          break;
        case "RC:ImgTextMsg":
          RichContentMessage richContentMsg = content as RichContentMessage;
          map = json.decode(richContentMsg.encode());
          break;
        default:
          return null;
      }
      return map;
    } else {
      return null;
    }
  }
}
