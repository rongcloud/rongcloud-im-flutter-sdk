
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_im_plugin_example/pages/item/widget_util.dart';
import 'item/conversation_list_item.dart';

class ConversationListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _ConversationListPageState();
  }
}

class _ConversationListPageState extends State<ConversationListPage> implements ConversationListItemDelegate{

  List conList = new List();
  bool needShowConversationDialog = false;

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

  Widget _buildConversationDialog() {
    if(needShowConversationDialog) {
      return WidgetUtil.buildLongPressDialog(["清除未读","删除会话"],(int index){
        //todo
        print("_buildConversationDialog "+index.toString());
        _showConversationDialog(false);
      });
    }else {
      return WidgetUtil.buildEmptyWidget();
    }
  }

  Widget _buildConversationListView() {
    return Stack(
      children: <Widget>[
        new ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: conList.length,
          itemBuilder: (BuildContext context,int index) {
            if(conList.length <= 0) {
              return Container();
            }
            return ConversationListItem(delegate:this,conversation:conList[index]);
          },
        ),
        _buildConversationDialog(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: UniqueKey(),
      body: _buildConversationListView(),
    );
  }

  void _showConversationDialog(bool show) {
    this.needShowConversationDialog = show;
    setState(() {
      
    });
  }

  @override
  void didLongPressConversation(Conversation conversation) {
    print("didLongPressConversation");
    _showConversationDialog(true);
  }

  @override
  void didTapConversation(Conversation conversation) {
    Map arg = {"coversationType":conversation.conversationType,"targetId":conversation.targetId};
    Navigator.pushNamed(context, "/conversation",arguments: arg);
  }
  
}