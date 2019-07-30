import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class BottomInputBar extends StatefulWidget {
  @override
  _BottomInputBarState createState() => _BottomInputBarState();
}

class _BottomInputBarState extends State<BottomInputBar> {
  void _clickSendMessage(String messageStr) {
    if (messageStr == null || messageStr.length <= 0) {
      print('不能为空');
      return;
    }
    TextMessage msg = new TextMessage();
    msg.content = messageStr;
    RongcloudImPlugin.sendMessage(RCConversationType.Private, '2002', msg);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
        color: Colors.yellow,
        padding: EdgeInsets.fromLTRB(30, 20, 30, 10),
        child: TextField(onSubmitted: _clickSendMessage),
        );
  }
}
