import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart' as prefix;
import '../im/util/dialog_util.dart';
import '../im/util/event_bus.dart';

class DebugPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  List titles = [
    "设置全局屏蔽某个时间段的消息提醒",
    "查询已设置的全局时间段消息提醒屏蔽",
    "删除已设置的全局时间段消息提醒屏蔽",
    "获取特定会话",
    "获取特定方向的消息列表",
    "分页获取会话",
    "消息携带用户信息",
    "聊天室状态存储测试",
  ];

  void _didTap(int index, BuildContext context) {
    print("did tap debug " + titles[index]);
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
    }
  }

  void _setNotificationQuietHours() {
    print("_setNotificationQuietHours");
    prefix.RongIMClient.setNotificationQuietHours("09:00:00", 600, (int code) {
      EventBus.instance.commit(EventKeys.UpdateNotificationQuietStatus, {});
      String toast = "设置全局屏蔽某个时间段的消息提醒:\n" +
          (code == 0 ? "设置成功" : "设置失败, code:" + code.toString());
      print(toast);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _getNotificationQuietHours() {
    print("_getNotificationQuietHours");
    prefix.RongIMClient.getNotificationQuietHours(
        (int code, String startTime, int spansMin) {
      String toast = "查询已设置的全局时间段消息提醒屏蔽\n: startTime:" +
          startTime +
          " spansMin:" +
          spansMin.toString() +
          (code == 0 ? "" : "\n设置失败, code:" + code.toString());
      print(toast);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _removeNotificationQuietHours() {
    print("_removeNotificationQuietHours");
    prefix.RongIMClient.removeNotificationQuietHours((int code) {
      EventBus.instance.commit(EventKeys.UpdateNotificationQuietStatus, {});
      String toast = "删除已设置的全局时间段消息提醒屏蔽:\n" +
          (code == 0 ? "删除成功" : "删除失败, code:" + code.toString());
      print(toast);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _getCons() async {
    int conversationType = prefix.RCConversationType.Private;
    String targetId = "SealTalk";
    prefix.Conversation con =
        await prefix.RongIMClient.getConversation(conversationType, targetId);
    if (con != null) {
      print("getConversation type:" +
          con.conversationType.toString() +
          " targetId:" +
          con.targetId);
    } else {
      print("不存在该会话 type:" +
          conversationType.toString() +
          " targetId:" +
          targetId);
    }
  }

  void _getMessagesByDirection() async {
    int conversationType = prefix.RCConversationType.Private;
    String targetId = "SealTalk";
    int sentTime = 1567756686643;
    int beforeCount = 10;
    int afterCount = 10;
    List msgs = await prefix.RongIMClient.getHistoryMessages(
        conversationType, targetId, sentTime, beforeCount, afterCount);
    if (msgs == null) {
      print("未获取消息列表 type:" +
          conversationType.toString() +
          " targetId:" +
          targetId);
    } else {
      for (prefix.Message msg in msgs) {
        print("getHistoryMessages messageId:" +
            msg.messageId.toString() +
            " objName:" +
            msg.objectName +
            " sentTime:" +
            msg.sentTime.toString());
      }
    }
  }

  void _getConversationListByPage() async {
    List list = await prefix.RongIMClient.getConversationListByPage(
        [prefix.RCConversationType.Private, prefix.RCConversationType.Group],
        2,
        0);
    prefix.Conversation lastCon;
    if (list != null && list.length > 0) {
      list.sort((a, b) => b.sentTime.compareTo(a.sentTime));
      for (int i = 0; i < list.length; i++) {
        prefix.Conversation con = list[i];
        print("first targetId:" +
            con.targetId +
            " " +
            "time:" +
            con.sentTime.toString());
        lastCon = con;
      }
    }
    if (lastCon != null) {
      list = await prefix.RongIMClient.getConversationListByPage(
          [prefix.RCConversationType.Private, prefix.RCConversationType.Group],
          2,
          lastCon.sentTime);
      if (list != null && list.length > 0) {
        list.sort((a, b) => b.sentTime.compareTo(a.sentTime));
        for (int i = 0; i < list.length; i++) {
          prefix.Conversation con = list[i];
          print("last targetId:" +
              con.targetId +
              " " +
              "time:" +
              con.sentTime.toString());
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

    prefix.Message message = await prefix.RongIMClient.sendMessage(
        prefix.RCConversationType.Private, "SealTalk", msg);
    String toast = "发送消息携带用户信息:\n 消息的 objectName:" +
        message.content.getObjectName() +
        "\nmsgContent:" +
        message.content.encode();
    print(toast);
    DialogUtil.showAlertDiaLog(context, toast);
  }

  void _pushToChatRoomDebug(BuildContext context) {
    Navigator.pushNamed(context, "/chatroom_debug");
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
