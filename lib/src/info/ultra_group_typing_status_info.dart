class RCUltraGroupTypingStatusInfo {
  String targetId;
  String channelId;
  String userId;
  int userNumbers;
  int timestamp;
  RCUltraGroupTypingStatus status;

  RCUltraGroupTypingStatusInfo.fromMap(Map statusInfo)
      : targetId = statusInfo["targetId"],
        channelId = statusInfo["channelId"],
        userId = statusInfo["userId"],
        userNumbers = statusInfo["userNumbers"],
        timestamp = statusInfo["timestamp"],
        status = RCUltraGroupTypingStatus.values[statusInfo["status"]];

  RCUltraGroupTypingStatusInfo.create(
    this.targetId,
    this.channelId,
    this.userId,
    this.userNumbers,
    this.timestamp,
    this.status,
  );
}

enum RCUltraGroupTypingStatus { RCUltraGroupTypingStatusText }
