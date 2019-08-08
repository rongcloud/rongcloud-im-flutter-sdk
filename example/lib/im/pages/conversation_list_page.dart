
import 'dart:async';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'item/widget_util.dart';
import 'item/conversation_list_item.dart';

import '../util/style.dart';
import '../util/event_bus.dart';

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

    EventBus.instance.addListener(EventKeys.ConversationPageDispose, (arg) {
      Timer(Duration(milliseconds:10), (){
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
    List list = await RongcloudImPlugin.getConversationList([RCConversationType.Private,RCConversationType.Group]);
    if(list != null) {
      list.sort((a,b) => b.sentTime.compareTo(a.sentTime));
      conList = list;
    }
    _renfreshUI();
  }

  void _renfreshUI() {
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

  void _deleteConversation(Conversation conversation) {
    //删除会话需要刷新会话列表数据
    RongcloudImPlugin.removeConversation(conversation.conversationType, conversation.targetId, (bool success) {
      if(success) {
        RongcloudImPlugin.deleteMessages(conversation.conversationType, conversation.targetId, (int code) {
          updateConversationList();
          _renfreshUI();
        });
      }
    });
  }

  void _clearConversationUnread(Conversation conversation) async {
    //清空未读需要刷新会话列表数据
    bool success = await RongcloudImPlugin.clearMessagesUnreadStatus(conversation.conversationType, conversation.targetId);
    if(success) {
      updateConversationList();
      _renfreshUI();
    }
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
      if(key == RCLongPressAction.DeleteConversationKey) {
        _deleteConversation(conversation);
      }else if(key == RCLongPressAction.ClearUnreadKey) {
        _clearConversationUnread(conversation);
      }else {
        print("未实现操作 "+key);
      }
    });
  }

  @override
  void didTapConversation(Conversation conversation) {
    Map arg = {"coversationType":conversation.conversationType,"targetId":conversation.targetId};
    Navigator.pushNamed(context, "/conversation",arguments: arg);
  }
  
}