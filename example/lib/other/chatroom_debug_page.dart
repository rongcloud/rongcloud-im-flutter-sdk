import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChatRoomDebugPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>
      _ChatRoomDebugPageState();
}

class _ChatRoomDebugPageState extends State<ChatRoomDebugPage> {
  List titles;
  String targetId = "kvchatroom1";

  _ChatRoomDebugPageState();
  @override
  void initState() {
    super.initState();
      titles = [
        "加入聊天室 1",
        "设置 KV",
        "强制设置 KV",
        "删除 KV",
        "强制删除 KV",
        "获取单个 KV",
        "获取所有 KV",
        "退出聊天室 1",
      ];

    RongcloudImPlugin.onJoinChatRoom = (String targetId, int status) {
      Fluttertoast.showToast(msg: "加入聊天室 $targetId " + (status == 0 ? "成功" : "失败"), timeInSecForIos: 2);
    };

    RongcloudImPlugin.onQuitChatRoom = (String targetId, int status) {
      Fluttertoast.showToast(msg: "退出聊天室 $targetId " + (status == 0 ? "成功" : "失败"), timeInSecForIos: 2);
    };
  }

  void _didTap(int index) {
    print("did tap debug " + titles[index]);
    switch (index) {
      case 0:
        _joinChatRoom();
        break;
      case 1:
        _setEntry();
        break;
      case 2:
        _forceSetEntry();
        break;
      case 3:
        _removeEntry();
        break;
      case 4:
        _forceRemoveEntry();
        break;
      case 5:
        _getEntry();
        break;
      case 6:
        _getAllEntry();
        break;
      case 7:
        _quitChatRoom();
        break;
    }
  }

  void _joinChatRoom() {
    RongcloudImPlugin.joinChatRoom(targetId, 10);
  }

  void _setEntry() {
    RongcloudImPlugin.setChatRoomEntry(targetId, "key1", "value1", true, true, "notificationExtra", (int code) {
      Fluttertoast.showToast(msg: "设置 KV：{key1: value1}, 发送通知，退出时删除，code：$code", timeInSecForIos: 2);
    });
  }

  void _forceSetEntry() {
    RongcloudImPlugin.forceSetChatRoomEntry(targetId, "key2", "value2", false, false, "notificationExtra", (int code) {
      Fluttertoast.showToast(msg: "强制删除 KV：{key2: value2}, 不发送通知，退出时不删除，code：$code", timeInSecForIos: 2);
    });
  }

  void _removeEntry() {
    RongcloudImPlugin.removeChatRoomEntry(targetId, "key1", true, "notificationExtra",  (int code) {
      Fluttertoast.showToast(msg: "删除 KV：key1, 发送通知，code：$code", timeInSecForIos: 2);
    });
  }

  void _forceRemoveEntry() {
    RongcloudImPlugin.forceRemoveChatRoomEntry(targetId, "key2", false, "notificationExtra",  (int code) {
      Fluttertoast.showToast(msg: "强制删除 KV：key2, 不发送通知，code：$code", timeInSecForIos: 2);
    });
  }

  void _getEntry() {
    RongcloudImPlugin.getChatRoomEntry(targetId, "key1", (Map entry, int code) {
      Fluttertoast.showToast(msg: "获取单个 KV：key1, code：$code，entry：$entry", timeInSecForIos: 2);
    });
  }

  void _getAllEntry() {
    RongcloudImPlugin.getAllChatRoomEntries(targetId, (Map entry, int code) {
      Fluttertoast.showToast(msg: "获取所有 KV：code：$code，entry：$entry", timeInSecForIos: 3);
    });
  }

  void _quitChatRoom() {
    RongcloudImPlugin.quitChatRoom(targetId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Debug"),
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
