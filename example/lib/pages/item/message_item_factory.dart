import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

class MessageItemFactory extends StatelessWidget {
  final Message message;
  const MessageItemFactory({Key key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget textMessageItem() {
      TextMessage msg = message.content;
      return RichText(
        text: TextSpan(
            text: '${msg.content}', style: TextStyle(color: Colors.red)),
        softWrap: true,
      );
    }

    Widget imageMessageItem() {
      ImageMessage msg = message.content;

      if (msg.content != null && msg.content.length > 0) {
        Uint8List bytes = base64.decode(msg.content);
        return Image.memory(bytes);
      } else {
        return Container(
          height: 200,
          width: 200,
          color: Colors.grey[100],
        );
      }
    }

    Widget messageItem() {
      if (message.content is TextMessage) {
        return textMessageItem();
      } else {
        return imageMessageItem();
      }
    }

    return Container(
      color: Colors.blue,
      child: messageItem(),
    );
  }
}
