class ChatRoomInfo {
  String targetId;
  int memberOrder; //参考 RCChatRoomMemberOrder
  List memberInfoList;
  int totalMemeberCount;
}

class ChatRoomMemberInfo {
  String userId;
  int joinTime;
}
