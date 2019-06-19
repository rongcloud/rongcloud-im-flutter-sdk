import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rc_chat_view.dart';
import 'package:rongcloud_im_plugin/rc_common_define.dart';

class ChatPage extends StatefulWidget {

  @override
  _ChatPageState createState() {
    return new _ChatPageState();
  }
  
}

class _ChatPageState extends State<ChatPage> {

  @override
  void initState() {
    super.initState();
  }

  RCChatViewController controller;
  
  void _onChatViewWidgetCreated(RCChatViewController _controller){
    controller = _controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text('Flutter QuickStart'),
        // ),
        backgroundColor: Colors.white,
        body: Center(
            child: Stack(
              children: <Widget>[
                new RCChatViewPage(
                 conversationType: RCConversationType.Private,
                  targetId: "asasdff",
                  onChatViewWidgetCreated: _onChatViewWidgetCreated,
                ),
              ],
            ) 
        ));
  }

  // new RCChatViewPage(
  //             conversationType: RCConversationType.Private,
  //             targetId: "asasdff",
  //             onChatViewWidgetCreated: _onChatViewWidgetCreated,
  //           ),
}