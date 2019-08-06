import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'dart:convert';
import 'dart:typed_data';

class MessageItemFactory extends StatelessWidget {
  final Message message;
  const MessageItemFactory({Key key, this.message}) : super(key: key);

  Widget textMessageItem() {
    TextMessage msg = message.content;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(8),
        color: Color(0xffD3D3D3),
        child: Text(msg.content),
      ),
    );
  }

  Widget imageMessageItem() {
    ImageMessage msg = message.content;
    
    Widget widget;
    if (msg.content != null && msg.content.length > 0) {
      Uint8List bytes = base64.decode(msg.content);
      widget = Image.memory(bytes);
    } else {
      widget = Container(
        height: 200,
        width: 200,
        color: Colors.grey[100],
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: widget,
    );
  }

  Widget voiceMessageItem() {
    VoiceMessage msg = message.content;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 80,
        height: 44,
        color: Color(0xffD3D3D3),
        child: Text(msg.duration.toString()+"'s"),
      ),
    );
  }

  Widget messageItem() {
    if (message.content is TextMessage) {
      return textMessageItem();
    } else if (message.content is ImageMessage){
      return imageMessageItem();
    } else if (message.content is VoiceMessage) {
      return voiceMessageItem();
    } else {
      return Text("无法识别消息 "+message.content.getObjectName());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: messageItem(),
    );
  }
}
