import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart' as prefix;

import '../im/util/dialog_util.dart';
import '../im/util/event_bus.dart';

class DebugPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  String pageName = "example.DebugPage";
  List titles = [
    "设置全局屏蔽某个时间段的消息提醒",
    "查询已设置的全局时间段消息提醒屏蔽",
    "删除已设置的全局时间段消息提醒屏蔽",
    "获取特定会话",
    "获取特定方向的消息列表",
    "分页获取会话",
    "消息携带用户信息",
    "聊天室状态存储测试",
    "获取免打扰的会话列表",
    "获取会话 SealTalk 第一条未读消息",
    "获取指定超级群 100 下所有频道的未读数",
    "获取超级群会话类型的所有未读消息数",
    "获取超级群会话类型的@消息未读数",
    "设置会话类型免打扰",
    "查询会话类型免打扰",
  ];

  void _didTap(int index, BuildContext context) {
    developer.log("did tap debug " + titles[index], name: pageName);
    switch (index) {
      case 0:
        _setNotificationQuietHours();
        break;
      case 1:
        _getNotificationQuietHours();
        break;
      case 2:
        _removeNotificationQuietHours();
        break;
      case 3:
        _getCons();
        break;
      case 4:
        _getMessagesByDirection();
        break;
      case 5:
        _getConversationListByPage();
        break;
      case 6:
        _sendMessageAddSendUserInfo();
        break;
      case 7:
        _pushToChatRoomDebug(context);
        break;
      case 8:
        _getBlockedConversationList();
        break;
      case 9:
        _getFirstUnreadMsg();
        break;
      case 10:
        _getUltraGroupUnreadCount();
        break;
      case 11:
        _getUltraGroupAllUnreadCount();
        break;
      case 12:
        _getUltraGroupAllUnreadMentionedCount();
        break;
      case 13:
        _showConversationTypeForSetConversationTypeLevel();
        break;
      case 14:
        _getConversationTypeForNotification();
        break;
    }
  }

  void _showConversationTypeForSetConversationTypeLevel() {
    List<Widget> widgets = [
      ListTile(
        title: Center(
          child: Text(
            "单聊",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        onTap: () async {
          Navigator.pop(context);
          _showLevelForSetConversationTypeLevel(1);
        },
      ),
      ListTile(
        title: Center(
          child: Text(
            "群聊",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        onTap: () async {
          Navigator.pop(context);
          _showLevelForSetConversationTypeLevel(3);
        },
      ),
      ListTile(
        title: Center(
          child: Text(
            "超级群",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        onTap: () async {
          Navigator.pop(context);
          _showLevelForSetConversationTypeLevel(10);
        },
      )
    ];
    _showSheet(widgets);
  }

  void _showLevelForSetConversationTypeLevel(int type) {
    List<Widget> widgets = [
      ListTile(
        title: Center(
          child: Text(
            "全部消息通知",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        onTap: () async {
          Navigator.pop(context);
          _setConversationTypeNotificationLevel(type, -1);
        },
      ),
      ListTile(
        title: Center(
          child: Text(
            "未设置",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        onTap: () async {
          Navigator.pop(context);
          _setConversationTypeNotificationLevel(type, 0);
        },
      ),
      ListTile(
        title: Center(
          child: Text(
            "@成员列表有自己 时通知",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        onTap: () async {
          Navigator.pop(context);
          _setConversationTypeNotificationLevel(type, 1);
        },
      ),
      ListTile(
        title: Center(
          child: Text(
            "不接收消息通知",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        onTap: () async {
          Navigator.pop(context);
          _setConversationTypeNotificationLevel(type, 5);
        },
      ),
      ListTile(
        title: Center(
          child: Text(
            "@ 有自己时通知@所有人不通知",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        onTap: () async {
          Navigator.pop(context);
          _setConversationTypeNotificationLevel(type, 2);
        },
      ),
      ListTile(
        title: Center(
          child: Text(
            "@所有人通知，其他情况都不通知",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        onTap: () async {
          Navigator.pop(context);
          _setConversationTypeNotificationLevel(type, 4);
        },
      )
    ];
    _showSheet(widgets);
  }

  void _setConversationTypeNotificationLevel(int type, int level) async {
    await prefix.RongIMClient.setConversationTypeNotificationLevel(type, level, (code) {
      String toast = "指定会话类型免打扰:\n" + type.toString() + "level:" + level.toString();
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _getConversationTypeForNotification() {
    List<Widget> widgets = [
      ListTile(
        title: Center(
          child: Text(
            "单聊",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        onTap: () async {
          Navigator.pop(context);
          _getConversationTypeNotificationLevel(1);
        },
      ),
      ListTile(
        title: Center(
          child: Text(
            "群聊",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        onTap: () async {
          Navigator.pop(context);
          _getConversationTypeNotificationLevel(3);
        },
      ),
      ListTile(
        title: Center(
          child: Text(
            "超级群",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        onTap: () async {
          Navigator.pop(context);
          _getConversationTypeNotificationLevel(10);
        },
      )
    ];
    _showSheet(widgets);
  }

  void _getConversationTypeNotificationLevel(int type) async {
    await prefix.RongIMClient.getConversationTypeNotificationLevel(type, (code, pushNotificationLevel) {
      String toast = "查询会话类型免打扰:\n" + pushNotificationLevel.toString();
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _getUltraGroupUnreadCount() async {
    String targetId = "100";
    await prefix.RongIMClient.getUltraGroupUnreadCount(targetId, (int? code, int? count) {
      String toast = "获取指定超级群下所有频道的未读数:\n" + count.toString();
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _getUltraGroupAllUnreadCount() async {
    await prefix.RongIMClient.getUltraGroupAllUnreadCount((int? code, int? count) {
      String toast = "获取超级群会话类型的所有未读消息数:\n" + count.toString();
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _getUltraGroupAllUnreadMentionedCount() async {
    await prefix.RongIMClient.getUltraGroupAllUnreadMentionedCount((int? code, int? count) {
      String toast = "获取超级群会话类型的@消息未读数:\n" + count.toString();
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _getFirstUnreadMsg() async {
    String targetId = "SealTalk";
    prefix.Message? m = await prefix.RongIMClient.getFirstUnreadMessage(1, targetId);
  }

  void _showSheet(List<Widget> items) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: items,
          );
        });
  }

  void setNotificationQuietHoursLevel(int level) {
    developer.log("_setNotificationQuietHours", name: pageName);
    prefix.RongIMClient.setNotificationQuietHoursLevel("09:00:00", 600, level, (int? code) {
      EventBus.instance!.commit(EventKeys.UpdateNotificationQuietStatus, {});
      String toast = "设置全局屏蔽某个时间段的消息提醒:\n" + (code == 0 ? "设置成功" : "设置失败, code:" + code.toString());
      developer.log(toast, name: pageName);

      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _setNotificationQuietHours() {
    List<Widget> widgets = [
      ListTile(
        title: Center(
          child: Text(
            "向上查询群或者APP级别设置",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        onTap: () async {
          Navigator.pop(context);
          setNotificationQuietHoursLevel(0);
        },
      ),
      ListTile(
        title: Center(
          child: Text(
            "仅@消息通知",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        onTap: () async {
          Navigator.pop(context);
          setNotificationQuietHoursLevel(1);
        },
      ),
      ListTile(
        title: Center(
          child: Text(
            "不接收消息通知",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        onTap: () async {
          Navigator.pop(context);
          setNotificationQuietHoursLevel(5);
        },
      )
    ];
    _showSheet(widgets);
  }

  void _getNotificationQuietHours() {
    developer.log("_getNotificationQuietHours", name: pageName);
    prefix.RongIMClient.getNotificationQuietHoursLevel((code, startTime, spanMins, pushNotificationQuietHoursLevel) {
      String toast = "查询已设置的全局时间段消息提醒屏蔽\n: startTime:" + (startTime ?? "") + " spansMin:" + spanMins.toString() + "pushNotificationQuietHoursLevel:" + pushNotificationQuietHoursLevel.toString() + (code == 0 ? "" : "\n设置失败, code:" + code.toString());
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _removeNotificationQuietHours() {
    developer.log("_removeNotificationQuietHours", name: pageName);

    prefix.RongIMClient.setNotificationQuietHoursLevel("09:00:00", 600, 0, (int? code) {
      EventBus.instance!.commit(EventKeys.UpdateNotificationQuietStatus, {});
      String toast = "删除已设置的全局时间段消息提醒屏蔽:\n" + (code == 0 ? "删除成功" : "删除失败, code:" + code.toString());
      developer.log(toast, name: pageName);

      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _getCons() async {
    int conversationType = prefix.RCConversationType.Private;
    String targetId = "SealTalk";
    prefix.Conversation? con = await prefix.RongIMClient.getConversation(conversationType, targetId);
    if (con != null) {
      developer.log("getConversation type:" + con.conversationType.toString() + " targetId:" + con.targetId!, name: pageName);
    } else {
      developer.log("不存在该会话 type:" + conversationType.toString() + " targetId:" + targetId, name: pageName);
    }
  }

  void _getMessagesByDirection() async {
    int conversationType = prefix.RCConversationType.Private;
    String targetId = "SealTalk";
    int sentTime = 1567756686643;
    int beforeCount = 10;
    int afterCount = 10;
    List? msgs = await prefix.RongIMClient.getHistoryMessages(conversationType, targetId, sentTime, beforeCount, afterCount);
    if (msgs == null) {
      developer.log("未获取消息列表 type:" + conversationType.toString() + " targetId:" + targetId, name: pageName);
    } else {
      for (prefix.Message msg in msgs) {
        developer.log("getHistoryMessages messageId:" + msg.messageId.toString() + " objName:" + msg.objectName! + " sentTime:" + msg.sentTime.toString(), name: pageName);
      }
    }
  }

  void _getConversationListByPage() async {
    List? list = await prefix.RongIMClient.getConversationListByPage([prefix.RCConversationType.Private, prefix.RCConversationType.Group], 2, 0);
    prefix.Conversation? lastCon;
    if (list != null && list.length > 0) {
      list.sort((a, b) => b.sentTime.compareTo(a.sentTime));
      for (int i = 0; i < list.length; i++) {
        prefix.Conversation con = list[i];
        developer.log("first targetId:" + con.targetId! + " " + "time:" + con.sentTime.toString(), name: pageName);
        lastCon = con;
      }
    }
    if (lastCon != null) {
      list = await prefix.RongIMClient.getConversationListByPage([prefix.RCConversationType.Private, prefix.RCConversationType.Group], 2, lastCon.sentTime!);
      if (list != null && list.length > 0) {
        list.sort((a, b) => b.sentTime.compareTo(a.sentTime));
        for (int i = 0; i < list.length; i++) {
          prefix.Conversation con = list[i];
          developer.log("last targetId:" + con.targetId! + " " + "time:" + con.sentTime.toString(), name: pageName);
        }
      }
    }
  }

  void _sendMessageAddSendUserInfo() async {
    prefix.TextMessage msg = new prefix.TextMessage();
    msg.content = "测试文本消息携带用户信息";
    /*
    测试携带用户信息
    */
    prefix.UserInfo sendUserInfo = new prefix.UserInfo();
    sendUserInfo.name = "textSendUser.name";
    sendUserInfo.userId = "textSendUser.userId";
    sendUserInfo.portraitUri = "textSendUser.portraitUrl";
    sendUserInfo.extra = "textSendUser.extra";
    msg.sendUserInfo = sendUserInfo;

    prefix.Message? message = await prefix.RongIMClient.sendMessage(prefix.RCConversationType.Private, "SealTalk", msg);
    String toast = "发送消息携带用户信息:\n 消息的 objectName:" + message!.content!.getObjectName()! + "\nmsgContent:" + message.content!.encode()!;
    developer.log(toast, name: pageName);
    DialogUtil.showAlertDiaLog(context, toast);
  }

  void _pushToChatRoomDebug(BuildContext context) {
    Navigator.pushNamed(context, "/chatroom_debug");
  }

  void _getBlockedConversationList() {
    prefix.RongIMClient.getBlockedConversationList([prefix.RCConversationType.Private, prefix.RCConversationType.Group], (List? convertionList, int? code) {
      String toast = "消息免打扰会话数量:\n ${convertionList!.length}";
      // for (prefix.Conversation conversation in convertionList) {
      //   toast = toast + conversation.toString();
      // }
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  // Widget getBottomSheet(){

  // }

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
              _didTap(index, context);
            },
            child: Text(titles[index]),
            color: Colors.blue,
          );
        },
      ),
    );
  }
}
