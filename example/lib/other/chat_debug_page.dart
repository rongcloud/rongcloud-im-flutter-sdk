import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import '../im/util/dialog_util.dart';
import 'dart:developer' as developer;

class ChatDebugPage extends StatefulWidget {
  final Map arguments;

  ChatDebugPage({Key key, this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _ChatDebugPageState(arguments: this.arguments);
}

class _ChatDebugPageState extends State<ChatDebugPage> {
  String pageName = "example.ChatDebugPage";
  Map arguments;
  List titles;
  int conversationType;
  String targetId;
  bool isPrivate;

  _ChatDebugPageState({this.arguments});
  @override
  void initState() {
    super.initState();
    conversationType = arguments["coversationType"];
    targetId = arguments["targetId"];
    titles = ["设置免打扰", "取消免打扰", "查看免打扰", "搜索会话消息记录", "通过UId获取消息"];
    if (conversationType == RCConversationType.Private) {
      List onlyPrivateTitles = [
        "加入黑名单",
        "移除黑名单",
        "查看黑名单状态",
        "获取黑名单列表",
      ];
      titles.addAll(onlyPrivateTitles);
    } else if (conversationType == RCConversationType.Group) {
      List onlyGroupTitles = [
        "发送定向消息",
      ];
      titles.addAll(onlyGroupTitles);
    }
  }

  void _didTap(int index) {
    developer.log("did tap debug " + titles[index], name: pageName);
    switch (titles[index]) {
      case "加入黑名单":
        _addBlackList();
        break;
      case "移除黑名单":
        _removeBalckList();
        break;
      case "查看黑名单状态":
        _getBlackStatus();
        break;
      case "获取黑名单列表":
        _getBlackList();
        break;
      case "设置免打扰":
        _setConStatusEnable();
        break;
      case "取消免打扰":
        _setConStatusDisanable();
        break;
      case "查看免打扰":
        _getConStatus();
        break;
      case "搜索会话消息记录":
        _goToSearchMessagePage();
        break;
      case "通过UId获取消息":
        _getMessageByUId();
        break;
      case "发送定向消息":
        _onSendDirectionalMessage();
        break;
    }
  }

  void _addBlackList() {
    developer.log("_addBlackList", name: pageName);
    RongIMClient.addToBlackList(targetId, (int code) {
      String toast = code == 0 ? "加入黑名单成功" : "加入黑名单失败， $code";
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _removeBalckList() {
    developer.log("_removeBalckList", name: pageName);
    RongIMClient.removeFromBlackList(targetId, (int code) {
      String toast = code == 0 ? "取消黑名单成功" : "取消黑名单失败，错误码: $code";
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _getBlackStatus() {
    developer.log("_getBlackStatus", name: pageName);
    RongIMClient.getBlackListStatus(targetId, (int blackStatus, int code) {
      if (0 == code) {
        if (RCBlackListStatus.In == blackStatus) {
          developer.log("用户:" + targetId + " 在黑名单中", name: pageName);
          DialogUtil.showAlertDiaLog(context, "用户:" + targetId + " 在黑名单中");
        } else {
          developer.log("用户:" + targetId + " 不在黑名单中", name: pageName);
          DialogUtil.showAlertDiaLog(context, "用户:" + targetId + " 不在黑名单中");
        }
      } else {
        developer.log("用户:" + targetId + " 黑名单状态查询失败" + code.toString(),
            name: pageName);
        DialogUtil.showAlertDiaLog(
            context, "用户:" + targetId + " 黑名单状态查询失败" + code.toString());
      }
    });
  }

  void _getBlackList() {
    developer.log("_getBlackList", name: pageName);
    RongIMClient.getBlackList((List/*<String>*/ userIdList, int code) {
      DialogUtil.showAlertDiaLog(
          context,
          "获取黑名单列表:\n userId 列表:" +
              userIdList.toString() +
              (code == 0 ? "" : "\n获取失败，错误码 code:" + code.toString()));
      userIdList.forEach((userId) {
        developer.log("userId:" + userId, name: pageName);
      });
    });
  }

  void _setConStatusEnable() {
    RongIMClient.setConversationNotificationStatus(
        conversationType, targetId, true, (int status, int code) {
      developer.log(
          "setConversationNotificationStatus1 status " + status.toString(),
          name: pageName);
      String toast = code == 0 ? "设置免打扰成功" : "设置免打扰失败，错误码: $code";
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _setConStatusDisanable() {
    RongIMClient.setConversationNotificationStatus(
        conversationType, targetId, false, (int status, int code) {
      developer.log(
          "setConversationNotificationStatus2 status " + status.toString(),
          name: pageName);
      String toast = code == 0 ? "取消免打扰成功" : "取消免打扰失败，错误码: $code";
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _getConStatus() {
    RongIMClient.getConversationNotificationStatus(conversationType, targetId,
        (int status, int code) {
      String toast = "免打扰状态:" + (status == 0 ? "免打扰" : "有消息提醒");
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _goToSearchMessagePage() {
    Map arg = {"coversationType": conversationType, "targetId": targetId};
    Navigator.pushNamed(context, "/search_message", arguments: arg);
  }

  void _getMessageByUId() async {
    List msgs =
        await RongIMClient.getHistoryMessage(conversationType, targetId, 0, 20);
    Message message = msgs[(Random().nextInt(msgs.length - 1))];
    String uId = message.messageUId;
    Message msg = await RongIMClient.getMessageByUId(uId);
    DialogUtil.showAlertDiaLog(context, "${msg.toString()}");
  }

  void _onSendDirectionalMessage() async {
    TextMessage txtMessage = new TextMessage();
    txtMessage.content = "这条消息来自 Flutter 的群定向消息";
    RongIMClient.sendDirectionalMessage(
        conversationType, targetId, ['UserId1', 'UserId2'], txtMessage,
        finished: (int messageId, int status, int code) {
      print("sendDirectionalMessage $messageId, $status, $code");
    });
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
