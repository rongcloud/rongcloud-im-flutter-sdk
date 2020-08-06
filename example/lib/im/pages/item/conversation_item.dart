import 'package:flutter/material.dart';

import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart' as prefix;
import 'message_item_factory.dart';
import 'widget_util.dart';
import '../../util/style.dart';
import '../../util/user_info_datesource.dart' as example;
import 'dart:developer' as developer;

class ConversationItem extends StatefulWidget {
  prefix.Message message;
  ConversationItemDelegate delegate;
  bool showTime;
  bool multiSelect = false;
  List selectedMessageIds;
  _ConversationItemState state;
  ValueNotifier<int> time = ValueNotifier<int>(0);

  ConversationItem(
      ConversationItemDelegate delegate,
      prefix.Message msg,
      bool showTime,
      bool multiSelect,
      List selectedMessageIds,
      ValueNotifier<int> time) {
    this.message = msg;
    this.delegate = delegate;
    this.showTime = showTime;
    this.multiSelect = multiSelect;
    this.selectedMessageIds = selectedMessageIds;
    this.time = time;
  }

  @override
  State<StatefulWidget> createState() {
    return state = new _ConversationItemState(this.delegate, this.message,
        this.showTime, this.multiSelect, this.selectedMessageIds, this.time);
  }

  void refreshUI(prefix.Message message) {
    this.message = message;
    state._refreshUI(message);
  }
}

class _ConversationItemState extends State<ConversationItem> {
  String pageName = "example.ConversationItem";
  prefix.Message message;
  ConversationItemDelegate delegate;
  bool showTime;
  example.UserInfo user;
  Offset tapPos;
  bool multiSelect;
  bool isSeleceted = false;
  List selectedMessageIds;
  SelectIcon icon;

  ValueNotifier<int> time = ValueNotifier<int>(0);
  bool needShowMessage = true;

  _ConversationItemState(
      ConversationItemDelegate delegate,
      prefix.Message msg,
      bool showTime,
      bool multiSelect,
      List selectedMessageIds,
      ValueNotifier<int> time) {
    this.message = msg;
    this.delegate = delegate;
    this.showTime = showTime;
    // this.user = example.UserInfoDataSource.getUserInfo(msg.senderUserId);
    this.multiSelect = multiSelect;
    this.selectedMessageIds = selectedMessageIds;
    this.time = time;
    setInfo(message.senderUserId);
    needShowMessage =
        !(msg.messageDirection == prefix.RCMessageDirection.Receive &&
            msg.content != null &&
            msg.content.destructDuration != null &&
            msg.content.destructDuration > 0 &&
            time.value == msg.content.destructDuration);
  }

  void setInfo(String targetId) {
    example.UserInfo userInfo =
        example.UserInfoDataSource.cachedUserMap[targetId];
    if (userInfo != null) {
      this.user = userInfo;
    } else {
      example.UserInfoDataSource.getUserInfo(targetId).then((onValue) {
        setState(() {
          this.user = onValue;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    bool isSelected = selectedMessageIds.contains(message.messageId);
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
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Column(
        children: <Widget>[
          this.showTime
              ? WidgetUtil.buildMessageTimeWidget(message.sentTime)
              : WidgetUtil.buildEmptyWidget(),
          showMessage()
        ],
      ),
    );
  }

  Widget showMessage() {
    //属于通知类型的消息
    if (message.content is prefix.RecallNotificationMessage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          alignment: Alignment.center,
          width: RCLayout.MessageNotifiItemWidth,
          height: RCLayout.MessageNotifiItemHeight,
          color: Color(RCColor.MessageTimeBgColor),
          child: Text(
            RCString.ConRecallMessageSuccess,
            style: TextStyle(
                color: Colors.white, fontSize: RCFont.MessageNotifiFont),
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

  Widget subContent() {
    if (message.messageDirection == prefix.RCMessageDirection.Send) {
      return Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                    child: Text(
                        (this.user == null || this.user.id == null
                            ? ""
                            : this.user.id),
                        style: TextStyle(
                            fontSize: RCFont.MessageNameFont,
                            color: Color(RCColor.MessageNameBgColor))),
                  ),
                  buildMessageWidget(),
                  Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (TapDownDetails details) {
                        this.tapPos = details.globalPosition;
                      },
                      onTap: () {
                        __onTapedReadRequest();
                      },
                      child: message.content != null &&
                              message.content.destructDuration != null &&
                              message.content.destructDuration > 0
                          ? Text("")
                          : buildReadInfo(),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                __onTapedUserPortrait();
              },
              child: WidgetUtil.buildUserPortrait(this.user?.portraitUrl),
            ),
          ],
        ),
      );
    } else if (message.messageDirection == prefix.RCMessageDirection.Receive) {
      return Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                __onTapedUserPortrait();
              },
              onLongPress: () {
                __onLongPressUserPortrait(this.tapPos);
              },
              child: WidgetUtil.buildUserPortrait(this.user?.portraitUrl),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: Text(
                      (this.user == null || this.user.id == null
                          ? ""
                          : this.user.id),
                      style:
                          TextStyle(color: Color(RCColor.MessageNameBgColor)),
                    ),
                  ),
                  buildMessageWidget(),
                ],
              ),
            ),
          ],
        ),
      );
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
      delegate.didTapItem(message);
      bool isSelected = selectedMessageIds.contains(message.messageId);
      icon.updateUI(isSelected);
    } else {
      developer.log("没有实现 ConversationItemDelegate", name: pageName);
    }
  }

  void __onTapedMesssage() {
    if (multiSelect == false) {
      prefix.RongIMClient.messageBeginDestruct(message);
    }
    // return;
    if (delegate != null) {
      if (multiSelect == true) {
        //多选模式下修改为didTapItem处理
        delegate.didTapItem(message);
        bool isSelected = selectedMessageIds.contains(message.messageId);
        icon.updateUI(isSelected);
      } else {
        if (!needShowMessage) {
          needShowMessage = true;
          setState(() {});
        }
        delegate.didTapMessageItem(message);
      }
    } else {
      developer.log("没有实现 ConversationItemDelegate", name: pageName);
    }
  }

  void __onTapedReadRequest() {
    if (delegate != null) {
      if (message.readReceiptInfo != null &&
          message.readReceiptInfo.isReceiptRequestMessage) {
        delegate.didTapMessageReadInfo(message);
      } else {
        delegate.didSendMessageRequest(message);
      }
    } else {
      developer.log("没有实现 ConversationItemDelegate", name: pageName);
    }
  }

  void __onLongPressMessage(Offset tapPos) {
    if (delegate != null) {
      delegate.didLongPressMessageItem(message, tapPos);
    } else {
      developer.log("没有实现 ConversationItemDelegate", name: pageName);
    }
  }

  void __onTapedUserPortrait() {}

  void __onLongPressUserPortrait(Offset tapPos) {
    if (delegate != null) {
      delegate.didLongPressUserPortrait(this.user.id, tapPos);
    } else {
      developer.log("没有实现 ConversationItemDelegate", name: pageName);
    }
  }

  Widget buildMessageWidget() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(15, 6, 15, 10),
            alignment:
                message.messageDirection == prefix.RCMessageDirection.Send
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
            child: Row(
                mainAxisAlignment:
                    message.messageDirection == prefix.RCMessageDirection.Send
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                children: <Widget>[
                  message.messageDirection == prefix.RCMessageDirection.Send &&
                          message.content != null &&
                          message.content.destructDuration != null &&
                          message.content.destructDuration > 0
                      ? ValueListenableBuilder(
                          builder:
                              (BuildContext context, int value, Widget child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                value > 0
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
                  message.messageDirection == prefix.RCMessageDirection.Send &&
                          message.sentStatus == 20
                      ? Container(
                          padding: EdgeInsets.fromLTRB(6, 6, 6, 6),
                          child: GestureDetector(
                              onTap: () {
                                if (delegate != null) {
                                  if (multiSelect == true) {
                                    //多选模式下修改为didTapItem处理
                                    delegate.didTapItem(message);
                                    bool isSelected = selectedMessageIds
                                        .contains(message.messageId);
                                    icon.updateUI(isSelected);
                                  } else {
                                    delegate.didTapReSendMessage(message);
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
                        child: MessageItemFactory(
                            message: message, needShow: needShowMessage),
                      ),
                    ),
                  ),
                  message.messageDirection ==
                              prefix.RCMessageDirection.Receive &&
                          message.content != null &&
                          message.content.destructDuration != null &&
                          message.content.destructDuration > 0
                      ? ValueListenableBuilder(
                          builder:
                              (BuildContext context, int value, Widget child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                value > 0
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
    );
  }

  Text buildReadInfo() {
    if (message.conversationType == prefix.RCConversationType.Private) {
      if (message.sentStatus == 50) {
        return Text("已读");
      }
      return Text("");
    } else if (message.conversationType == prefix.RCConversationType.Group) {
      if (message.readReceiptInfo != null &&
          message.readReceiptInfo.isReceiptRequestMessage) {
        if (message.readReceiptInfo.userIdList != null) {
          return Text("${message.readReceiptInfo.userIdList.length}人已读");
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
    if (nowTime - message.sentTime < 120 * 1000) {
      return true;
    }
    return false;
  }
}

abstract class ConversationItemDelegate {
  //点击 item
  void didTapItem(prefix.Message message);
  //点击消息
  void didTapMessageItem(prefix.Message message);
  //长按消息
  void didLongPressMessageItem(prefix.Message message, Offset tapPos);
  //点击用户头像
  void didTapUserPortrait(String userId);
  //长按用户头像
  void didLongPressUserPortrait(String userId, Offset tapPos);
  //发送消息已读回执请求
  void didSendMessageRequest(prefix.Message message);
  //点击消息已读人数
  void didTapMessageReadInfo(prefix.Message message);
  //点击消息已读人数
  void didTapReSendMessage(prefix.Message message);
}

// 多选模式下 cell 显示的 Icon
class SelectIcon extends StatefulWidget {
  bool isSelected;
  _SelectIconState state;

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
  bool isSelected;

  _SelectIconState(bool isSelected) {
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
      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
      size: 20,
    );
  }
}
