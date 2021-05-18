import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart' as prefix;
import 'package:shared_preferences/shared_preferences.dart';

import '../im/util/user_info_datesource.dart' as example;
import 'login_page.dart';

class ContactsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _ContactsPageState();
  }
}

class _ContactsPageState extends State<ContactsPage> {
  List<Widget> widgetList = [];
  List<example.UserInfo> userList = [];
  @override
  void initState() {
    super.initState();
    _addFriends();
  }

  void _addFriends() {
    // List users = await _getRandomUserInfos();
    _getRandomUserInfos().then((users) {
      for (example.UserInfo u in users) {
        this.widgetList.add(getWidget(u));
        _refreshUI();
      }
    });
  }

  void _refreshUI() {
    setState(() {});
  }

  Future<List<example.UserInfo>> _getRandomUserInfos() async {
    this.userList.add(await example.UserInfoDataSource.getUserInfo("SealTalk"));
    this.userList.add(await example.UserInfoDataSource.getUserInfo("RongRTC"));
    this.userList.add(await example.UserInfoDataSource.getUserInfo("RongIM"));
    return this.userList;
  }

  void _onTapUser(example.UserInfo user) {
    Map arg = {
      "coversationType": prefix.RCConversationType.Private,
      "targetId": user.id
    };
    Navigator.pushNamed(context, "/conversation", arguments: arg);
  }

  void _pushToDebug() {
    Navigator.pushNamed(context, "/debug");
  }

  void _logout() async {
    prefix.RongIMClient.disconnect(false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
    Navigator.of(context).pushAndRemoveUntil(
        new MaterialPageRoute(builder: (context) => new LoginPage()),
        (route) => route == null);
  }

  Widget getWidget(example.UserInfo user) {
    return Container(
      height: 50.0,
      color: Colors.white,
      child: InkWell(
        onTap: () {
          _onTapUser(user);
        },
        child: new ListTile(
          title: new Text(user.id),
          leading: Container(
            width: 36,
            height: 36,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CachedNetworkImage(
                fit: BoxFit.fill,
                imageUrl: user.portraitUrl,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("RongCloud IM"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more),
            onPressed: () {
              _pushToDebug();
            },
          ),
          IconButton(
            icon: Icon(Icons.power_settings_new),
            onPressed: () {
              _logout();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widgetList.length,
        itemBuilder: (BuildContext context, int index) {
          return widgetList[index];
        },
      ),
    );
  }
}
