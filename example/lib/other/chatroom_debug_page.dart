import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../im/util/code_util.dart';
import '../im/util/dialog_util.dart';

class ChatRoomDebugPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChatRoomDebugPageState();
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
      Fluttertoast.showToast(
          msg: "加入聊天室 $targetId " + (status == 0 ? "成功" : "失败"),
          timeInSecForIos: 2);
    };

    RongcloudImPlugin.onQuitChatRoom = (String targetId, int status) {
      Fluttertoast.showToast(
          msg: "退出聊天室 $targetId " + (status == 0 ? "成功" : "失败"),
          timeInSecForIos: 2);
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
    RongcloudImPlugin.setChatRoomEntry(
        targetId, "key1", "value1", true, true, "notificationExtra",
        (int code) {
      DialogUtil.showAlertDiaLog(context,
          "设置 KV：{key1: value1}, 发送通知，退出时删除，code：" + CodeUtil.codeString(code));
    });
  }

  void _forceSetEntry() {
    RongcloudImPlugin.forceSetChatRoomEntry(
        targetId, "key2", "value2", false, false, "notificationExtra",
        (int code) {
      DialogUtil.showAlertDiaLog(
          context,
          "强制删除 KV：{key2: value2}, 不发送通知，退出时不删除，code：" +
              CodeUtil.codeString(code));
    });
  }

  void _removeEntry() {
    RongcloudImPlugin.removeChatRoomEntry(
        targetId, "key1", true, "notificationExtra", (int code) {
      DialogUtil.showAlertDiaLog(
          context, "删除 KV：key1, 发送通知，code：" + CodeUtil.codeString(code));
    });
  }

  void _forceRemoveEntry() {
    RongcloudImPlugin.forceRemoveChatRoomEntry(
        targetId, "key2", false, "notificationExtra", (int code) {
      DialogUtil.showAlertDiaLog(
          context, "强制删除 KV：key2, 不发送通知，code：" + CodeUtil.codeString(code));
    });
  }

  void _getEntry() {
    RongcloudImPlugin.getChatRoomEntry(targetId, "key1", (Map entry, int code) {
      DialogUtil.showAlertDiaLog(context,
          "获取单个 KV：key1, code：" + CodeUtil.codeString(code) + "，entry：$entry");
    });
  }

  void _getAllEntry() {
    RongcloudImPlugin.getAllChatRoomEntries(targetId, (Map entry, int code) {
      DialogUtil.showAlertDiaLog(context,
          "获取所有 KV：code：" + CodeUtil.codeString(code) + "，entry：$entry");
    });
  }

  void _quitChatRoom() {
    RongcloudImPlugin.quitChatRoom(targetId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ChatRoom Debug"),
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
