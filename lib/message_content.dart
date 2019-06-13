import 'status_define.dart';

class MessageContent implements MessageCoding,MessageContentView,MessagePersistentCompatible {
  @override
  void decode(Map map) {
    // TODO: implement decode
  }

  @override
  Map encode() {
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

  static int persistentFlag() {
    return RCMessagePersistentFlag.None;
  }

}

class MessageCoding {
  Map encode() {
    return null;
  }
  void decode(Map map) {

  }
  String getObjectName() {
    return null;
  }
}

class MessageContentView {
  String conversationDigest(){
    return null;
  }
}

class MessagePersistentCompatible {
  static int persistentFlag() {
    return RCMessagePersistentFlag.None;
  }
}