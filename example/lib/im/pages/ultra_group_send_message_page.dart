import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart' as rong;

class UltraGroupSendMessagePage extends StatefulWidget {
  const UltraGroupSendMessagePage({Key? key}) : super(key: key);

  @override
  _UltraGroupSendMessagePageState createState() => _UltraGroupSendMessagePageState();
}

class _UltraGroupSendMessagePageState extends State<UltraGroupSendMessagePage> {
  String targetId = '';
  String channelId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("给会话发送消息"),
      ),
      body: Container(
        child: Column(
          children: [
            TextField(
              onChanged: (value) => targetId = value,
              decoration: InputDecoration(labelText: "请输入targetId"),
            ),
            TextField(
              onChanged: (value) => channelId = value,
              decoration: InputDecoration(labelText: "请输入channelId"),
            ),
            MaterialButton(
              onPressed: _sendMsg,
              child: Text("发送消息"),
              color: Colors.blue,
            )
          ],
        ),
      ),
    );
  }

  _sendMsg() {
    rong.TextMessage msg = rong.TextMessage.obtain("你好，新朋友");
    rong.RongIMClient.sendMessage(10, targetId, msg, channelId: channelId);
  }
}
