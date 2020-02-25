import 'message_content.dart';
import 'dart:convert' show json;

// 聊天室自定义属性通知消息
// 不要随意构造此类消息发送，调用设置或者删除接口时会自动构建。
class ChatroomKVNotificationMessage extends MessageContent {
  static const String objectName = "RC:chrmKVNotiMsg";

  int type;//聊天室操作的类型
  String key;//聊天室属性名称
  String value;//聊天室属性对应的值
  String extra;//通知消息的自定义字段，最大长度 2 kb

  @override
  void decode(String jsonStr) {
    if(jsonStr == null && jsonStr.isEmpty) {
      print("[RC-Flutter-IM] Flutter ChatroomKVNotificationMessage deocde error: no content");
      return;
    }
    Map map = json.decode(jsonStr.toString());
    this.type = map["type"];
    this.key = map["key"];
    this.value = map["value"];
    this.extra = map["extra"];
    Map userMap = map["user"];
    super.decodeUserInfo(userMap);
  }

  @override
  String encode() {
    Map map = {"type":this.type,"key":this.key,"value":this.value,"extra":this.extra};
    if (this.sendUserInfo != null) {
      Map userMap = super.encodeUserInfo(this.sendUserInfo);
      map["user"] = userMap;
    } else {
      map["user"] = {};
    }
    return json.encode(map);
  }

  @override
  String getObjectName() {
    return objectName;
  }
}