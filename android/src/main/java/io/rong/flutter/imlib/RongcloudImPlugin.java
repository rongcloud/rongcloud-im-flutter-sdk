package io.rong.flutter.imlib;

import android.util.Log;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;

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
    RCIMFlutterWrapper.getInstance().saveContext(registrar.activity().getApplicationContext());
    RCIMFlutterWrapper.getInstance().saveChannel(channel);
  }

  // @Override
  // public void onMethodCall(MethodCall call, Result result) {
    // RCIMFlutterWrapper.getInstance().onFlutterMethodCall(call,result);
  // }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      Log.e("onMethodCall", call.method);
      result.success("Android " + android.os.Build.VERSION.RELEASE);
      Map<String, String> map = new HashMap<>();
      map.put("message", "message");
      // channel.invokeMethod("onMessageTest", map);
      RCIMFlutterWrapper.getInstance().onFlutterMethodCall(call,result);
    } else {
      result.notImplemented();
    }
  }

}
