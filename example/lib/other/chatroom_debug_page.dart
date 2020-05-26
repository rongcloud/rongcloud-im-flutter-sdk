import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../im/util/code_util.dart';
import '../im/util/dialog_util.dart';
import 'dart:developer' as developer;

class ChatRoomDebugPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChatRoomDebugPageState();
}

class _ChatRoomDebugPageState extends State<ChatRoomDebugPage> {
  String pageName = "example.ChatRoomDebugPage";
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
      "获取聊天室历史消息",
    ];

    RongIMClient.onJoinChatRoom = (String targetId, int status) {
      Fluttertoast.showToast(
          msg: "加入聊天室 $targetId " + (status == 0 ? "成功" : "失败"),
          timeInSecForIos: 2);
    };

    RongIMClient.onQuitChatRoom = (String targetId, int status) {
      Fluttertoast.showToast(
          msg: "退出聊天室 $targetId " + (status == 0 ? "成功" : "失败"),
          timeInSecForIos: 2);
    };
  }

  void _didTap(int index) {
    developer.log("did tap debug " + titles[index], name: pageName);
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
      case 8:
        _getChatRoomHistoryMessage();
        break;
    }
  }

  void _joinChatRoom() {
    RongIMClient.joinChatRoom(targetId, 10);
  }

  void _setEntry() {
    RongIMClient.setChatRoomEntry(
        targetId, "key1", "value1", true, true, "notificationExtra",
        (int code) {
      DialogUtil.showAlertDiaLog(context,
          "设置 KV：{key1: value1}, 发送通知，退出时删除，code：" + CodeUtil.codeString(code));
    });
  }

  void _forceSetEntry() {
    RongIMClient.forceSetChatRoomEntry(
        targetId, "key2", "value2", false, false, "notificationExtra",
        (int code) {
      DialogUtil.showAlertDiaLog(
          context,
          "强制删除 KV：{key2: value2}, 不发送通知，退出时不删除，code：" +
              CodeUtil.codeString(code));
    });
  }

  void _removeEntry() {
    RongIMClient.removeChatRoomEntry(
        targetId, "key1", true, "notificationExtra", (int code) {
      DialogUtil.showAlertDiaLog(
          context, "删除 KV：key1, 发送通知，code：" + CodeUtil.codeString(code));
    });
  }

  void _forceRemoveEntry() {
    RongIMClient.forceRemoveChatRoomEntry(
        targetId, "key2", false, "notificationExtra", (int code) {
      DialogUtil.showAlertDiaLog(
          context, "强制删除 KV：key2, 不发送通知，code：" + CodeUtil.codeString(code));
    });
  }

  void _getEntry() {
    RongIMClient.getChatRoomEntry(targetId, "key1", (Map entry, int code) {
      DialogUtil.showAlertDiaLog(context,
          "获取单个 KV：key1, code：" + CodeUtil.codeString(code) + "，entry：$entry");
    });
  }

  void _getAllEntry() {
    RongIMClient.getAllChatRoomEntries(targetId, (Map entry, int code) {
      DialogUtil.showAlertDiaLog(context,
          "获取所有 KV：code：" + CodeUtil.codeString(code) + "，entry：$entry");
    });
  }

  void _quitChatRoom() {
    RongIMClient.quitChatRoom(targetId);
  }

  void _getChatRoomHistoryMessage() {
    RongIMClient.getRemoteChatRoomHistoryMessages(
        targetId, 0, 20, RCTimestampOrder.RC_Timestamp_Desc,
        (List/*<Message>*/ msgList, int syncTime, int code) {
      DialogUtil.showAlertDiaLog(
          context,
          "获取聊天室历史消息：code：" +
              CodeUtil.codeString(code) +
              "，msgListCount：${msgList.length} 条消息\n" +
              "，msgList：$msgList" +
              "，syncTime：$syncTime");
    });
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
