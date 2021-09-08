/// @author Pan ming da
/// @time 2021/9/8 16:28
/// @version 1.0

class BlockedMessageInfo {
  final int conversationType;
  final String targetId;
  final String blockMsgUId;
  final int blockType;
  final String? extra;

  BlockedMessageInfo.fromMap(Map<dynamic, dynamic> map)
      : conversationType = map['conversationType'],
        targetId = map['targetId'],
        blockMsgUId = map['blockMsgUId'],
        blockType = map['blockType'],
        extra = map['extra'];
}
