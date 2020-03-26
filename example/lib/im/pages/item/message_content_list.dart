import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:flutter/material.dart';

import '../../util/time.dart';
import 'conversation_item.dart';
import 'widget_util.dart';

class MessageContentList extends StatefulWidget {
  MessageContentListDelegate delegate;
  List messageDataSource = new List();
  bool multiSelect;
  List selectedMessageIds = new List();
  _MessageContentListState state;
  MessageContentList(List messageDataSource, bool multiSelect,
      List selectedMessageIds, MessageContentListDelegate delegate) {
    this.delegate = delegate;
    this.messageDataSource = messageDataSource;
    this.multiSelect = multiSelect;
    this.selectedMessageIds = selectedMessageIds;
  }

  void updateData(
      List messageDataSource, bool multiSelect, List selectedMessageIds) {
    this.state._refreshUI(messageDataSource, multiSelect, selectedMessageIds);
  }

  @override
  State<StatefulWidget> createState() {
    return state = _MessageContentListState(
        messageDataSource, multiSelect, selectedMessageIds, delegate);
  }
}

class _MessageContentListState extends State<MessageContentList>
    implements ConversationItemDelegate {
  MessageContentListDelegate delegate;
  List messageDataSource = new List();
  ScrollController _scrollController;
  bool multiSelect;
  double mPosition = 0;
  List selectedMessageIds = new List();

  _MessageContentListState(List messageDataSource, bool multiSelect,
      List selectedMessageIds, MessageContentListDelegate delegate) {
    this.delegate = delegate;
    this.messageDataSource = messageDataSource;
    this.multiSelect = multiSelect;
    this.selectedMessageIds = selectedMessageIds;
    // this._scrollController = ScrollController();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    this._scrollController = ScrollController(initialScrollOffset: mPosition);
    _addScroolListener();
    return ListView.separated(
        key: UniqueKey(),
        shrinkWrap: true,
        //因为消息超过一屏，ListView 很难滚动到最底部，所以要翻转显示，同时数据源也要逆序
        reverse: true,
        controller: _scrollController,
        itemCount: messageDataSource.length,
        itemBuilder: (BuildContext context, int index) {
          if (messageDataSource.length != null &&
              messageDataSource.length > 0) {
            Message tempMessage = messageDataSource[index];
            // bool isSelected = selectedMessageIds.contains(tempMessage.messageId);
            return ConversationItem(this, tempMessage, _needShowTime(index),
                this.multiSelect, selectedMessageIds);
          } else {
            return WidgetUtil.buildEmptyWidget();
          }
        },
        separatorBuilder: (BuildContext context, int index) {
          return Container(
            height: 10,
            width: 1,
          );
        });
  }

  void _addScroolListener() {
    _scrollController.addListener(() {
      //此处要用 == 而不是 >= 否则会触发多次
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        delegate.willpullMoreHistoryMessage();
      }
      mPosition = _scrollController.position.pixels;
    });
  }

  bool _needShowTime(int index) {
    bool needShow = false;
    //消息是逆序的
    if (index == messageDataSource.length - 1) {
      //第一条消息一定显示时间
      needShow = true;
    } else {
      //如果满足条件，则显示时间
      Message lastMessage = messageDataSource[index + 1];
      Message curMessage = messageDataSource[index];
      if (TimeUtil.needShowTime(lastMessage.sentTime, curMessage.sentTime)) {
        needShow = true;
      }
    }
    return needShow;
  }

  void _refreshUI(
      List messageDataSource, bool multiSelect, List selectedMessageIds) {
    setState(() {
      this.messageDataSource = messageDataSource;
      this.multiSelect = multiSelect;
      this.selectedMessageIds = selectedMessageIds;
    });
  }

  @override
  void didLongPressMessageItem(Message message, Offset tapPos) {
    delegate.didLongPressMessageItem(message, tapPos);
  }

  @override
  void didLongPressUserPortrait(String userId, Offset tapPos) {
    delegate.didLongPressUserPortrait(userId, tapPos);
  }

  @override
  void didSendMessageRequest(Message message) {
    delegate.didSendMessageRequest(message);
  }

  @override
  void didTapItem(Message message) {
    delegate.didTapItem(message);
  }

  @override
  void didTapMessageItem(Message message) {
    delegate.didTapMessageItem(message);
  }

  @override
  void didTapMessageReadInfo(Message message) {
    delegate.didTapMessageReadInfo(message);
  }

  @override
  void didTapUserPortrait(String userId) {
    delegate.didTapUserPortrait(userId);
  }
}

abstract class MessageContentListDelegate {
  void willpullMoreHistoryMessage();

  void didLongPressMessageItem(Message message, Offset tapPos);

  void didLongPressUserPortrait(String userId, Offset tapPos);

  void didSendMessageRequest(Message message);

  void didTapItem(Message message);

  void didTapMessageItem(Message message);

  void didTapMessageReadInfo(Message message);

  void didTapUserPortrait(String userId);
}
