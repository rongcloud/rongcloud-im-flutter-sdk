package com.example.rongcloud_im_plugin_example;

import android.content.Context;
import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.rong.imkit.RongIM;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    Context con = getApplicationContext();
    //Android 注册自定义消息必须在 init 之后
    //如果注册了自定义消息，但是没有注册消息模板，无法进入 SDK 的聊天页面
    //https://www.rongcloud.cn/docs/android.html 参见文档的"消息自定义"
    RongIM.init(con,"pvxdm17jxjaor");
    RongIM.registerMessageType(TestMessage.class);
  }
}
