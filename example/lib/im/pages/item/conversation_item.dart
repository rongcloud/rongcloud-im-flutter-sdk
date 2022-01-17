import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart' as prefix;

import '../../util/style.dart';
import '../../util/user_info_datesource.dart' as example;
import 'message_item_factory.dart';
import 'widget_util.dart';

class ConversationItem extends StatefulWidget {
  late prefix.Message message;
  ConversationItemDelegate? delegate;
  bool? showTime;
  bool? multiSelect = false;
  List? selectedMessageIds;
  late _ConversationItemState state;
  ValueNotifier<int?> time = ValueNotifier<int?>(0);

  ConversationItem(ConversationItemDelegate delegate, prefix.Message msg, bool showTime, bool? multiSelect, List selectedMessageIds, ValueNotifier<int?> time) {
    this.message = msg;
    this.delegate = delegate;
    this.showTime = showTime;
    this.multiSelect = multiSelect;
    this.selectedMessageIds = selectedMessageIds;
    this.time = time;
  }

  @override
  State<StatefulWidget> createState() {
    return state = new _ConversationItemState(this.delegate, this.message, this.showTime, this.multiSelect, this.selectedMessageIds, this.time);
  }

  void refreshUI(prefix.Message message) {
    this.message = message;
    state._refreshUI(message);
  }
}

class _ConversationItemState extends State<ConversationItem> {
  String pageName = "example.ConversationItem";
  prefix.Message? message;
  ConversationItemDelegate? delegate;
  bool? showTime;
  example.UserInfo? user;
  Offset? tapPos;
  bool? multiSelect;
  bool isSeleceted = false;
  List? selectedMessageIds;
  SelectIcon? icon;

  ValueNotifier<int?> time = ValueNotifier<int>(0);
  bool needShowMessage = true;

  _ConversationItemState(ConversationItemDelegate? delegate, prefix.Message msg, bool? showTime, bool? multiSelect, List? selectedMessageIds, ValueNotifier<int?> time) {
    this.message = msg;
    this.delegate = delegate;
    this.showTime = showTime;
    // this.user = example.UserInfoDataSource.getUserInfo(msg.senderUserId);
    this.multiSelect = multiSelect;
    this.selectedMessageIds = selectedMessageIds;
    this.time = time;
    setInfo(message!.senderUserId);
    needShowMessage = !(msg.messageDirection == prefix.RCMessageDirection.Receive && msg.content != null && msg.content!.destructDuration != null && msg.content!.destructDuration! > 0 && time.value == msg.content!.destructDuration);
  }

  void setInfo(String? targetId) async {
    example.UserInfo? userInfo = example.UserInfoDataSource.cachedUserMap[targetId];
    if (userInfo != null) {
      this.user = userInfo;
    } else {
      example.UserInfo? userInfo = await example.UserInfoDataSource.getUserInfo(targetId);
      if (mounted) {
        setState(() {
          this.user = userInfo;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    bool isSelected = selectedMessageIds!.contains(message!.messageId);
    icon = SelectIcon(isSelected);
  }

  void _refreshUI(prefix.Message msg) {
    // setState(() {
    this.message = msg;
    // 撤回消息的时候因为是替换之前的消息 UI ，需要整个刷新 item
    if (msg.content is prefix.RecallNotificationMessage) {
      setState(() {});
    }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[this.showTime! ? WidgetUtil.buildMessageTimeWidget(message!.sentTime!) : WidgetUtil.buildEmptyWidget(), showMessage()],
      ),
    );
  }

  Widget showMessage() {
    //属于通知类型的消息
    if (message!.content is prefix.RecallNotificationMessage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          alignment: Alignment.center,
          width: RCLayout.MessageNotifiItemWidth,
          height: RCLayout.MessageNotifiItemHeight,
          color: Color(RCColor.MessageTimeBgColor),
          child: Text(
            RCString.ConRecallMessageSuccess,
            style: TextStyle(color: Colors.white, fontSize: RCFont.MessageNotifiFont),
          ),
        ),
      );
    } else {
      if (multiSelect == true) {
        return GestureDetector(
          child: Row(
            children: <Widget>[mutiSelectContent(), subContent()],
          ),
          onTap: () {
            __onTapedItem();
          },
        );
      } else {
        return GestureDetector(
          child: Row(
            children: <Widget>[subContent()],
          ),
        );
      }
    }
  }

  Widget _buildSendContent() {
    return Expanded(
        child: Row(
      children: [
        buildMessageWidget(),
        Column(
          children: [_buildUserName(), _buildUserPortrait()],
        ),
      ],
    ));
  }

  Widget _buildReceiveContent() {
    return Expanded(
        child: Row(
      children: [
        Column(
          children: [_buildUserName(), _buildUserPortrait()],
        ),
        buildMessageWidget(),
      ],
    ));
  }

  Widget _buildUserName() {
    return Container(
      // 名字
      alignment: Alignment.centerRight,
      child: Text((this.user == null || this.user!.id == null ? "" : this.user!.id!), style: TextStyle(fontSize: RCFont.MessageNameFont, color: Color(RCColor.MessageNameBgColor))),
    );
  }

  Widget _buildUserPortrait() {
    return GestureDetector(
      onTap: () {
        __onTapedUserPortrait();
      },
      child: WidgetUtil.buildUserPortrait(this.user?.portraitUrl),
    );
  }

  Widget subContent() {
    if (message!.messageDirection == prefix.RCMessageDirection.Send) {
      return _buildSendContent();
    } else if (message!.messageDirection == prefix.RCMessageDirection.Receive) {
      return _buildReceiveContent();
    } else {
      return WidgetUtil.buildEmptyWidget();
    }
  }

  Widget mutiSelectContent() {
    // 消息是否添加
    // final alreadySaved = _saved.contains(message);
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
      child: icon,
    );
  }

  void __onTapedItem() {
    if (delegate != null) {
      delegate!.didTapItem(message);
      bool isSelected = selectedMessageIds!.contains(message!.messageId);
      icon!.updateUI(isSelected);
    } else {
      developer.log("没有实现 ConversationItemDelegate", name: pageName);
    }
  }

  void __onTapedMesssage() {
    if (multiSelect == false) {
      prefix.RongIMClient.messageBeginDestruct(message!);
    }
    // return;
    if (delegate != null) {
      if (multiSelect == true) {
        //多选模式下修改为didTapItem处理
        delegate!.didTapItem(message);
        bool isSelected = selectedMessageIds!.contains(message!.messageId);
        icon!.updateUI(isSelected);
      } else {
        if (!needShowMessage) {
          needShowMessage = true;
          setState(() {});
        }
        delegate!.didTapMessageItem(message);
      }
    } else {
      developer.log("没有实现 ConversationItemDelegate", name: pageName);
    }
  }

  void __onTapedReadRequest() {
    if (delegate != null) {
      if (message!.readReceiptInfo != null && message!.readReceiptInfo!.isReceiptRequestMessage!) {
        delegate!.didTapMessageReadInfo(message);
      } else {
        delegate!.didSendMessageRequest(message);
      }
    } else {
      developer.log("没有实现 ConversationItemDelegate", name: pageName);
    }
  }

  void __onLongPressMessage(Offset? tapPos) {
    if (delegate != null) {
      delegate!.didLongPressMessageItem(message, tapPos);
    } else {
      developer.log("没有实现 ConversationItemDelegate", name: pageName);
    }
  }

  void __onTapedUserPortrait() {}

  void __onLongPressUserPortrait(Offset? tapPos) {
    if (delegate != null) {
      delegate!.didLongPressUserPortrait(this.user!.id, tapPos);
    } else {
      developer.log("没有实现 ConversationItemDelegate", name: pageName);
    }
  }

  Widget buildMessageContentWidget() {
    return Container();
  }

  Widget buildMessageWidget() {
    bool _isSend = message!.messageDirection == prefix.RCMessageDirection.Send;
    return Expanded(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              alignment: _isSend ? Alignment.centerRight : Alignment.centerLeft,
              child: Row(mainAxisAlignment: _isSend ? MainAxisAlignment.end : MainAxisAlignment.start, children: <Widget>[
                _isSend && message!.content != null && message!.content!.destructDuration != null && message!.content!.destructDuration! > 0
                    ? ValueListenableBuilder(
                        builder: (BuildContext context, int? value, Widget? child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              value! > 0
                                  ? Text(
                                      "$value ",
                                      style: TextStyle(color: Colors.red),
                                    )
                                  : Text("")
                            ],
                          );
                        },
                        valueListenable: time,
                      )
                    : Text(""),
                // sentStatus = 20 为发送失败
                _isSend && message!.sentStatus == 20
                    ? Container(
                        child: GestureDetector(
                            onTap: () {
                              if (delegate != null) {
                                if (multiSelect == true) {
                                  //多选模式下修改为didTapItem处理
                                  delegate!.didTapItem(message);
                                  bool isSelected = selectedMessageIds!.contains(message!.messageId);
                                  icon!.updateUI(isSelected);
                                } else {
                                  delegate!.didTapReSendMessage(message);
                                }
                              }
                            },
                            child: Image.asset(
                              "assets/images/rc_ic_warning.png",
                              width: RCLayout.MessageErrorHeight,
                              height: RCLayout.MessageErrorHeight,
                            )))
                    : WidgetUtil.buildEmptyWidget(),
                Container(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (TapDownDetails details) {
                      this.tapPos = details.globalPosition;
                    },
                    onTap: () {
                      __onTapedMesssage();
                    },
                    onLongPress: () {
                      __onLongPressMessage(this.tapPos);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: MessageItemFactory(message: message, needShow: needShowMessage),
                    ),
                  ),
                ),
                !_isSend && message!.content != null && message!.content!.destructDuration != null && message!.content!.destructDuration! > 0
                    ? ValueListenableBuilder(
                        builder: (BuildContext context, int? value, Widget? child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              value! > 0
                                  ? Text(
                                      " $value",
                                      style: TextStyle(color: Colors.red),
                                    )
                                  : Text("")
                            ],
                          );
                        },
                        valueListenable: time,
                      )
                    : Text(""),
              ]),
            ),
          )
        ],
      ),
    );
  }

  Text? buildReadInfo() {
    if (message!.conversationType == prefix.RCConversationType.Private) {
      if (message!.sentStatus == 50) {
        return Text("已读");
      }
      return Text("");
    } else if (message!.conversationType == prefix.RCConversationType.Group) {
      if (message!.readReceiptInfo != null && message!.readReceiptInfo!.isReceiptRequestMessage!) {
        if (message!.readReceiptInfo!.userIdList != null) {
          return Text("${message!.readReceiptInfo!.userIdList!.length}人已读");
        }
        return Text("0人已读");
      } else {
        if (canSendMessageReqdRequest()) {
          return Text("√");
        }
        return Text("");
      }
    }
  }

  bool canSendMessageReqdRequest() {
    DateTime time = DateTime.now();
    int nowTime = time.millisecondsSinceEpoch;
    if (nowTime - message!.sentTime! < 120 * 1000) {
      return true;
    }
    return false;
  }
}

abstract class ConversationItemDelegate {
  //点击 item
  void didTapItem(prefix.Message? message);

  //点击消息
  void didTapMessageItem(prefix.Message? message);

  //长按消息
  void didLongPressMessageItem(prefix.Message? message, Offset? tapPos);

  //点击用户头像
  void didTapUserPortrait(String userId);

  //长按用户头像
  void didLongPressUserPortrait(String? userId, Offset? tapPos);

  //发送消息已读回执请求
  void didSendMessageRequest(prefix.Message? message);

  //点击消息已读人数
  void didTapMessageReadInfo(prefix.Message? message);

  //点击消息已读人数
  void didTapReSendMessage(prefix.Message? message);
}

// 多选模式下 cell 显示的 Icon
class SelectIcon extends StatefulWidget {
  bool? isSelected;
  late _SelectIconState state;

  SelectIcon(bool isSelected) {
    this.isSelected = isSelected;
  }

  @override
  _SelectIconState createState() => state = _SelectIconState(isSelected);

  void updateUI(bool isSelected) {
    this.state.refreshUI(isSelected);
  }
}

class _SelectIconState extends State<SelectIcon> {
  bool? isSelected;

  _SelectIconState(bool? isSelected) {
    this.isSelected = isSelected;
  }

  void refreshUI(bool isSelected) {
    setState(() {
      this.isSelected = isSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      isSelected! ? Icons.radio_button_checked : Icons.radio_button_unchecked,
      size: 20,
    );
  }
}
