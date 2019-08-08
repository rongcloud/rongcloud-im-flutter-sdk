
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'item/widget_util.dart';
import '../util/style.dart';
import 'item/conversation_list_item.dart';

class ConversationListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _ConversationListPageState();
  }
}

class _ConversationListPageState extends State<ConversationListPage> implements ConversationListItemDelegate{

  List conList = new List();

  @override
  void initState() {
    super.initState();
    addIMhandler();
    updateConversationList();
  }

  updateConversationList() async {
    List list = await RongcloudImPlugin.getConversationList([RCConversationType.Private,RCConversationType.Group]);
    if(list != null) {
      list.sort((a,b) => b.sentTime.compareTo(a.sentTime));
      conList = list;
    }
    setState(() {
      
    });
  }

  addIMhandler() {
    RongcloudImPlugin.onMessageReceived = (Message msg, int left) {
      if(left == 0) {
        updateConversationList();
      }
    };

    RongcloudImPlugin.onConnectionStatusChange = (int connectionStatus) {
      if(RCConnectionStatus.Connected == connectionStatus) {
        updateConversationList();
      }
    };
  }

  Widget _buildConversationListView() {
    return new ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: conList.length,
      itemBuilder: (BuildContext context,int index) {
        if(conList.length <= 0) {
          return WidgetUtil.buildEmptyWidget();
        }
        return ConversationListItem(delegate:this,conversation:conList[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: UniqueKey(),
      body: _buildConversationListView(),
    );
  }

  @override
  void didLongPressConversation(Conversation conversation,Offset tapPos) {
    Map<String,String> actionMap = {
      RCLongPressAction.DeleteConversationKey:RCLongPressAction.DeleteConversationValue,
      RCLongPressAction.ClearUnreadKey:RCLongPressAction.ClearUnreadValue
    };
    WidgetUtil.showLongPressMenu(context, tapPos,actionMap,(String key) {
      print("当前选中的是 "+ key);
    });
  }

  @override
  void didTapConversation(Conversation conversation) {
    Map arg = {"coversationType":conversation.conversationType,"targetId":conversation.targetId};
    Navigator.pushNamed(context, "/conversation",arguments: arg);
  }
  
}