import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart' as prefix ;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'im/util/event_bus.dart';
import 'other/home_page.dart';
import 'router.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  AppLifecycleState currentState = AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addObserver(this);

    prefix.RongcloudImPlugin.onMessageReceivedWrapper = (prefix.Message msg, int left, bool hasPackage, bool offline) {
      String hasP = hasPackage ? "true":"false";
      String off = offline ? "true":"false";
      print("object onMessageReceivedWrapper objName:"+msg.content.getObjectName()+" msgContent:"+msg.content.encode()+" left:"+left.toString()+" hasPackage:"+hasP+" offline:"+off);
      if(currentState == AppLifecycleState.paused) {
        _postLocalNotification(msg,left);
      }else {
        //通知其他页面收到消息
        EventBus.instance.commit(EventKeys.ReceiveMessage, {"message":msg,"left":left,"hasPackage":hasPackage});
      }
    };

    prefix.RongcloudImPlugin.onDataReceived = (Map map) {
      print("object onDataReceived " + map.toString());
    };
  }

  void _postLocalNotification(prefix.Message msg, int left) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
    new AndroidInitializationSettings("app_icon");// app_icon 所在目录为 res/drawable/
    var initializationSettingsIOS = new IOSInitializationSettings(requestAlertPermission: true,requestSoundPermission: true);
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid,initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: null);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'your channel id', 'your channel name', 'your channel description',
    importance: Importance.Max, priority: Priority.High, ticker: '本地通知');


    var platformChannelSpecifics = NotificationDetails(
    androidPlatformChannelSpecifics, null);

    String content = "测试本地通知";

    await flutterLocalNotificationsPlugin.show(
    0, 'RongCloud IM', content, platformChannelSpecifics,
    payload: 'item x');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: onGenerateRoute,
      theme: ThemeData(primaryColor: Colors.blue),
      home: HomePage(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("--" + state.toString());
    currentState = state;
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        break;
      case AppLifecycleState.resumed:// 应用程序可见，前台
        break;
      case AppLifecycleState.paused: // 应用程序不可见，后台
        break;
      case AppLifecycleState.detached: // 申请将暂时暂停
        break;
    }
  }  
}
