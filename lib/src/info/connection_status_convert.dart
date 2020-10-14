import 'package:flutter/foundation.dart';

import '../common_define.dart';

///网络状态装换
///
///由于 iOS 与 Android 的网络状态码并不完全匹配，所以要在此进行转换
///
///具体可以参见对应平台的枚举： iOS 的 [RCConnectionStatus] 和 Android 的 [ConnectionStatus]
class ConnectionStatusConvert {
  static int convert(int originCode) {
    if (TargetPlatform.android == defaultTargetPlatform) {
      return _convertAndroid(originCode);
    } else if (TargetPlatform.iOS == defaultTargetPlatform) {
      return _convertIOS(originCode);
    }
    return originCode;
  }

  static int _convertIOS(int originCode) {
    if (originCode == 0) {
      return RCConnectionStatus.Connected;
    } else if (originCode == 10) {
      return RCConnectionStatus.Connecting;
    } else if (originCode == 6) {
      return RCConnectionStatus.KickedByOtherClient;
    } else if (originCode == 1) {
      return RCConnectionStatus.NetworkUnavailable;
    } else if (originCode == 31004) {
      return RCConnectionStatus.TokenIncorrect;
    } else if (originCode == 31011) {
      return RCConnectionStatus.UserBlocked;
    } else if (originCode == 12) {
      return RCConnectionStatus.DisConnected;
    } else if (originCode == 13) {
      return RCConnectionStatus.Suspend;
    } else if (originCode == 14) {
      return RCConnectionStatus.Timeout;
    }
    return originCode;
  }

  static int _convertAndroid(int originCode) {
    if (originCode == 0) {
      return RCConnectionStatus.Connected;
    } else if (originCode == 1) {
      return RCConnectionStatus.Connecting;
    } else if (originCode == 2) {
      return RCConnectionStatus.DisConnected;
    } else if (originCode == 3) {
      return RCConnectionStatus.KickedByOtherClient;
    } else if (originCode == -1) {
      return RCConnectionStatus.NetworkUnavailable;
    } else if (originCode == 4) {
      return RCConnectionStatus.TokenIncorrect;
    } else if (originCode == 6) {
      return RCConnectionStatus.UserBlocked;
    } else if (originCode == 13) {
      return RCConnectionStatus.Suspend;
    } else if (originCode == 14) {
      return RCConnectionStatus.Timeout;
    }
    return originCode;
  }
}
