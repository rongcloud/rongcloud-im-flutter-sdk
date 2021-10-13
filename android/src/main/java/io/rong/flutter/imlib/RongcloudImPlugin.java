package io.rong.flutter.imlib;

import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class RongcloudImPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        final MethodChannel channel = new MethodChannel(binding.getBinaryMessenger(), "rongcloud_im_plugin");
        channel.setMethodCallHandler(this);
        RCIMFlutterWrapper.getInstance().saveContext(binding.getApplicationContext());
        RCIMFlutterWrapper.getInstance().saveChannel(channel);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        Log.e("onDetachedFromEngine", "onDetachedFromEngine");
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        RCIMFlutterWrapper.getInstance().onFlutterMethodCall(call, result);
    }
}