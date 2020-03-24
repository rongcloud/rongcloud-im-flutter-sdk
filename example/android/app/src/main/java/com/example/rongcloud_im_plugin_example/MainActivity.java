package com.example.rongcloud_im_plugin_example;

import android.content.Context;
import android.os.Bundle;

import io.rong.flutter.imlib.RCIMFlutterWrapper;

import java.util.HashMap;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.rong.imlib.AnnotationNotFoundException;
import io.rong.imlib.RongIMClient;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    Context con = getApplicationContext();
    //Android 注册自定义消息必须在 init 之后
    //如果注册了自定义消息，但是没有注册消息模板，无法进入 SDK 的聊天页面
    //https://www.rongcloud.cn/docs/android.html 参见文档的"消息自定义"
//    RongIMClient.init(con,"pvxdm17jxjaor");
//    try {
//      RongIMClient.registerMessageType(TestMessage.class);
//    } catch (AnnotationNotFoundException e) {
//      e.printStackTrace();
//    }

    // 测试Android往Flutter传递数据
//    Timer timer = new Timer();
//    timer.schedule(new TimerTask() {
//      public void run() {
//        Map map = new HashMap();
//        map.put("key","android");
//        RCIMFlutterWrapper.getInstance().sendDataToFlutter(map);
//      }
//    },500);


  }
}
