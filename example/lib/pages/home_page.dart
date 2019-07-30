
import 'package:flutter/material.dart';
import 'conversation_list_page.dart';
import 'friend_list_page.dart';
import 'dart:convert' show json;
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../util/user_data.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  
  final List<BottomNavigationBarItem> tabbarList = [
    new BottomNavigationBarItem(icon: new Icon(Icons.chat,color: Colors.grey),title: new Text("会话"),),
    new BottomNavigationBarItem(icon: new Icon(Icons.perm_contact_calendar,color: Colors.grey,),title: new Text("通讯录"),),
  ];
  final List<StatefulWidget> vcList = [new ConversationListPage(),new FriendListPage()];

  int curIndex = 0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  initPlatformState() async {

    //1.初始化 im SDK
    RongcloudImPlugin.init(RongAppKey);

    //2.配置 im SDK
    String confString = await DefaultAssetBundle.of(context).loadString("assets/RCFlutterConf.json");
    Map confMap = json.decode(confString.toString());
    RongcloudImPlugin.config(confMap);

    //3.连接 im SDK
    int rc = await RongcloudImPlugin.connect(RongIMToken);
    print('connect result '+rc.toString());
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 750,height:1334)..init(context);//初始化屏幕分辨率
    return new Scaffold(
      appBar: AppBar(
        title: Text("RongCloud IM"),
      ),
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
      body: vcList[curIndex],
    );
  }
  
}