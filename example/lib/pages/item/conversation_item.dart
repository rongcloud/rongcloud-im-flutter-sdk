import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'user_portrait.dart';

class ConversationItem extends StatefulWidget {
  Message message = null;

  ConversationItem(Message msg) {
    message = msg;
  }

  @override
  State<StatefulWidget> createState() {
    return new _ConversationItemState(message);
  }
}

class _ConversationItemState extends State<ConversationItem> {
  Message message = null;

  _ConversationItemState(Message msg) {
    message = msg;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return backgroundContent();
  }

  Widget subContent() {
    if (message.messageDirection == 1) {
      return Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: textContent(),
            ),
            Portrait(),
          ],
        ),
      );
    } else if (message.messageDirection == 2) {
      return Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Portrait(),
            Expanded(
              child: textContent(),
            )
          ],
        ),
      );
    }
  }

  Widget backgroundContent() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[subContent()],
      ),
    );
  }

  Widget textContent() {
    TextMessage txtMsg = message.content;
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
            alignment: message.messageDirection == 1
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                  text: '${txtMsg.content}',
                  style: TextStyle(color: Colors.red)),
              softWrap: true,
            ),
          ),
        )
      ],
    );
  }
}
