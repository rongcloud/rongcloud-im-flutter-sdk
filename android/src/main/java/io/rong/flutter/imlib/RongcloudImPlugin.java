package io.rong.flutter.imlib;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** RongcloudImPlugin */
public class RongcloudImPlugin implements FlutterPlugin,MethodCallHandler {

  private MethodChannel channel;

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    RCIMFlutterWrapper.getInstance().onFlutterMethodCall(call,result);
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    channel = new MethodChannel(binding.getBinaryMessenger(),"rongcloud_im_plugin");
    channel.setMethodCallHandler(this);
    RCIMFlutterWrapper.getInstance().saveContext(binding.getApplicationContext());
    RCIMFlutterWrapper.getInstance().saveChannel(channel);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
