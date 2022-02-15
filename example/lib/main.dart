import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart' as prefix;
import 'package:rongcloud_im_plugin_example/test_message.dart';

import 'im/util/event_bus.dart';
import 'location_message.dart';
import 'other/home_page.dart';
import 'router.dart';
import 'user_data.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

  static BuildContext? getContext() {
    return _MyAppState.getContext();
  }
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  String pageName = "example.main";
  AppLifecycleState currentState = AppLifecycleState.resumed;
  DateTime? notificationQuietEndTime;
  DateTime? notificationQuietStartTime;
  static BuildContext? appContext;

  bool _ready = false;

  static BuildContext? getContext() {
    return appContext;
  }

  @override
  void initState() {
    super.initState();

    if (NaviServer.length > 0 || FileServer.length > 0) {
      prefix.RongIMClient.setServerInfo(NaviServer, FileServer);
    }
    if (Platform.isAndroid) {
      // android 推送配置
      prefix.PushConfig pushConfig = prefix.PushConfig();
      // pushConfig.enableHWPush = true;
      // pushConfig.enableVivoPush = true;

      // 小米推送，请填入自己申请的 appkey 和 id
      // pushConfig.miAppKey = "1111147338625";
      // pushConfig.miAppId = "2222203761517473625";

      // oppo 推送，请填入自己申请的 appkey 和 secret
      // pushConfig.oppoAppKey = "11111146d261446dbd3c94bb04d322de";
      // pushConfig.oppoAppSecret = "2222223d5ce1414ea4b6d75c880a3031";

      //魅族推送 请填入自己申请的 appkey 和 id
      // pushConfig.mzAppKey = "11111802ac4bd5843d694517307896";
      // pushConfig.mzAppId = "222288";
      // pushConfig.enableFCM = true;
      prefix.RongIMClient.setAndroidPushConfig(pushConfig).then((value) {
        _init();
      });
    } else {
      _init();
    }
  }

  void _init() {
    //1.初始化 im SDK
    prefix.RongIMClient.init(RongAppKey);

    //注册自定义消息
    _registerCustomMessage();

    // _initUserInfoCache();

    WidgetsBinding.instance!.addObserver(this);

    EventBus.instance!.addListener(EventKeys.UpdateNotificationQuietStatus, widget, (map) {
      _getNotificationQuietHours();
    });

    prefix.RongIMClient.onMessageReceivedWrapper = (prefix.Message? msg, int? left, bool? hasPackage, bool? offline) {
      String hasP = hasPackage! ? "true" : "false";
      String off = offline! ? "true" : "false";
      if (msg!.content != null) {
        developer.log("object onMessageReceivedWrapper objName:" + msg.content!.getObjectName()! + " msgContent:" + msg.content!.encode()! + " left:" + left.toString() + " hasPackage:" + hasP + " offline:" + off, name: pageName);
      } else {
        developer.log("object onMessageReceivedWrapper objName: ${msg.objectName} content is null left:${left.toString()} hasPackage:$hasP offline:$off", name: pageName);
      }
      if (currentState == AppLifecycleState.paused && !checkNoficationQuietStatus()) {
        EventBus.instance!.commit(EventKeys.ReceiveMessage, {"message": msg, "left": left, "hasPackage": hasPackage});
        prefix.RongIMClient.getConversationNotificationStatus(msg.conversationType!, msg.targetId!, (int? status, int? code) {
          if (status == 1) {
            _postLocalNotification(msg, left);
          }
        });
      } else {
        //通知其他页面收到消息
        EventBus.instance!.commit(EventKeys.ReceiveMessage, {"message": msg, "left": left, "hasPackage": hasPackage});
      }
    };

    prefix.RongIMClient.onDataReceived = (Map? map) {
      developer.log("object onDataReceived " + map.toString(), name: pageName);
    };

    prefix.RongIMClient.onMessageReceiptRequest = (Map? map) {
      EventBus.instance!.commit(EventKeys.ReceiveReceiptRequest, map);
      developer.log("object onMessageReceiptRequest " + map.toString(), name: pageName);
    };

    prefix.RongIMClient.onMessageReceiptResponse = (Map? map) {
      EventBus.instance!.commit(EventKeys.ReceiveReceiptResponse, map);
      developer.log("object onMessageReceiptResponse " + map.toString(), name: pageName);
    };

    prefix.RongIMClient.onReceiveReadReceipt = (Map? map) {
      EventBus.instance!.commit(EventKeys.ReceiveReadReceipt, map);
      developer.log("object onReceiveReadReceipt " + map.toString(), name: pageName);
    };

    prefix.RongIMClient.onMessageBlocked = (info) {
      EventBus.instance!.commit(EventKeys.BlockMessage, info);
      developer.log("object onReceiveReadReceipt " + info.toString(), name: pageName);
    };

    prefix.RongIMClient.onUltraGroupTypingStatusChanged = (List<prefix.RCUltraGroupTypingStatusInfo> infoList) {
      String str = "";
      infoList.forEach((element) {
        if (element.userNumbers > 2) {
          str += "${element.targetId} [${element.channelId}] 正在有 ${element.userNumbers} 人输入";
        } else {
          str += "${element.userId} 正在超级群 ${element.targetId} [${element.channelId}] 输入内容";
        }
      });
      Fluttertoast.showToast(msg: str);
    };

    setState(() {
      _ready = true;
    });
  }

  void _registerCustomMessage() {
    prefix.RongIMClient.addMessageDecoder(TestMessage.objectName, (content) {
      TestMessage msg = new TestMessage();
      msg.decode(content);
      return msg;
    });

    prefix.RongIMClient.addMessageDecoder(LocationMessage.objectName, (content) {
      LocationMessage msg = new LocationMessage();
      msg.decode(content);
      return msg;
    });
  }

  void _getNotificationQuietHours() {
    prefix.RongIMClient.getNotificationQuietHours((int? code, String? startTime, int? spansMin) {
      if (startTime != null && startTime.length > 0 && spansMin! > 0) {
        DateTime now = DateTime.now();
        String nowString = now.year.toString() + "-" + now.month.toString().padLeft(2, '0') + "-" + now.day.toString().padLeft(2, '0') + " " + startTime;
        DateTime start = DateTime.parse(nowString);
        notificationQuietStartTime = start;
        notificationQuietEndTime = start.add(Duration(minutes: spansMin));
      } else {
        notificationQuietStartTime = null;
        notificationQuietEndTime = null;
      }
    });
  }

  bool checkNoficationQuietStatus() {
    bool isNotificationQuiet = false;

    DateTime now = DateTime.now();
    if (notificationQuietStartTime != null && notificationQuietEndTime != null && now.isAfter(notificationQuietStartTime!) && now.isBefore(notificationQuietEndTime!)) {
      isNotificationQuiet = true;
    }

    return isNotificationQuiet;
  }

  void _postLocalNotification(prefix.Message? msg, int? left) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = new AndroidInitializationSettings("app_icon"); // app_icon 所在目录为 res/drawable/
    var initializationSettingsIOS = new IOSInitializationSettings(requestAlertPermission: true, requestSoundPermission: true);
    var initializationSettings = new InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: null);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails('your channel id', 'your channel name', 'your channel description', importance: Importance.max, priority: Priority.high, ticker: '本地通知');

    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: null);

    String content = "测试本地通知";

    await flutterLocalNotificationsPlugin.show(0, 'RongCloud IM', content, platformChannelSpecifics, payload: 'item x');
  }

  @override
  Widget build(BuildContext context) {
    appContext = context;
    return MaterialApp(
      onGenerateRoute: onGenerateRoute,
      theme: ThemeData(primaryColor: Colors.blue),
      home: _ready ? HomePage() : _loading(context),
    );
  }

  Widget _loading(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    developer.log("--" + state.toString(), name: pageName);
    currentState = state;
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        break;
      case AppLifecycleState.resumed: // 应用程序可见，前台
        break;
      case AppLifecycleState.paused: // 应用程序不可见，后台
        break;
      case AppLifecycleState.detached: // 申请将暂时暂停
        break;
    }
  }
}
