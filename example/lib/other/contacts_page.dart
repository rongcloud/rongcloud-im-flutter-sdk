import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  List<example.GroupInfo> groupList = [];

  @override
  void initState() {
    super.initState();
    _addFriends();
    _addGroups();
  }

  void _addFriends() {
    // List users = await _getRandomUserInfos();
    _getRandomUserInfos().then((users) {
      for (example.UserInfo u in users) {
        this.widgetList.add(_getUserWidget(u));
        _refreshUI();
      }
    });
  }

  void _addGroups() {
    _getRandomGroupInfos().then((groups) {
      for (example.GroupInfo g in groups) {
        this.widgetList.add(_getGroupWidget(g));
        _refreshUI();
      }
    });
  }

  void _refreshUI() {
    if (mounted) setState(() {});
  }

  Future<List<example.UserInfo>> _getRandomUserInfos() async {
    this.userList.add(await example.UserInfoDataSource.getUserInfo("222"));
    this.userList.add(await example.UserInfoDataSource.getUserInfo("333"));
    this.userList.add(await example.UserInfoDataSource.getUserInfo("555"));
    this.userList.add(await example.UserInfoDataSource.getUserInfo("666"));
    this.userList.add(await example.UserInfoDataSource.getUserInfo("Lno_B2cKRKEkbg_gVyk_YU"));
    this.userList.add(await example.UserInfoDataSource.getUserInfo("Z2CvBJNvQp4iPWy2P_VaG4"));
    return this.userList;
  }

  Future<List<example.GroupInfo>> _getRandomGroupInfos() async {
    this.groupList.add(await example.UserInfoDataSource.getGroupInfo("chOjozEWTl4s8eQYZhri0c"));
    this.groupList.add(await example.UserInfoDataSource.getGroupInfo("9EYmQ_QUTEktP9Z8jTWL_c"));
    return this.groupList;
  }

  void _onTapUser(example.UserInfo user) {
    Map arg = {"coversationType": prefix.RCConversationType.Private, "targetId": user.id};
    Navigator.pushNamed(context, "/conversation", arguments: arg);
  }

  void _onTapGroup(example.GroupInfo group) {
    Map arg = {"coversationType": prefix.RCConversationType.Group, "targetId": group.id};
    Navigator.pushNamed(context, "/conversation", arguments: arg);
  }

  void _pushToDebug() {
    Navigator.pushNamed(context, "/debug");
  }

  void _logout() async {
    prefix.RongIMClient.disconnect(false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
    Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (context) => new LoginPage()), (route) => route == null);
  }

  Widget _getUserWidget(example.UserInfo user) {
    return Container(
      height: 50.0,
      color: Colors.white,
      child: InkWell(
        onTap: () {
          _onTapUser(user);
        },
        child: new ListTile(
          title: new Text(user.id!),
          leading: Container(
            width: 36,
            height: 36,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CachedNetworkImage(
                fit: BoxFit.fill,
                imageUrl: user.portraitUrl!,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getGroupWidget(example.GroupInfo group) {
    return Container(
      height: 50.0,
      color: Colors.white,
      child: InkWell(
        onTap: () {
          _onTapGroup(group);
        },
        child: new ListTile(
          title: new Text(group.id!),
          leading: Container(
            width: 36,
            height: 36,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CachedNetworkImage(
                fit: BoxFit.fill,
                imageUrl: group.portraitUrl!,
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
