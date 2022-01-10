package io.rong.flutter.imlib;

import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class RongcloudImPlugin implements FlutterPlugin {

    public static void registerWith(PluginRegistry.Registrar registrar) {
        channel = new MethodChannel(registrar.messenger(), "rongcloud_im_plugin");
        channel.setMethodCallHandler(RCIMFlutterWrapper.getInstance());
        RCIMFlutterWrapper.getInstance().saveContext(registrar.activity().getApplicationContext());
        RCIMFlutterWrapper.getInstance().saveChannel(channel);
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "rongcloud_im_plugin");
        channel.setMethodCallHandler(RCIMFlutterWrapper.getInstance());
        RCIMFlutterWrapper.getInstance().saveContext(binding.getApplicationContext());
        RCIMFlutterWrapper.getInstance().saveChannel(channel);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        Log.e("onDetachedFromEngine", "onDetachedFromEngine");
        channel = null;
    }

    private static MethodChannel channel;
}