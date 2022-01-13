import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/src/info/conversation.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_im_plugin_example/im/util/event_bus.dart';
import 'package:rongcloud_im_plugin_example/user_data.dart';

import 'item/conversation_list_item.dart';

class UltraGroupConversationListPage extends StatefulWidget {
  UltraGroupConversationListPage({Key? key}) : super(key: key);

  @override
  _UltraGroupConversationListPageState createState() => _UltraGroupConversationListPageState();
}

class _UltraGroupConversationListPageState extends State<UltraGroupConversationListPage>
    with AutomaticKeepAliveClientMixin
    implements ConversationListItemDelegate {
  ScrollController _scrollController = ScrollController();

  List _converstaionList = [];

  @override
  void initState() {
    super.initState();
    print("我在初始化");
    _updateConversationList();
    EventBus.instance!.addListener(EventKeys.ReceiveMessage, (map) {
      Message msg = map["message"];
      int? left = map["left"];
      bool hasPackage = map["hasPackage"];

      _updateConversationList();
    });
  }

  @override
  void didUpdateWidget(covariant UltraGroupConversationListPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    print("我更新了");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    print("didChangeDependencies");
  }

  void _updateConversationList() async {
    print("我去拉一下数据");
    List? list = await RongIMClient.getConversationList([10]);
    if (list != null) {
      this.setState(() {
        _converstaionList = list;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("我重建了1");
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
      child: Text("我没有数据啊"),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void didLongPressConversation(Conversation? conversation, Offset? tapPos) {
    // TODO: implement didLongPressConversation
  }

  @override
  void didTapConversation(Conversation? conversation) {
    Map arg = {
      "coversationType": conversation!.conversationType,
      "targetId": conversation.targetId,
      "channelId": conversation.channelId
    };
    Navigator.pushNamed(context, "/conversation", arguments: arg);
  }
}
