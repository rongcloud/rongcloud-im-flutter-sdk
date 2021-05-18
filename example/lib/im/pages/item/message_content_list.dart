import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:flutter/material.dart';
import '../../util/bloc/message_bloc.dart';

import '../../util/time.dart';
import 'conversation_item.dart';
import 'widget_util.dart';
import '../../util/event_bus.dart';

class MessageContentList extends StatefulWidget {
  MessageContentListDelegate delegate;
  List messageDataSource = [];
  bool multiSelect;
  List selectedMessageIds = [];
  _MessageContentListState state;
  Map burnMsgMap = Map();
  MessageContentList(
      List messageDataSource,
      bool multiSelect,
      List selectedMessageIds,
      MessageContentListDelegate delegate,
      Map burnMsgMap) {
    this.delegate = delegate;
    this.messageDataSource = messageDataSource;
    this.multiSelect = multiSelect;
    this.selectedMessageIds = selectedMessageIds;
    this.burnMsgMap = burnMsgMap;
  }

  void updateData(
      List messageDataSource, bool multiSelect, List selectedMessageIds) {
    // this.state._refreshUI(messageDataSource, multiSelect, selectedMessageIds);
    this.state.updateData(messageDataSource, multiSelect, selectedMessageIds);
  }

  void refreshItem(Message msg) {
    this.state._refrshItem(msg);
  }

  @override
  State<StatefulWidget> createState() {
    return state = _MessageContentListState(messageDataSource, multiSelect,
        selectedMessageIds, delegate, burnMsgMap);
  }
}

class _MessageContentListState extends State<MessageContentList>
    implements ConversationItemDelegate {
  MessageContentListDelegate delegate;
  List messageDataSource = [];
  ScrollController _scrollController;
  bool multiSelect;
  double mPosition = 0;
  List selectedMessageIds = [];
  MessageBloc _bloc;
  // StreamController<List> streamController = new StreamController();
  Map conversationItems = Map();
  Map burnMsgMap = Map();

  _MessageContentListState(
      List messageDataSource,
      bool multiSelect,
      List selectedMessageIds,
      MessageContentListDelegate delegate,
      Map burnMsgMap) {
    this.delegate = delegate;
    this.messageDataSource = messageDataSource;
    this.multiSelect = multiSelect;
    this.selectedMessageIds = selectedMessageIds;
    this.burnMsgMap = burnMsgMap;
    // this._scrollController = ScrollController();
    // updateData(messageDataSource);
  }

  void updateData(
      List messageDataSource, bool multiSelect, List selectedMessageIds) {
    // streamController.sink.add(messageDataSource);
    _bloc.updateMessageList(messageDataSource);
    this.messageDataSource = messageDataSource;
    this.multiSelect = multiSelect;
    this.selectedMessageIds = selectedMessageIds;
  }

  @override
  void initState() {
    _bloc = new MessageBloc();
    super.initState();

    EventBus.instance.addListener(EventKeys.BurnMessage, (map) {
      int messageId = map["messageId"];
      int remainDuration = map["remainDuration"];
      ConversationItem item = conversationItems[messageId];
      item.time.value = remainDuration;
    });
  }

  @override
  void dispose() {
    // streamController.sink.close();
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // mPosition 不是特别准确，可能导致有偏移
    this._scrollController = ScrollController(initialScrollOffset: mPosition);
    _addScroolListener();
    return StreamBuilder<MessageInfoWrapState>(
        stream: _bloc.outListData,
        builder: (ctx, AsyncSnapshot<MessageInfoWrapState> snapshot) {
          MessageInfoWrapState messageInfoWrapState = snapshot.data;
          if (messageInfoWrapState == null) {
            return WidgetUtil.buildEmptyWidget();
          }
          List messageDataSource = messageInfoWrapState.messageList;
          if (messageDataSource == null) {
            messageDataSource = List();
          }
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
                  int destructDuration = tempMessage.content != null &&
                          tempMessage.content.destructDuration != null
                      ? tempMessage.content.destructDuration
                      : 0;
                  ValueNotifier<int> time =
                      ValueNotifier<int>(destructDuration);
                  if (burnMsgMap[tempMessage.messageId] != null) {
                    time.value = burnMsgMap[tempMessage.messageId];
                  }
                  ConversationItem item = ConversationItem(
                      this,
                      tempMessage,
                      _needShowTime(index, messageDataSource),
                      this.multiSelect,
                      selectedMessageIds,
                      time);
                  conversationItems[tempMessage.messageId] = item;
                  return item;
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
        });
  }

  void _addScroolListener() {
    _scrollController.addListener(() {
      mPosition = _scrollController.position.pixels;
      //此处要用 == 而不是 >= 否则会触发多次
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        delegate.willpullMoreHistoryMessage();
        setState(() {});
      }
    });
  }

  bool _needShowTime(int index, List messageDataSource) {
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

  void _refrshItem(Message msg) {
    ConversationItem item = conversationItems[msg.messageId];
    item?.refreshUI(msg);
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

  @override
  void didTapReSendMessage(Message message) {
    delegate.didTapReSendMessage(message);
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

  void didTapReSendMessage(Message message);
}
