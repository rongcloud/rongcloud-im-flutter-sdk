package com.example.rongcloud_im_plugin_example;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.ArrayList;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.rong.imlib.AnnotationNotFoundException;
import io.rong.imlib.RongIMClient;
import io.rong.imlib.model.MessageContent;

class ExampleChannel implements FlutterPlugin, MethodChannel.MethodCallHandler {
    public static final String channelName = "com.example.rongcloud_im_plugin_example/exampleChannel";
    private static final String METHOD_REGISTER_CUSTOM_MESSAGES = "registerCustomMessages";

    private @Nullable FlutterPluginBinding flutterPluginBinding;

    public ExampleChannel() {}

    @SuppressWarnings("deprecation")
    public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
        setMethodCallHandler(registrar.messenger());
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        this.flutterPluginBinding = binding;
        setMethodCallHandler(binding.getBinaryMessenger());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        this.flutterPluginBinding = null;
    }

    static void setMethodCallHandler(BinaryMessenger messenger) {
        final MethodChannel channel = new MethodChannel(messenger, channelName);
        channel.setMethodCallHandler(new ExampleChannel());
    }

    @Override
    public void onMethodCall(@NonNull final MethodCall call, @NonNull final MethodChannel.Result result) {
        if (call.method.equals(METHOD_REGISTER_CUSTOM_MESSAGES)) {
            //Android 侧注册自定义消息必须紧跟在 Flutter 侧调用 RongIMClient.init 之后
            //如果注册了自定义消息，但是没有注册消息模板，无法进入 SDK 的聊天页面
            //https://www.rongcloud.cn/docs/android.html 参见文档的"消息自定义"
            try {
                //1. 构造 MessageContent 列表，即可以同时注册多个类型
                final ArrayList<Class<? extends MessageContent>> list = new ArrayList<>();
                //2. 加入自定义消息的类型 class
                list.add(TestMessage.class);
                //3. 注册
                RongIMClient.registerMessageType(list);
                //4. （可选）将成功传递回 Flutter 侧。如果在 Flutter 侧等待了方法（await）则一定要传递。
                result.success(null);
            } catch (AnnotationNotFoundException e) {
                e.printStackTrace();
                result.error(String.valueOf(e.hashCode()), e.getMessage(), e.toString());
            }
        } else {
            result.notImplemented();
        }
    }
}
