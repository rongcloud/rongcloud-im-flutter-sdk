///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 11/18/20 3:53 PM
///
import 'package:flutter/services.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class Channel {
  const Channel._();

  static const String channelName =
      'com.example.rongcloud_im_plugin_example/exampleChannel';

  /// [MethodChannel] instance.
  static const MethodChannel channel = MethodChannel(channelName);

  /// Constant method keys.
  static const String METHOD_REGISTER_CUSTOM_MESSAGES = 'registerCustomMessages';

  /// Register custom messages type.
  /// 注册自定义消息类型
  ///
  /// To ensure that your custom messages can be _send or receive_ normally,
  /// call this method once the [RongIMClient.init] is called.
  /// 为了保证自定义消息类型可以正常的 **发送和接收**，请在 [RongIMClient.init] 被调用
  /// 后立刻调用该方法。
  static void registerCustomMessage() {
    channel.invokeMethod<void>(METHOD_REGISTER_CUSTOM_MESSAGES);
  }
}
