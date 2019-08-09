import 'common_define.dart';

class MessageContent
    implements MessageCoding, MessageContentView {
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
