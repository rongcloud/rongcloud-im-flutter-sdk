import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_im_plugin_example/im/util/dialog_util.dart';
import 'package:rongcloud_im_plugin_example/im/util/style.dart';
import '../im/util/event_bus.dart';

class SelectConversationPage extends StatefulWidget {
  // final List selectMessages;
  final Map arguments;
  const SelectConversationPage({Key key, this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _SelectConversationPageState(this.arguments);
}

class _SelectConversationPageState extends State<SelectConversationPage> {
  final Map arguments;
  _SelectConversationPageState(this.arguments);

  List selectMessages;
  int forwardType; // 0:逐条转发，1:合并转发
  List conList = new List();
  List<int> displayConversationType = [
    RCConversationType.Private,
    RCConversationType.Group
  ];
  ScrollController _scrollController;
  List selectConList = new List();

  @override
  void initState() {
    super.initState();
    selectMessages = arguments["selectMessages"];
    forwardType = arguments["forwardType"];
    updateConversationList();
  }

  updateConversationList() async {
    List list =
        await RongcloudImPlugin.getConversationList(displayConversationType);
    if (list != null) {
      conList = list;
    }
    _renfreshUI();
  }

  void _renfreshUI() {
    setState(() {});
  }

  Widget _buildConversationListView() {
    return new ListView.separated(
        scrollDirection: Axis.vertical,
        itemCount: conList.length,
        controller: _scrollController,
        itemBuilder: (BuildContext context, int index) {
          if (conList.length <= 0) {
            // return WidgetUtil.buildEmptyWidget();
          }
          return getWidget(conList[index]);
        },
        separatorBuilder: (BuildContext context, int index) {
          return Container(
            height: 10,
            width: 1,
          );
        });
  }

  Widget getWidget(Conversation con) {
    return GestureDetector(
      onTap: () {
        didTapItem(con);
      },
      child: Container(
        height: 50.0,
        color: Colors.white,
        child: InkWell(
          child: new ListTile(
            title: new Text((con.conversationType == RCConversationType.Private
                    ? "单聊："
                    : "群聊：") +
                con.targetId),
          ),
        ),
      ),
    );
  }

  void didTapItem(Conversation con) {
    selectConList.add(con);

    if (forwardType == 0) {
      sendMessageOneByOne();
    } else {
      // 合并转发
    }
  }

  void sendMessageOneByOne() {
    print("sendMessageOneByOne" +
        selectMessages.toString() +
        "转发的会话个数：" +
        selectConList.length.toString());
    // 这里不使用 loading，因为发消息时 sleep 会卡住动画
    DialogUtil.showAlertDiaLog(context, "消息转发中，请稍后...",
        confirmButton: FlatButton(onPressed: () {}, child: Text("")));
    sendMessage();
  }

  void sendMessage() async {
    Future.delayed(Duration(milliseconds: 400), () {
      for (Message msg in selectMessages) {
        for (Conversation con in selectConList) {
          // 转发时去掉消息原先携带的 sendUserInfo 和 mentionedInfo
          msg.content.sendUserInfo = null;
          msg.content.mentionedInfo = null;
          if (TargetPlatform.android == defaultTargetPlatform) {
            RongcloudImPlugin.forwardMessageByStep(con.conversationType,con.targetId,msg);
          } else {
            RongcloudImPlugin.sendMessage(
                con.conversationType, con.targetId, msg.content);
          }

          // 延迟400秒，防止过渡频繁的发送消息导致发送失败的问题
          sleep(Duration(milliseconds: 400));
        }
      }
      selectConList.clear();
      Navigator.pop(context);
      Navigator.pop(context);
      EventBus.instance.commit(EventKeys.ForwardMessageEnd, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(RCString.SelectConTitle),
        actions: <Widget>[
          // IconButton(
          //   icon: Icon(Icons.done),
          //   onPressed: () {
          //     // _pushToDebug();
          //   },
          // ),
        ],
      ),
      body: _buildConversationListView(),
    );
  }
}
