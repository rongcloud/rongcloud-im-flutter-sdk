package io.rong.flutter.imlib;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** RongcloudImPlugin */
public class RongcloudImPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {
  private static final String CHANNEL_NAME = "rongcloud_im_plugin";

  private static MethodChannel channel;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
    channel.setMethodCallHandler(new RongcloudImPlugin());
    RCIMFlutterWrapper.getInstance().saveContext(registrar.activity().getApplicationContext());
    RCIMFlutterWrapper.getInstance().saveChannel(channel);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    RCIMFlutterWrapper.getInstance().onFlutterMethodCall(call,result);
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    channel.setMethodCallHandler(new RongcloudImPlugin());
    RCIMFlutterWrapper.getInstance().saveContext(binding.getApplicationContext());
    RCIMFlutterWrapper.getInstance().saveChannel(channel);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    channel = null;
  }
}
