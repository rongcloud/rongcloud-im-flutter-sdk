import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class DebugPage extends StatelessWidget {
  List titles;
  String blackUserId = "blackUserId";

  DebugPage() {
    titles = ["加入黑名单", "移除黑名单", "查看黑名单状态", "获取黑名单列表"];
  }

  void _didTap(int index) {
    print("did tap debug " + titles[index]);
    switch (index) {
      case 0:
        _addBlackList();
        break;
      case 1:
        _removeBalckList();
        break;
      case 2:
        _getBlackStatus();
        break;
      case 3:
        _getBlackList();
        break;
    }
  }

  void _addBlackList() {
    print("_addBlackList");
    RongcloudImPlugin.addToBlackList(blackUserId, (int code) {
      print("_addBlackList:" + blackUserId + " code:" + code.toString());
    });
  }

  void _removeBalckList() {
    print("_removeBalckList");
    RongcloudImPlugin.removeFromBlackList(blackUserId, (int code) {
      print("_removeBalckList:" + blackUserId + " code:" + code.toString());
    });
  }

  void _getBlackStatus() {
    print("_getBlackStatus");
    RongcloudImPlugin.getBlackListStatus(blackUserId,
        (int blackStatus, int code) {
      if (0 == code) {
        if (RCBlackListStatus.In == blackStatus) {
          print("用户:" + blackUserId + " 在黑名单中");
        } else {
          print("用户:" + blackUserId + " 不在黑名单中");
        }
      } else {
        print("用户:" + blackUserId + " 黑名单状态查询失败" + code.toString());
      }
    });
  }

  void _getBlackList() {
    print("_getBlackList");
    RongcloudImPlugin.getBlackList((List/*<String>*/ userIdList, int code) {
      print("_getBlackList:" + userIdList.toString() + " code:" + code.toString());
      userIdList.forEach((userId) {
        print("userId:"+userId);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Debug"),
      ),
      body: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: titles.length,
        itemBuilder: (BuildContext context, int index) {
          return MaterialButton(
            onPressed: () {
              _didTap(index);
            },
            child: Text(titles[index]),
            color: Colors.blue,
          );
        },
      ),
    );
  }
}
