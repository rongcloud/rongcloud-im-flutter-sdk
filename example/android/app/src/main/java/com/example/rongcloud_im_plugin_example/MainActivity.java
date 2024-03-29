package com.example.rongcloud_im_plugin_example;

import android.os.Bundle;

import androidx.annotation.Nullable;

import com.example.rongcloud_im_plugin_example.message.LocationMessage;

import io.flutter.embedding.android.FlutterActivity;
import io.rong.flutter.imlib.RCIMFlutterWrapper;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        RCIMFlutterWrapper.getInstance().registerMessage(LocationMessage.class);
    }

    //    @Override
//    protected void onCreate(Bundle savedInstanceState) {
//        super.onCreate(savedInstanceState);
//        GeneratedPluginRegistrant.registerWith(this);
//        Context con = getApplicationContext();
//        RCIMFlutterWrapper.getInstance().registerMessage(LocationMessage.class);
//        //Android 注册自定义消息必须在 init 之后
//        //如果注册了自定义消息，但是没有注册消息模板，无法进入 SDK 的聊天页面
//        //https://www.rongcloud.cn/docs/android.html 参见文档的"消息自定义"
////    RongIMClient.init(con,"pvxdm17jxjaor");
////    RCIMFlutterWrapper.getInstance().registerMessage(TestMessage.class);
//
//        // 测试Android往Flutter传递数据
////    Timer timer = new Timer();
////    timer.schedule(new TimerTask() {
////      public void run() {
////        Map map = new HashMap();
////        map.put("key","android");
////        RCIMFlutterWrapper.getInstance().sendDataToFlutter(map);
////      }
////    },500);
//    }
//
//    @Override
//    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
//        GeneratedPluginRegistrant.registerWith(flutterEngine);
//    }
}