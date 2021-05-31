import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart' as prefix;

import '../im/util/user_info_datesource.dart' as example;

class MessageReadPage extends StatefulWidget {
  final prefix.Message message;
  const MessageReadPage({Key key, this.message}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MessageReadPageState(message);
}

class _MessageReadPageState extends State<MessageReadPage> {
  final prefix.Message message;
  _MessageReadPageState(this.message);

  List<Widget> widgetList = [];
  List<example.UserInfo> userList = [];
  @override
  void initState() {
    super.initState();
    _addFriends();
  }

  _addFriends() async {
    await _getRandomUserInfos();
    for (example.UserInfo u in this.userList) {
      this.widgetList.add(getWidget(u));
    }
    setState(() {});
  }

  Future<void> _getRandomUserInfos() async {
    Map userIdList = message.readReceiptInfo.userIdList;
    if (userIdList != null) {
      for (String key in userIdList.keys) {
        example.UserInfo userInfo =
            example.UserInfoDataSource.cachedUserMap[key];
        if (userInfo == null) {
          userInfo = await example.UserInfoDataSource.getUserInfo(key);
        }
        if (userInfo != null) {
          this.userList.add(userInfo);
        }
      }
      // return this.userList;
    }
  }

  Widget getWidget(example.UserInfo user) {
    return Container(
      height: 50.0,
      color: Colors.white,
      child: InkWell(
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
        title: Text("已读成员列表"),
      ),
      body: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: this.widgetList.length,
        itemBuilder: (BuildContext context, int index) {
          return this.widgetList[index];
        },
      ),
    );
  }
}
