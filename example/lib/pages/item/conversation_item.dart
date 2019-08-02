import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'user_portrait.dart';
import 'message_item_factory.dart';

class ConversationItem extends StatefulWidget {
  Message message ;
  ConversationItemDelegate delegate;

  ConversationItem(Message msg,ConversationItemDelegate delegate) {
    this.message = msg;
    this.delegate = delegate;
  }

  @override
  State<StatefulWidget> createState() {
    return new _ConversationItemState(message,this.delegate);
  }
}

class _ConversationItemState extends State<ConversationItem> {
  Message message;
  ConversationItemDelegate delegate;

  _ConversationItemState(Message msg,ConversationItemDelegate delegate) {
    this.message = msg;
    this.delegate = delegate;
  }

  @override
  Widget build(BuildContext context) {
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

  void __onTapedMesssage() {
    if(delegate != null) {
      delegate.didTapMessageItem(message);
    }
  }

  Widget textContent() {
    // TextMessage txtMsg = message.content;
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
            alignment: message.messageDirection == 1
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                __onTapedMesssage();
              },
              child:MessageItemFactory(message: message) ,
            )
          ),
        )
      ],
    );
  }
}

abstract class ConversationItemDelegate {
  void didTapMessageItem(Message message);
}