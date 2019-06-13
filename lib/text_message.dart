import 'package:rongcloud_im_plugin/status_define.dart';

import 'message_content.dart';

class TextMessage extends MessageContent {
  String content;
  String extra;
  @override
  void decode(Map map) {
    this.content = map["content"];
    this.extra = map["extra"];
  }

  @override
  Map encode() {
    Map map = {"content":content,"extra":extra};
    return map;
  }

  @override
  String conversationDigest() {
    return content;
  }

  @override
  String getObjectName() {
    return "RC:TxtMsg";
  }

  static int persistentFlag() {
    return MessagePersistentFlagIsPersisted | MessagePersistentFlagIsCounted;
  }
}