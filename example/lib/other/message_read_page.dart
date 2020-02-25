import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart' as prefix;

import '../im/util/user_info_datesource.dart';

class MessageReadPage extends StatefulWidget {
  final prefix.Message message;
  const MessageReadPage({Key key, this.message}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
    _MessageReadPageState(message);
}

class _MessageReadPageState extends State<MessageReadPage> {
  final prefix.Message message;
  _MessageReadPageState(this.message);
  
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
    Map userIdList = message.readReceiptInfo.userIdList;
    if (userIdList != null) {
      for (String key in userIdList.keys) {
      this.userList.add(UserInfoDataSource.getUserInfo(key));
      }
    }
    return this.userList;
  }

  Widget getWidget(UserInfo user) {
    return Container(
            height: 50.0,
            color: Colors.white,
            child:InkWell(
              child: new ListTile(
                title: new Text(user.name + "   " + user.id),
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
        title: Text("已读成员列表"),
      ),
      body: new ListView(
        children: this.widgetList,
      ),
    );
  }
}