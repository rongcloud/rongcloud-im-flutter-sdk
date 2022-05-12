import 'dart:core';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_im_plugin_example/im/util/event_bus.dart';

import '../im/util/dialog_util.dart';

List<String> _kUltraGroupTitles = <String>["设置免打扰", "查看免打扰", "清空本地历史消息", "清空本地和远端历史消息", "删除本地[所有频道]当前时间之前的消息", "删除本地[当前频道]当前时间之前的消息", "删除服务端当前时间之前的消息", "查询指定超级群默认通知配置", "设置指定超级群默认通知配置", "查询指定超级群指定频道默认通知配置", "设置指定超级群指定频道默认通知配置"];

class ChatDebugPage extends StatefulWidget {
  final Map? arguments;

  ChatDebugPage({Key? key, this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatDebugPageState(arguments: this.arguments);
}

class _ChatDebugPageState extends State<ChatDebugPage> {
  String pageName = "example.ChatDebugPage";
  Map? arguments;
  late List titles;
  int? conversationType;
  String? targetId;
  bool? isPrivate;
  late String channelId;
  late bool isUltraGroup;

  _ChatDebugPageState({this.arguments});

  @override
  void initState() {
    super.initState();
    conversationType = arguments!["coversationType"];
    targetId = arguments!["targetId"];
    channelId = arguments!["channelId"] ?? "";
    isUltraGroup = arguments!["isUltraGroup"];
    titles = [
      "设置免打扰",
      "查看免打扰",
      "搜索会话消息记录",
      "通过UId获取消息",
      "批量插入数据库消息",
      "设置缩略图配置",
      "添加标签",
      "移除标签",
      "更新标签",
      "获取标签列表",
      "添加会话到一个标签",
      "删除指定一个标签中会话",
      "获取指定会话下的所有标签",
      "删除指定会话中的某些标签",
      "分页获取本地指定标签下会话列表",
      "按标签获取未读消息数",
      "设置标签中会话置顶状态",
      "获取指定会话下的标签置顶状态",
      "消息断档新接口",
    ];
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
    } else if (conversationType == RCConversationType.UltraGroup) {
      titles.clear();
      titles.addAll(_kUltraGroupTitles);
    }

    RongIMClient.onTagChanged = () {
      Fluttertoast.showToast(msg: "会话标签变化收到监听", timeInSecForIosWeb: 2);
    };
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
        _setConStatusEnable(true);
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
      case "批量插入数据库消息":
        _batchInsertMessage();
        break;
      case "设置缩略图配置":
        _imageCompressConfig();
        break;
      case "添加标签":
        _addtag();
        break;
      case "移除标签":
        _removeTag();
        break;
      case "更新标签":
        _updateTag();
        break;
      case "获取标签列表":
        _getTags();
        break;
      case "添加会话到一个标签":
        _addConversationsToTag();
        break;
      case "删除指定一个标签中会话":
        _removeConversationsFromTag();
        break;
      case "发送定向消息":
        _onSendDirectionalMessage();
        break;
      case "消息断档新接口":
        _getMessages();
        break;
      case "获取指定会话下的所有标签":
        _getTagsFromConversation();
        break;
      case "删除指定会话中的某些标签":
        _removeTagsFromConversation();
        break;
      case "分页获取本地指定标签下会话列表":
        _getConversationsFromTagByPage();
        break;
      case "按标签获取未读消息数":
        _getUnreadCountByTag();
        break;
      case "设置标签中会话置顶状态":
        _setConversationToTopInTag();
        break;
      case "获取指定会话下的标签置顶状态":
        _getConversationTopStatusInTag();
        break;
      case "会话置顶":
        _setConversationTopState(true);
        break;
      case "取消会话置顶":
        _setConversationTopState(false);
        break;
      case "清空本地历史消息":
        _clearLocalHistoryMessage();
        break;
      case "清空本地和远端历史消息":
        _clearHistoryMessage();
        break;
      case "删除本地[所有频道]当前时间之前的消息":
        _clearMessagesForAllChannel();
        break;
      case "删除本地[当前频道]当前时间之前的消息":
        _clearUltraGroupMessages();
        break;
      case "删除服务端当前时间之前的消息":
        _clearRemoteMessages();
        break;
      case "获取当前超级群所有频道的lastMsgUid":
        _getConversationTopStatusInTag();
        break;
      case "查询指定超级群默认通知配置":
        _getUltraGroupConversationDefaultNotificationLevel();
        break;
      case "设置指定超级群默认通知配置":
        _setUltraGroupLevel();
        break;
      case "查询指定超级群指定频道默认通知配置":
        _getUltraGroupConversationChannelDefaultNotificationLevel();
        break;
      case "设置指定超级群指定频道默认通知配置":
        _setUltraGroupChannelLevel();
        break;
    }
  }

  void _getUltraGroupConversationChannelDefaultNotificationLevel() {
    developer.log("_getUltraGroupConversationDefaultNotificationLevel", name: pageName);
    RongIMClient.getUltraGroupConversationChannelDefaultNotificationLevel(targetId!, channelId, (code, pushNotificationLevel) {
      String toast = pushNotificationLevel.toString();
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _setUltraGroupConversationChannelDefaultNotificationLevel(int level) {
    developer.log("_setUltraGroupConversationDefaultNotificationLevel", name: pageName);
    RongIMClient.setUltraGroupConversationChannelDefaultNotificationLevel(targetId!, channelId, level, (code) {
      String toast = "设置成功 code:" + code.toString();
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _setUltraGroupChannelLevel() {
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
          _setUltraGroupConversationChannelDefaultNotificationLevel(-1);
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
          _setUltraGroupConversationChannelDefaultNotificationLevel(0);
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
          _setUltraGroupConversationChannelDefaultNotificationLevel(1);
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
          _setUltraGroupConversationChannelDefaultNotificationLevel(5);
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
          _setUltraGroupConversationChannelDefaultNotificationLevel(2);
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
          _setUltraGroupConversationChannelDefaultNotificationLevel(4);
        },
      )
    ];
    _showSheet(widgets);
  }

  void _setUltraGroupLevel() {
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
          _setUltraGroupConversationDefaultNotificationLevel(-1);
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
          _setUltraGroupConversationDefaultNotificationLevel(0);
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
          _setUltraGroupConversationDefaultNotificationLevel(1);
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
          _setUltraGroupConversationDefaultNotificationLevel(5);
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
          _setUltraGroupConversationDefaultNotificationLevel(2);
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
          _setUltraGroupConversationDefaultNotificationLevel(4);
        },
      )
    ];
    _showSheet(widgets);
  }

  void _setUltraGroupConversationDefaultNotificationLevel(int level) {
    developer.log("_setUltraGroupConversationDefaultNotificationLevel", name: pageName);
    RongIMClient.setUltraGroupConversationDefaultNotificationLevel(targetId!, level, (code) {
      String toast = "设置成功 code:" + code.toString();
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _getUltraGroupConversationDefaultNotificationLevel() {
    developer.log("_getUltraGroupConversationDefaultNotificationLevel", name: pageName);
    RongIMClient.getUltraGroupConversationDefaultNotificationLevel(targetId!, (code, pushNotificationLevel) {
      String toast = pushNotificationLevel.toString();
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _addBlackList() {
    developer.log("_addBlackList", name: pageName);
    RongIMClient.addToBlackList(targetId!, (int? code) {
      String toast = code == 0 ? "加入黑名单成功" : "加入黑名单失败， $code";
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _removeBalckList() {
    developer.log("_removeBalckList", name: pageName);
    RongIMClient.removeFromBlackList(targetId!, (int? code) {
      String toast = code == 0 ? "取消黑名单成功" : "取消黑名单失败，错误码: $code";
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _getBlackStatus() {
    developer.log("_getBlackStatus", name: pageName);
    RongIMClient.getBlackListStatus(targetId!, (int? blackStatus, int? code) {
      if (0 == code) {
        if (RCBlackListStatus.In == blackStatus) {
          developer.log("用户:" + targetId! + " 在黑名单中", name: pageName);
          DialogUtil.showAlertDiaLog(context, "用户:" + targetId! + " 在黑名单中");
        } else {
          developer.log("用户:" + targetId! + " 不在黑名单中", name: pageName);
          DialogUtil.showAlertDiaLog(context, "用户:" + targetId! + " 不在黑名单中");
        }
      } else {
        developer.log("用户:" + targetId! + " 黑名单状态查询失败" + code.toString(), name: pageName);
        DialogUtil.showAlertDiaLog(context, "用户:" + targetId! + " 黑名单状态查询失败" + code.toString());
      }
    });
  }

  void _getBlackList() {
    developer.log("_getBlackList", name: pageName);
    RongIMClient.getBlackList((List? /*<String>*/ userIdList, int? code) {
      DialogUtil.showAlertDiaLog(context, "获取黑名单列表:\n userId 列表:" + userIdList.toString() + (code == 0 ? "" : "\n获取失败，错误码 code:" + code.toString()));
      userIdList!.forEach((userId) {
        developer.log("userId:" + userId, name: pageName);
      });
    });
  }

  void _setConStatusEnable(bool enable) {
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
          setConversationChannelNotificationLevel(-1);
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
          setConversationChannelNotificationLevel(0);
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
          setConversationChannelNotificationLevel(1);
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
          setConversationChannelNotificationLevel(5);
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
          setConversationChannelNotificationLevel(2);
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
          setConversationChannelNotificationLevel(4);
        },
      )
    ];
    _showSheet(widgets);

    // RongIMClient.setConversationNotificationStatus(conversationType!, targetId!, enable, (int? status, int? code) {
    //   developer.log("setConversationNotificationStatus1 status " + status.toString(), name: pageName);
    //   String toast = code == 0 ? "设置免打扰成功" : "设置免打扰失败，错误码: $code";
    //   DialogUtil.showAlertDiaLog(context, toast);
    // }, channelId: channelId);
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

  void setConversationChannelNotificationLevel(int level) {
    if (channelId == "") {
      RongIMClient.setConversationNotificationLevel(conversationType!, targetId!, level, (code) {
        developer.log("setConversationNotificationLevel status " + level.toString(), name: pageName);
        String toast = code == 0 ? "设置免打扰成功" : "设置免打扰失败，错误码: $code";
        DialogUtil.showAlertDiaLog(context, toast);
      });
    } else {
      RongIMClient.setConversationChannelNotificationLevel(conversationType!, targetId!, channelId, level, (code) {
        developer.log("setConversationChannelNotificationLevel status " + level.toString(), name: pageName);
        String toast = code == 0 ? "设置免打扰成功" : "设置免打扰失败，错误码: $code";
        DialogUtil.showAlertDiaLog(context, toast);
      });
    }
  }

  void _getConStatus() {
    if (channelId == "") {
      RongIMClient.getConversationNotificationLevel(conversationType!, targetId!, (code, pushNotificationLevel) {
        String toast = "免打扰状态:" + pushNotificationLevel.toString();
        developer.log(toast, name: pageName);
        DialogUtil.showAlertDiaLog(context, toast);
      });
    } else {
      RongIMClient.getConversationChannelNotificationLevel(conversationType!, targetId!, channelId, (code, pushNotificationLevel) {
        String toast = "免打扰状态:" + pushNotificationLevel.toString();
        developer.log(toast, name: pageName);
        DialogUtil.showAlertDiaLog(context, toast);
      });
    }
  }

  void _goToSearchMessagePage() {
    Map arg = {"coversationType": conversationType, "targetId": targetId};
    Navigator.pushNamed(context, "/search_message", arguments: arg);
  }

  void _getMessageByUId() async {
    List? msgs = await RongIMClient.getHistoryMessage(conversationType!, targetId!, 0, 20);
    if (msgs!.length <= 0) {
      return;
    }
    Message message = msgs[(Random().nextInt(msgs.length - 1))];
    String uId = message.messageUId!;
    Message? msg = await RongIMClient.getMessageByUId(uId);
    DialogUtil.showAlertDiaLog(context, "${msg.toString()}");
  }

  void _batchInsertMessage() async {
    List? msgs = await RongIMClient.getHistoryMessage(conversationType!, targetId!, 0, 20);
    if (msgs!.length <= 0) {
      return;
    }
    Message? message = msgs[(Random().nextInt(msgs.length - 1))];
    RongIMClient.batchInsertMessage([message!], (bool? result, int? code) {
      if (code != 0) {
        DialogUtil.showAlertDiaLog(context, "插入数据库消息失败");
      } else {
        if (result!) {
          DialogUtil.showAlertDiaLog(context, "插入数据库消息成功");
        } else {
          DialogUtil.showAlertDiaLog(context, "插入数据库消息失败");
        }
      }
    });
  }

  void _onSendDirectionalMessage() async {
    TextMessage txtMessage = new TextMessage();
    txtMessage.content = "这条消息来自 Flutter 的群定向消息";
    RongIMClient.sendDirectionalMessage(conversationType, targetId, ['UserId1', 'UserId2'], txtMessage, finished: (int messageId, int status, int code) {
      print("sendDirectionalMessage $messageId, $status, $code");
    });
  }

  void _getMessages() async {
    List? msgs = await RongIMClient.getHistoryMessage(conversationType!, targetId!, 0, 20);
    if (msgs!.length <= 0) {
      return;
    }
    Message message = msgs[msgs.length - 1];
    int timestamps = message.sentTime!;
    HistoryMessageOption option = HistoryMessageOption(20, timestamps, 0);
    RongIMClient.getMessages(conversationType!, targetId!, option, (msgList, code) {
      String toast = code == 0 ? "断档消息获取成功:" + msgList!.length.toString() : "断档消息获取失败， $code";
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _imageCompressConfig() {
    RongIMClient.imageCompressConfig(120, 50, 0.3);
  }

  void _addtag() {
    TagInfo tagInfo = new TagInfo();
    tagInfo.tagId = targetId;
    tagInfo.tagName = 'FAddtag';
    tagInfo.count = 10;
    DateTime time = DateTime.now();
    int timestamps = time.millisecondsSinceEpoch;
    tagInfo.timestamp = timestamps;
    RongIMClient.addTag(tagInfo, (int? code) {
      String toast = code == 0 ? "添加标签成功" : "添加标签失败， $code";
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _removeTag() {
    RongIMClient.removeTag(targetId, (int? code) {
      String toast = code == 0 ? "删除标签成功" : "删除标签失败， $code";
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _updateTag() {
    TagInfo tagInfo = new TagInfo();
    tagInfo.tagId = targetId;
    tagInfo.tagName = 'FUpdatetag';
    tagInfo.count = 10;
    DateTime time = DateTime.now();
    int timestamp = time.millisecondsSinceEpoch;
    tagInfo.timestamp = timestamp;
    RongIMClient.updateTag(tagInfo, (int? code) {
      String toast = code == 0 ? "更新标签成功" : "更新标签失败， $code";
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _getTags() async {
    List? tags = await RongIMClient.getTags((int? code, List tags) {
      int count = tags.length;
      String toast = "标签个数 :  $count";
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _addConversationsToTag() async {
    List identifiers = [];
    ConversationIdentifier identifier = ConversationIdentifier();
    identifier.conversationType = conversationType;
    identifier.targetId = targetId;
    identifiers.add(identifier);
    await RongIMClient.addConversationsToTag(targetId, identifiers, (result, code) {
      String toast = code == 0 ? "添加成功" : "添加失败 $code";
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _removeConversationsFromTag() async {
    List identifiers = [];
    ConversationIdentifier identifier = ConversationIdentifier();
    identifier.conversationType = conversationType;
    identifier.targetId = targetId;
    identifiers.add(identifier);
    await RongIMClient.removeConversationsFromTag(targetId, identifiers, (result, code) {
      String toast = code == 0 ? "删除成功" : "删除失败 $code";
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _getTagsFromConversation() async {
    String toast = "";
    await RongIMClient.getTagsFromConversation(conversationType, targetId, (int? code, List conversationList) {
      if (conversationList.length == 0) {
        toast = "tags is null";
      } else {
        for (ConversationTagInfo? info in conversationList) {
          toast = toast + "[isTop:${info!.isTop},tagId:${info.tagInfo!.tagId},tagName:${info.tagInfo!.tagName},count:${info.tagInfo!.count},timestamp:${info.tagInfo!.timestamp}] ";
        }
      }
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _removeTagsFromConversation() async {
    await RongIMClient.removeTagsFromConversation(conversationType, targetId, [targetId], (result, code) {
      String toast = code == 0 ? "删除成功" : "删除失败 $code";
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _getConversationsFromTagByPage() async {
    String toast = "";
    await RongIMClient.getConversationsFromTagByPage(targetId, 0, 0, (code, conversationList) {
      if (conversationList == null || conversationList.length == 0) {
        toast = "tags is null";
      } else {
        for (Conversation? con in conversationList) {
          toast = toast + "[targetId:${con!.conversationType},conversationType:${con.conversationType}}";
        }
      }
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, "$toast");
    });
  }

  void _getUnreadCountByTag() async {
    RongIMClient.getUnreadCountByTag(targetId, true, (int? result, int? code) {
      String toast = code == 0 ? "获取成功未读数:$code" : "获取成功 $code";
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _setConversationToTopInTag() async {
    RongIMClient.setConversationToTopInTag(conversationType, targetId, targetId, true, (result, code) {
      String toast = code == 0 ? "设置置顶成功" : "设置失败 $code";
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _getConversationTopStatusInTag() async {
    RongIMClient.getConversationTopStatusInTag(conversationType, targetId, targetId, (result, code) {
      String toast = code == 0 ? "置顶状态 $result" : "获取失败 $code";
      developer.log(toast, name: pageName);
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }

  void _setConversationTopState(bool isTop) {
    RongIMClient.setConversationToTop(conversationType!, targetId!, isTop, (status, code) => null, channelId: channelId);
  }

  void _clearLocalHistoryMessage() {
    RongIMClient.clearMessages(
      conversationType,
      targetId,
      (code) {
        String toast = code == 0 ? "本地历史清除成功" : "本地历史清除失败";
        DialogUtil.showAlertDiaLog(context, toast);
        EventBus.instance!.commit(EventKeys.ClearMessage, null);
      },
      channelId: channelId,
    );
  }

  void _clearHistoryMessage() {
    RongIMClient.clearHistoryMessages(
      conversationType,
      targetId,
      0,
      true,
      (code) {
        String toast = code == 0 ? "清除成功" : "清除失败";
        DialogUtil.showAlertDiaLog(context, toast);
        EventBus.instance!.commit(EventKeys.ClearMessage, null);
      },
      channelId: channelId,
    );
  }

  void _clearUltraGroupMessages() async {
    bool isSuccess = await RongIMClient.deleteUltraGroupMessages(targetId!, channelId, 0);
    if (isSuccess) {
      EventBus.instance!.commit(EventKeys.ClearMessage, null);
    }
    String toast = isSuccess ? "清除成功" : "清除失败";
    DialogUtil.showAlertDiaLog(context, toast);
  }

  void _clearMessagesForAllChannel() async {
    bool isSuccess = await RongIMClient.deleteUltraGroupMessagesForAllChannel(targetId!, 0);
    if (isSuccess) {
      EventBus.instance!.commit(EventKeys.ClearMessage, null);
    }

    String toast = isSuccess ? "清除成功" : "清除失败";
    DialogUtil.showAlertDiaLog(context, toast);
  }

  void _clearRemoteMessages() {
    RongIMClient.deleteRemoteUltraGroupMessages(targetId!, channelId, 0, (code) {
      String toast = code == 0 ? "清除成功" : "清除失败";
      DialogUtil.showAlertDiaLog(context, toast);
    });
  }
}
