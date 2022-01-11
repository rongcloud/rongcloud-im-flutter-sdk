import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import '../im/util/code_util.dart';
import '../im/util/dialog_util.dart';

class ChatRoomDebugPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChatRoomDebugPageState();
}

class _ChatRoomDebugPageState extends State<ChatRoomDebugPage> {
  String pageName = "example.ChatRoomDebugPage";
  late List titles;
  late List<Function> functions;
  String targetId = "kvchatroom9920";

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
      "设置 KV 列表",
      "删除 KV 列表",
      "获取单个 KV",
      "获取所有 KV",
      "退出聊天室 1",
      "获取聊天室历史消息",
      "加入已存在的聊天室 1",
      "聊天室发送消息",
      // "聊天室发送带有敏感词消息",
    ];

    functions = [
      _joinChatRoom,
      _setEntry,
      _forceSetEntry,
      _removeEntry,
      _forceRemoveEntry,
      _setEntries,
      _removeEntries,
      _getEntry,
      _getAllEntry,
      _quitChatRoom,
      _getChatRoomHistoryMessage,
      _joinExistChatRoom,
      _sendChatMessage,
      // _sendXXMessage,
    ];

    RongIMClient.onJoinChatRoom = (String? targetId, int? status) {
      Fluttertoast.showToast(msg: "加入聊天室 $targetId " + (status == 0 ? "成功" : "失败"), timeInSecForIosWeb: 2);
    };

    RongIMClient.onQuitChatRoom = (String? targetId, int? status) {
      Fluttertoast.showToast(msg: "退出聊天室 $targetId " + (status == 0 ? "成功" : "失败"), timeInSecForIosWeb: 2);
    };

    RongIMClient.onChatRoomReset = (String? targetId) {
      Fluttertoast.showToast(msg: "聊天室被重制 $targetId ", timeInSecForIosWeb: 2);
    };

    RongIMClient.onChatRoomDestroyed = (String? targetId, int? type) {
      Fluttertoast.showToast(msg: "聊天室被销毁 $targetId " + (type == 0 ? "开发者主动销毁" : "聊天室长时间不活跃，被系统自动回收"), timeInSecForIosWeb: 2);
    };

    RongIMClient.chatRoomKVDidSync = (String? roomId) {
      DialogUtil.showAlertDiaLog(context, "chatRoomKVDidSync $roomId ");
    };

    RongIMClient.chatRoomKVDidUpdate = (String? roomId, Map? entry) {
      DialogUtil.showAlertDiaLog(context, "chatRoomKVDidUpdate $roomId $entry");
    };

    RongIMClient.chatRoomKVDidRemove = (String? roomId, Map? entry) {
      DialogUtil.showAlertDiaLog(context, "chatRoomKVDidRemove $roomId $entry");
    };
  }

  void _didTap(int index) {
    functions[index].call();
  }

  void _joinChatRoom() {
    RongIMClient.joinChatRoom(targetId, 10);
  }

  void _joinExistChatRoom() {
    RongIMClient.joinExistChatRoom(targetId, 10);
  }

  void _setEntry() {
    RongIMClient.setChatRoomEntry(targetId, "key1", "value1", true, true, "notificationExtra", (int? code) {
      DialogUtil.showAlertDiaLog(context, "设置 KV：{key1: value1}, 发送通知，退出时删除，code：" + CodeUtil.codeString(code)!);
    });
  }

  void _forceSetEntry() {
    RongIMClient.forceSetChatRoomEntry(targetId, "key2", "value2", false, false, "notificationExtra", (int? code) {
      DialogUtil.showAlertDiaLog(context, "强制设置 KV：{key2: value2}, 不发送通知，退出时不删除，code：" + CodeUtil.codeString(code)!);
    });
  }

  void _removeEntry() {
    RongIMClient.removeChatRoomEntry(targetId, "key1", true, "notificationExtra", (int? code) {
      DialogUtil.showAlertDiaLog(context, "删除 KV：key1, 发送通知，code：" + CodeUtil.codeString(code)!);
    });
  }

  void _forceRemoveEntry() {
    RongIMClient.forceRemoveChatRoomEntry(targetId, "key2", false, "notificationExtra", (int? code) {
      DialogUtil.showAlertDiaLog(context, "强制删除 KV：key2, 不发送通知，code：" + CodeUtil.codeString(code)!);
    });
  }

  void _setEntries() {
    Map<String, String> map = {
      "key3": "value3",
      "key4": "value4",
      "key5": "value5",
      "key6": "value6",
      "key7": "value7",
      "key8": "value8",
      "key9": "value9",
      "key10": "value10",
      "key11": "value11",
      "key12": "value12",
    };
    RongIMClient.setChatRoomEntries(
      targetId,
      map,
      true,
      true,
      (code, errors) {
        DialogUtil.showAlertDiaLog(context, "设置 KV：$map, 退出时删除，覆盖，code：" + CodeUtil.codeString(code)!);
      },
    );
  }

  void _removeEntries() {
    List<String> list = [
      "key3",
      "key4",
      "key5",
      "key6",
      "key7",
      "key8",
      "key9",
      "key10",
      "key11",
      "key12",
    ];
    RongIMClient.removeChatRoomEntries(
      targetId,
      list,
      true,
      (code, errors) {
        DialogUtil.showAlertDiaLog(context, "删除 KV：$list, 强制，code：" + CodeUtil.codeString(code)!);
      },
    );
  }

  void _getEntry() {
    RongIMClient.getChatRoomEntry(targetId, "key1", (Map? entry, int? code) {
      DialogUtil.showAlertDiaLog(context, "获取单个 KV：key1, code：" + CodeUtil.codeString(code)! + "，entry：$entry");
    });
  }

  void _getAllEntry() {
    RongIMClient.getAllChatRoomEntries(targetId, (Map? entry, int? code) {
      DialogUtil.showAlertDiaLog(context, "获取所有 KV：code：" + CodeUtil.codeString(code)! + "，entry：$entry");
    });
  }

  void _quitChatRoom() {
    RongIMClient.quitChatRoom(targetId);
  }

  void _sendChatMessage() async {
    TextMessage msg = new TextMessage();
    msg.content = "测试文本消息携带用户信息";
    Message? message = await RongIMClient.sendMessage(RCConversationType.ChatRoom, targetId, msg);
  }

  void _getChatRoomHistoryMessage() {
    RongIMClient.getRemoteChatRoomHistoryMessages(targetId, 0, 20, RCTimestampOrder.RC_Timestamp_Desc, (
      List? /*<Message>*/ msgList,
      int? syncTime,
      int? code,
    ) {
      DialogUtil.showAlertDiaLog(context, "获取聊天室历史消息：code：" + CodeUtil.codeString(code)! + "，msgListCount：${msgList!.length} 条消息\n" + "，msgList：$msgList" + "，syncTime：$syncTime");
    });
  }

  // void _sendXXMessage() async {
  //   TextMessage msg = new TextMessage();
  //   msg.content = "fuck";
  //   Message message = await RongIMClient.sendMessage(RCConversationType.ChatRoom, targetId, msg);
  // }

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
