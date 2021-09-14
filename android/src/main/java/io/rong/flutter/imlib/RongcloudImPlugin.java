package io.rong.flutter.imlib;

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

  //// FlutterPlugin 的两个 方法
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    Log.e("onAttachedToEngine", "onAttachedToEngine");
    channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutter_plugin_test_new");
    channel.setMethodCallHandler(new FlutterPluginTestNewPlugin());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    Log.e("onDetachedFromEngine", "onDetachedFromEngine");
  }


  ///activity 生命周期
  @Override
  public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
    Log.e("onAttachedToActivity", "onAttachedToActivity");

  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    Log.e("onDetachedFromActivityForConfigChanges", "onDetachedFromActivityForConfigChanges");

  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
    Log.e("onReattachedToActivityForConfigChanges", "onReattachedToActivityForConfigChanges");
  }

  @Override
  public void onDetachedFromActivity() {
    Log.e("onDetachedFromActivity", "onDetachedFromActivity");
  }

}
