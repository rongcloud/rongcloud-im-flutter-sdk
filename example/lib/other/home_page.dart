import 'package:flutter/material.dart';
import '../im/pages/conversation_list_page.dart';
import 'contacts_page.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import '../user_data.dart';

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
  final List<StatefulWidget> vcList = [new ConversationListPage(),new ContactsPage()];

  int curIndex = 0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  initPlatformState() async {

    //1.初始化 im SDK
    RongcloudImPlugin.init(RongAppKey);

    //2.连接 im SDK
    int rc = await RongcloudImPlugin.connect(RongIMToken);
    print('connect result '+rc.toString());
  }

  @override
  Widget build(BuildContext context) {
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