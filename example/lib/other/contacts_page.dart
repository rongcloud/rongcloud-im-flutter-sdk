import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import '../im/util/user_info_datesource.dart';

class ContactsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _ContactsPageState();
  }
}

class _ContactsPageState extends State<ContactsPage> {
  List<Widget> widgetList = new List();
  List<UserInfo> userList = new List();
  @override
  void initState() {
    super.initState();
    _addFriends();
  }

  _addFriends() {
    List users = _getRandomUserInfos();
    for(UserInfo u in users) {
      this.widgetList.add(getWidget(u));
    }
  }

  List<UserInfo> _getRandomUserInfos() {
    this.userList.add(UserInfoDataSource.getUserInfo("SealTalk"));
    this.userList.add(UserInfoDataSource.getUserInfo("RongRTC"));
    this.userList.add(UserInfoDataSource.getUserInfo("RongIM"));
    return this.userList;
  }

  void _onTapUser(UserInfo user) {
    Map arg = {"coversationType":RCConversationType.Private,"targetId":user.userId};
    Navigator.pushNamed(context, "/conversation",arguments: arg);
  }

  Widget getWidget(UserInfo user) {
    return Container(
            height: 50.0,
            color: Colors.white,
            child:InkWell(
              onTap: () {
                _onTapUser(user);
              },
              child: new ListTile(
                title: new Text(user.name),
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
      body: new ListView(
        children: this.widgetList,
      ),
    );
  }
}
