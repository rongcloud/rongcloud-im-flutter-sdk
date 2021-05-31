import 'dart:async';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'item/widget_util.dart';
import 'item/conversation_list_item.dart';

import '../util/style.dart';
import '../util/event_bus.dart';
import '../util/dialog_util.dart';
import '../../other/login_page.dart';
import 'dart:developer' as developer;

class ConversationListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _ConversationListPageState();
  }
}

class _ConversationListPageState extends State<ConversationListPage>
    implements ConversationListItemDelegate {
  String pageName = "example.ConversationListPage";
  List conList = [];
  List<int> displayConversationType = [
    RCConversationType.Private,
    RCConversationType.Group
  ];
  ScrollController _scrollController;
  double mPosition = 0;

  @override
  void initState() {
    super.initState();
    addIMhandler();
    updateConversationList();

    EventBus.instance.addListener(EventKeys.ConversationPageDispose, (arg) {
      Timer(Duration(milliseconds: 10), () {
        addIMhandler();
        updateConversationList();
        _renfreshUI();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    EventBus.instance.removeListener(EventKeys.ConversationPageDispose);
  }

  updateConversationList() async {
    List list = await RongIMClient.getConversationList(displayConversationType);
    if (list != null) {
      // list.sort((a,b) => b.sentTime.compareTo(a.sentTime));
      conList = list;
    }
    _renfreshUI();
  }

  void _renfreshUI() {
    setState(() {});
  }

  addIMhandler() {
    EventBus.instance.addListener(EventKeys.ReceiveMessage, (map) {
      Message msg = map["message"];
      int left = map["left"];
      bool hasPackage = map["hasPackage"];
      bool isDisplayConversation = msg.conversationType != null &&
          displayConversationType.contains(msg.conversationType);
      //如果离线消息过多，那么可以等到 hasPackage 为 false 并且 left == 0 时更新会话列表
      if (!hasPackage && left == 0 && isDisplayConversation) {
        updateConversationList();
      }
    });

    RongIMClient.onConnectionStatusChange = (int connectionStatus) {
      if (RCConnectionStatus.KickedByOtherClient == connectionStatus ||
          RCConnectionStatus.TokenIncorrect == connectionStatus ||
          RCConnectionStatus.UserBlocked == connectionStatus) {
        String toast = "连接状态变化 $connectionStatus, 请退出后重新登录";
        DialogUtil.showAlertDiaLog(context, toast,
            confirmButton: TextButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove("token");
                  Navigator.of(context).pushAndRemoveUntil(
                      new MaterialPageRoute(
                          builder: (context) => new LoginPage()),
                      (route) => route == null);
                },
                child: Text("重新登录")));
      } else if (RCConnectionStatus.Connected == connectionStatus) {
        updateConversationList();
      }
    };

    RongIMClient.onRecallMessageReceived = (Message message) {
      updateConversationList();
    };

    RongIMClient.onDatabaseOpened = (int status) {
      updateConversationList();
    };
  }

  void _deleteConversation(Conversation conversation) {
    //删除会话需要刷新会话列表数据
    RongIMClient.removeConversation(
        conversation.conversationType, conversation.targetId, (bool success) {
      if (success) {
        updateConversationList();
        // // 如果需要删除会话中的消息调用下面的接口
        // RongIMClient.deleteMessages(
        //     conversation.conversationType, conversation.targetId, (int code) {
        //   updateConversationList();
        // });
      }
    });
  }

  void _clearConversationUnread(Conversation conversation) async {
    //清空未读需要刷新会话列表数据
    bool success = await RongIMClient.clearMessagesUnreadStatus(
        conversation.conversationType, conversation.targetId);
    if (success) {
      updateConversationList();
    }
  }

  void _setConversationToTop(Conversation conversation, bool isTop) {
    RongIMClient.setConversationToTop(
        conversation.conversationType, conversation.targetId, isTop,
        (bool status, int code) {
      if (code == 0) {
        updateConversationList();
      }
    });
  }

  void _addScroolListener() {
    _scrollController.addListener(() {
      mPosition = _scrollController.position.pixels;
    });
  }

  Widget _buildConversationListView() {
    return new ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: conList.length,
      controller: _scrollController,
      itemBuilder: (BuildContext context, int index) {
        if (conList.length <= 0) {
          return WidgetUtil.buildEmptyWidget();
        }
        return ConversationListItem(
            delegate: this, conversation: conList[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    this._scrollController = ScrollController(initialScrollOffset: mPosition);
    _addScroolListener();
    return new Scaffold(
      appBar: AppBar(
        title: Text("RongCloud IM"),
      ),
      key: UniqueKey(),
      body: _buildConversationListView(),
    );
  }

  @override
  void didLongPressConversation(Conversation conversation, Offset tapPos) {
    Map<String, String> actionMap = {
      RCLongPressAction.DeleteConversationKey:
          RCLongPressAction.DeleteConversationValue,
      RCLongPressAction.ClearUnreadKey: RCLongPressAction.ClearUnreadValue,
      RCLongPressAction.SetConversationToTopKey: conversation.isTop
          ? RCLongPressAction.CancelConversationToTopValue
          : RCLongPressAction.SetConversationToTopValue
    };
    WidgetUtil.showLongPressMenu(context, tapPos, actionMap, (String key) {
      developer.log("当前选中的是 " + key, name: pageName);
      if (key == RCLongPressAction.DeleteConversationKey) {
        _deleteConversation(conversation);
      } else if (key == RCLongPressAction.ClearUnreadKey) {
        _clearConversationUnread(conversation);
      } else if (key == RCLongPressAction.SetConversationToTopKey) {
        bool isTop = true;
        if (conversation.isTop) {
          isTop = false;
        }
        _setConversationToTop(conversation, isTop);
      } else {
        developer.log("未实现操作 " + key, name: pageName);
      }
    });
  }

  @override
  void didTapConversation(Conversation conversation) {
    Map arg = {
      "coversationType": conversation.conversationType,
      "targetId": conversation.targetId
    };
    Navigator.pushNamed(context, "/conversation", arguments: arg);
  }
}
