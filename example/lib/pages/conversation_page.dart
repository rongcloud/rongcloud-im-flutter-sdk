import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'item/conversation_item.dart';
import 'item/bottom_inputBar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_sound/flutter_sound.dart';

class ConversationPage extends StatefulWidget {
  final Map arguments;
  ConversationPage({Key key, this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _ConversationPageState(arguments: this.arguments);
}

class _ConversationPageState extends State<ConversationPage> implements ConversationItemDelegate,BottomInputBarDelegate {
  Map arguments;
  int conversationType;
  String targetId;
  List msgList = new List();
  _ConversationPageState({this.arguments});
  ScrollController _controller = ScrollController();
  @override
  void initState() {
    super.initState();
    conversationType = arguments["coversationType"];
    targetId = arguments["targetId"];
    _addIMHandler();
    onGetHistoryMessages();
    _controller.addListener(() {
      print(
          'scroller 最大值 addListener maxScrollExtent${_controller.position.maxScrollExtent}');
      print('scroller 最大值 addListener pixels${_controller.position.pixels}');
    });
    print("get history message11111");
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('scroller 最大值 oldWidget ${_controller.position.maxScrollExtent}');
  }

  _addIMHandler() {
    RongcloudImPlugin.onMessageReceived = (Message msg, int left) {
      if (msg.targetId == this.targetId) {
        msgList.add(msg);
      }
      //  _controller.jumpTo(0);
      setState(() {});
      _scrollToBottom(100);
    };

    RongcloudImPlugin.onMessageSend = (int messageId, int status, int code) async {
      Message msg = await RongcloudImPlugin.getMessage(messageId);
      if(msg.targetId == this.targetId) {
        msgList.add(msg);
      }

      setState(() {});
      _scrollToBottom(100);
    };
  }

  RefreshController _refreshController = RefreshController();

  onGetHistoryMessages() async {
    List msgs = await RongcloudImPlugin.getHistoryMessage(
        conversationType, targetId, 0, 20);
    print("get history message");

    List msg = new List();

    for (Message m in msgs) {
      msg.insert(0, m);
    }
    print(msg);

    setState(() {
      msgList = msg;
      print('scroller   setState 1${_controller.position.maxScrollExtent}');
    });

    print(
        'scroller 最大值onGetHistoryMessages ${_controller.position.maxScrollExtent}');
    // _controller.jumpTo(_controller.position.maxScrollExtent);

    _scrollToBottom(10);
  }

  void _scrollToBottom(int milliseconds) {
    Timer(Duration(milliseconds: milliseconds),
        () => _controller.jumpTo(_controller.position.maxScrollExtent));
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    //  msgList.add(msgList[0]);
    setState(() {});
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    // items.add((items.length+1).toString());
    // if(mounted)

    msgList.add(msgList[0]);
    setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('与${targetId}的会话'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SmartRefresher(
              enablePullDown: true,

              onRefresh: _onRefresh,
              child: ListView.builder(
                key: UniqueKey(),
                controller: _controller,
                itemCount: msgList.length,
                itemBuilder: (BuildContext context, int index) {
                  if (msgList.length != null && msgList.length > 0) {
                    return ConversationItem(msgList[index],this);
                  } else {
                    return null;
                  }
                },
              ),
              controller: _refreshController,
            ),
          ),
          Container(
            height: 70,
            child: BottomInputBar(this),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _refreshController.dispose();
    super.dispose();
  }

  @override
  void didTapMessageItem(Message message) {
    print("didTapMessageItem "+message.content.getObjectName());
    if(message.content is VoiceMessage) {
      VoiceMessage msg = message.content;
      FlutterSound flutterSound = new FlutterSound();
      flutterSound.startPlayer(msg.remoteUrl);
    }
  }

  @override
  void willSendText(String text) {
    TextMessage msg = new TextMessage();
    msg.content = text;
    RongcloudImPlugin.sendMessage(conversationType, targetId, msg);
  }
}
