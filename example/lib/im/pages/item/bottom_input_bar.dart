import 'package:flutter/material.dart';

import '../../util/media_util.dart';
import '../../util/style.dart';

class BottomInputBar extends StatefulWidget {
  BottomInputBarDelegate delegate;
  _BottomInputBarState state;
  BottomInputBar(BottomInputBarDelegate delegate) {
    this.delegate = delegate;
  }
  @override
  _BottomInputBarState createState() =>
      state = _BottomInputBarState(this.delegate);

  void setTextContent(String textContent) {
    this.state.setText(textContent);
  }

  void refreshUI() {
    this.state._refreshUI();
  }
}

class _BottomInputBarState extends State<BottomInputBar> {
  BottomInputBarDelegate delegate;
  TextField textField;
  FocusNode focusNode = FocusNode();
  InputBarStatus inputBarStatus;
  TextEditingController textEditingController;

  _BottomInputBarState(BottomInputBarDelegate delegate) {
    this.delegate = delegate;
    this.inputBarStatus = InputBarStatus.Normal;
    this.textEditingController = TextEditingController();

    this.textField = TextField(
      onSubmitted: _clickSendMessage,
      controller: textEditingController,
      decoration: InputDecoration(
          border: InputBorder.none, hintText: RCString.BottomInputTextHint),
      focusNode: focusNode,
      autofocus: true,
      maxLines: null,
      keyboardType: TextInputType.text,
    );
  }

  void setText(String textContent) {
    if (textContent == null) {
      textContent = '';
    }
    this.textEditingController.text =
        this.textEditingController.text + textContent;
    this.textEditingController.selection = TextSelection.fromPosition(
        TextPosition(offset: textEditingController.text.length));
    _refreshUI();
  }

  void _refreshUI() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    textEditingController.addListener(() {
      //获取输入的值
      delegate.onTextChange(textEditingController.text);
    });
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        _notifyInputStatusChanged(InputBarStatus.Normal);
      }
    });
  }

  void _clickSendMessage(String messageStr) {
    if (messageStr == null || messageStr.length <= 0) {
      print('不能为空');
      return;
    }

    if (this.delegate != null) {
      this.delegate.willSendText(messageStr);
    } else {
      print("没有实现 BottomInputBarDelegate");
    }
    this.textField.controller.text = '';
  }

  switchPhrases() {
    print("switchPhrases");
    if (focusNode.hasFocus) {
      focusNode.unfocus();
    }
    InputBarStatus status = InputBarStatus.Normal;
    if (this.inputBarStatus != InputBarStatus.Phrases) {
      status = InputBarStatus.Phrases;
    }
    _notifyInputStatusChanged(status);
  }

  switchVoice() {
    print("switchVoice");
    InputBarStatus status = InputBarStatus.Normal;
    if (this.inputBarStatus != InputBarStatus.Voice) {
      status = InputBarStatus.Voice;
    }
    _notifyInputStatusChanged(status);
  }

  switchEmoji() {
    print("switchEmoji");
    InputBarStatus status = InputBarStatus.Normal;
    if (this.inputBarStatus != InputBarStatus.Emoji) {
      if (focusNode.hasFocus) {
        focusNode.unfocus();
      }
      status = InputBarStatus.Emoji;
    }
    _notifyInputStatusChanged(status);
  }

  switchExtention() {
    print("switchExtention");
    if (focusNode.hasFocus) {
      focusNode.unfocus();
    }
    InputBarStatus status = InputBarStatus.Normal;
    if (this.inputBarStatus != InputBarStatus.Extention) {
      status = InputBarStatus.Extention;
    }
    if (this.delegate != null) {
      this.delegate.didTapExtentionButton();
    } else {
      print("没有实现 BottomInputBarDelegate");
    }
    _notifyInputStatusChanged(status);
  }

  _onVoiceGesLongPress() {
    print("_onVoiceGesLongPress");
    MediaUtil.instance.startRecordAudio();
    if (this.delegate != null) {
      this.delegate.willStartRecordVoice();
    } else {
      print("没有实现 BottomInputBarDelegate");
    }
  }

  _onVoiceGesLongPressEnd() {
    print("_onVoiceGesLongPressEnd");

    if (this.delegate != null) {
      this.delegate.willStopRecordVoice();
    } else {
      print("没有实现 BottomInputBarDelegate");
    }

    MediaUtil.instance.stopRecordAudio((String path, int duration) {
      if (this.delegate != null && path.length > 0) {
        this.delegate.willSendVoice(path, duration);
      } else {
        print("没有实现 BottomInputBarDelegate || 录音路径为空");
      }
    });
  }

  Widget _getMainInputField() {
    Widget widget;
    if (this.inputBarStatus == InputBarStatus.Voice) {
      widget = Container(
        alignment: Alignment.center,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Text(RCString.BottomTapSpeak, textAlign: TextAlign.center),
          onLongPress: () {
            _onVoiceGesLongPress();
          },
          onLongPressEnd: (LongPressEndDetails details) {
            _onVoiceGesLongPressEnd();
          },
        ),
      );
    } else {
      widget = Container(
        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: new ConstrainedBox(
          constraints: BoxConstraints(
              // maxHeight: 200.0,
              ),
          child: new SingleChildScrollView(
            scrollDirection: Axis.vertical,
            reverse: true,
            child: this.textField,
          ),
        ),
      );
    }
    return Container(
      height: 45,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
            decoration: BoxDecoration(
                border: new Border.all(color: Colors.black54, width: 0.5),
                borderRadius: BorderRadius.circular(8)),
          ),
          widget
        ],
      ),
    );
  }

  void _notifyInputStatusChanged(InputBarStatus status) {
    this.inputBarStatus = status;
    if (this.delegate != null) {
      this.delegate.inputStatusDidChange(status);
    } else {
      print("没有实现 BottomInputBarDelegate");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              GestureDetector(
                  onTap: () {
                    switchPhrases();
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(6, 6, 12, 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        alignment: Alignment.center,
                        width: 80,
                        height: 22,
                        color: Color(0xffC8C8C8),
                        child: Text(
                          RCString.BottomCommonPhrases,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  )),
              Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.mic),
                    iconSize: 32,
                    onPressed: () {
                      switchVoice();
                    },
                  ),
                  Expanded(child: _getMainInputField()),
                  IconButton(
                    icon: Icon(Icons.mood), // sentiment_ver
                    iconSize: 32,
                    onPressed: () {
                      switchEmoji();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    iconSize: 32,
                    onPressed: () {
                      switchExtention();
                    },
                  ),
                ],
              ),
            ]));
  }
}

enum InputBarStatus {
  Normal, //正常
  Voice, //语音输入
  Extention, //扩展栏
  Phrases, //快捷回复
  Emoji, // emoji输入
}

abstract class BottomInputBarDelegate {
  ///输入工具栏状态发生变更
  void inputStatusDidChange(InputBarStatus status);

  ///即将发送消息
  void willSendText(String text);

  ///即将发送语音
  void willSendVoice(String path, int duration);

  ///即将开始录音
  void willStartRecordVoice();

  ///即将停止录音
  void willStopRecordVoice();

  ///点击了加号按钮
  void didTapExtentionButton();

  ///输入框内容变化监听
  void onTextChange(String text);
}
