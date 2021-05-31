import 'package:flutter/material.dart';
import '../im/util/db_manager.dart';
import '../im/util/user_info_datesource.dart';
import '../im/pages/conversation_list_page.dart';
import 'contacts_page.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../im/util/event_bus.dart';
import 'dart:developer' as developer;

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  String pageName = "example.HomePage";
  final List<BottomNavigationBarItem> tabbarList = [
    new BottomNavigationBarItem(
      icon: new Icon(Icons.chat, color: Colors.grey),
      label: "会话",
    ),
    new BottomNavigationBarItem(
      icon: new Icon(
        Icons.perm_contact_calendar,
        color: Colors.grey,
      ),
      label: "通讯录",
    ),
  ];
  final List<StatefulWidget> vcList = [
    new ConversationListPage(),
    new ContactsPage()
  ];

  int curIndex = 0;

  @override
  void initState() {
    super.initState();
    _initUserInfoCache();
    initPlatformState();
  }

  initPlatformState() async {
    //1.初始化 im SDK
    // RongIMClient.init(RongAppKey);

    //2.连接 im SDK
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.get("token");
    if (token != null && token.length > 0) {
      // int rc = await RongIMClient.connect(token);
      RongIMClient.connect(token, (int code, String userId) {
        developer.log("connect result " + code.toString(), name: pageName);
        EventBus.instance.commit(EventKeys.UpdateNotificationQuietStatus, {});
        if (code == 31004 || code == 12) {
          developer.log("connect result " + code.toString(), name: pageName);
          Navigator.of(context).pushAndRemoveUntil(
              new MaterialPageRoute(builder: (context) => new LoginPage()),
              (route) => route == null);
        } else if (code == 0) {
          developer.log("connect userId" + userId, name: pageName);
          // 连接成功后打开数据库
          // _initUserInfoCache();
        }
      });
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          new MaterialPageRoute(builder: (context) => new LoginPage()),
          (route) => route == null);
    }
  }

  // 初始化用户信息缓存
  void _initUserInfoCache() {
    DbManager.instance.openDb();
    UserInfoCacheListener cacheListener = UserInfoCacheListener();
    cacheListener.getUserInfo = (String userId) {
      return UserInfoDataSource.generateUserInfo(userId);
    };
    cacheListener.getGroupInfo = (String groupId) {
      return UserInfoDataSource.generateGroupInfo(groupId);
    };
    UserInfoDataSource.setCacheListener(cacheListener);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      bottomNavigationBar: new BottomNavigationBar(
        items: tabbarList,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            curIndex = index;
          });
        },
        currentIndex: curIndex,
      ),
      body: IndexedStack(
        index: curIndex,
        children: <Widget>[new ConversationListPage(), new ContactsPage()],
      ),
    );
  }
}
