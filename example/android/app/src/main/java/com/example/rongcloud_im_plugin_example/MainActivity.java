package com.example.rongcloud_im_plugin_example;

import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    //要注册自定义消息类型，请参考 ExampleChannel 通过 MethodChannel 进行交互。
    ExampleChannel.registerWith(this.registrarFor(ExampleChannel.channelName));

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
