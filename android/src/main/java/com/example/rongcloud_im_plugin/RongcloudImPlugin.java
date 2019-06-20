package com.example.rongcloud_im_plugin;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** RongcloudImPlugin */
public class RongcloudImPlugin implements MethodCallHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "rongcloud_im_plugin");
    channel.setMethodCallHandler(new RongcloudImPlugin());
    RCIMFlutterWrapper.getInstance().saveContext(registrar.context());
    RCIMFlutterWrapper.getInstance().saveChannel(channel);
    registrar.platformViewRegistry().registerViewFactory("rc_chat_view", new ChatViewFactory(registrar.messenger()));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    RCIMFlutterWrapper.getInstance().onFlutterMethodCall(call,result);
  }
}
