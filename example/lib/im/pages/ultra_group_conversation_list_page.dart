import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_im_plugin_example/im/pages/item/widget_util.dart';
import 'package:rongcloud_im_plugin_example/im/util/event_bus.dart';
import 'package:rongcloud_im_plugin_example/im/util/style.dart';

import 'item/conversation_list_item.dart';

class UltraGroupConversationListPage extends StatefulWidget {
  UltraGroupConversationListPage({Key? key}) : super(key: key);

  @override
  _UltraGroupConversationListPageState createState() => _UltraGroupConversationListPageState();
}

class _UltraGroupConversationListPageState extends State<UltraGroupConversationListPage> with AutomaticKeepAliveClientMixin implements ConversationListItemDelegate {
  ScrollController _scrollController = ScrollController();

  List _converstaionList = [];

  @override
  void initState() {
    super.initState();
    print("我在初始化");
    _updateConversationList();
    EventBus.instance!.addListener(EventKeys.ReceiveMessage, widget, (map) {
      Message msg = map["message"];
      int? left = map["left"];
      bool hasPackage = map["hasPackage"];
      print("超级群的会话列表在更新" + msg.messageId.toString());
      _updateConversationList();
    });
  }

  @override
  void didUpdateWidget(covariant UltraGroupConversationListPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    print("我更新了");
  }

  @override
  void dispose() {
    super.dispose();
    print("超级群会话页面我销毁了");

    EventBus.instance!.removeListener(EventKeys.ReceiveMessage, widget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    print("didChangeDependencies");
  }

  void _updateConversationList() async {
    print("我去拉一下数据");
    List? list = await RongIMClient.getConversationListByPage([10], 300, 0);
    if (list != null) {
      List ultraGroupList = [];
      list.forEach((element) async {
        List? l = await RongIMClient.getConversationListForAllChannel(element.conversationType, element.targetId);
        if (l != null) {
          l.forEach((element1) {
            RongIMClient.getUnreadCount(element1.conversationType, element1.targetId, (count, code) => {
              print("element1.targetId channel 未读数" + element1.targetId + " ${element1.channelId} " + count.toString())
            },element1.channelId);
          });
          ultraGroupList.addAll(l);
        }
        this.setState(() {
          _converstaionList = ultraGroupList;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("我在build");
    super.build(context);
    return Scaffold(
      key: UniqueKey(),
      appBar: AppBar(title: Text("超级群")),
      body: Container(
        child: _conversationList1(),
      ),
    );
  }

  Widget _conversationList1() {
    if (_converstaionList.length == 0) {
      return _buildEmptyWidget();
    }
    return _conversationList();
  }

  Widget _conversationList() {
    return Scrollbar(
        child: ListView.builder(
      controller: _scrollController,
      itemBuilder: (BuildContext context, int index) {
        return ConversationListItem(delegate: this, conversation: _converstaionList[index]);
      },
      itemCount: _converstaionList.length,
    ));
  }

  Widget _buildEmptyWidget() {
    return Container(
      child: GestureDetector(
        onTap: () {
          Conversation conversation = Conversation();
          conversation.conversationType = 10;
          conversation.targetId = "100";

          didTapConversation(conversation);
        },
        child: Text("data"),
      ),
    );
  }

  // @override
  bool get wantKeepAlive => true;

  @override
  void didLongPressConversation(Conversation? conversation, Offset? tapPos) {
    print("长按了会话 " + tapPos.toString());
    Map<String, String> actionMap = {RCLongPressAction.DeleteConversationKey: RCLongPressAction.DeleteConversationValue, RCLongPressAction.ClearUnreadKey: RCLongPressAction.ClearUnreadValue, RCLongPressAction.SetConversationToTopKey: conversation!.isTop! ? RCLongPressAction.CancelConversationToTopValue : RCLongPressAction.SetConversationToTopValue};
    WidgetUtil.showLongPressMenu(context, tapPos!, actionMap, (String? key) {
      if (key == RCLongPressAction.DeleteConversationKey) {
        if(conversation.channelId == "") {
          Fluttertoast.showToast(msg: "主频道当前 UI 不支持删除");
          return;
        }
        RongIMClient.removeConversation(conversation.conversationType!, conversation.targetId!, (success) => {_updateConversationList(), Fluttertoast.showToast(msg: RCLongPressAction.DeleteConversationKey)}, conversation.channelId!);
      } else if (key == RCLongPressAction.DeleteConversationValue) {
        // _recallMessage(message);

        Fluttertoast.showToast(msg: RCLongPressAction.DeleteConversationValue);
      } else if (key == RCLongPressAction.ClearUnreadKey) {
        RongIMClient.clearMessagesUnreadStatus(conversation.conversationType!, conversation.targetId!,conversation.channelId!);
        Fluttertoast.showToast(msg: RCLongPressAction.ClearUnreadKey);
      } else if (key == RCLongPressAction.SetConversationToTopKey) {
        Fluttertoast.showToast(msg: RCLongPressAction.SetConversationToTopKey);
      }
      // developer.log("当前选中的是 " + key!, name: pageName);
    });
  }

  @override
  void didTapConversation(Conversation? conversation) {
    Map arg = {"coversationType": conversation!.conversationType, "targetId": conversation.targetId, "channelId": conversation.channelId};
    Navigator.pushNamed(context, "/conversation", arguments: arg).then((value) => {_updateConversationList()});
  }
}
