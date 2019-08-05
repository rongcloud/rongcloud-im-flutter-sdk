import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../util/media_util.dart';

class BottomInputBar extends StatefulWidget {
  BottomInputBarDelegate delegate;
  BottomInputBar(BottomInputBarDelegate delegate) {
    this.delegate = delegate;
  }
  @override
  _BottomInputBarState createState() => _BottomInputBarState(this.delegate);
}

class _BottomInputBarState extends State<BottomInputBar> {
  BottomInputBarDelegate delegate;
  TextField textField;
  FocusNode focusNode = FocusNode();
  InputBarStatus inputBarStatus;

  _BottomInputBarState(BottomInputBarDelegate delegate) {
    this.delegate = delegate;
    this.inputBarStatus = InputBarStatus.Normal;

    this.textField = TextField(
      onSubmitted: _clickSendMessage,
      decoration: InputDecoration(
            border: InputBorder.none,
          ),
      focusNode: focusNode,
      );
  }

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if(focusNode.hasFocus) {
        _notifyInputStatusChanged(InputBarStatus.Normal);
      }
    });
  }

  void _clickSendMessage(String messageStr) {
    if (messageStr == null || messageStr.length <= 0) {
      print('不能为空');
      return;
    }
    if(this.delegate != null) {
      this.delegate.willSendText(messageStr);
    }
    this.textField.controller.text = '';
  }

  switchVoice() {
    print("switchVoice");
    InputBarStatus status = InputBarStatus.Normal;
    if(this.inputBarStatus != InputBarStatus.Voice) {
      status = InputBarStatus.Voice;
    }
    _notifyInputStatusChanged(status);
  }

  switchExtention() {
    print("switchExtention");
    if(focusNode.hasFocus) {
      focusNode.unfocus();
    }
    InputBarStatus status = InputBarStatus.Normal;
    if(this.inputBarStatus != InputBarStatus.Extention) {
      status = InputBarStatus.Extention;
    }
    if(this.delegate != null) {
      this.delegate.didTapExtentionButton();
    }
    _notifyInputStatusChanged(status);
  }

  _onVoiceGesLongPress() {
    print("_onVoiceGesLongPress");
    MediaUtil.instance.startRecordAudio();
  }

  _onVoiceGesLongPressEnd() {
    print("_onVoiceGesLongPressEnd");
    MediaUtil.instance.stopRecordAudio((String path,int duration) {
      if(this.delegate != null) {
        this.delegate.willSendVoice(path,duration);
      }
    });
  }

  Widget _getVoiceButton() {
    return Container(
      width: 48,
      height: 48,
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: MaterialButton(
            color: Colors.blue,
            textColor: Colors.white,
            child: Icon(Icons.mic),
            onPressed: () {
              switchVoice();
            },
          ),
    );
  }

  Widget _getExtentionButton() {
    return Container(
      width: 48,
      height: 48,
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: MaterialButton(
            color: Colors.blue,
            textColor: Colors.white,
            child: new Text("加"),
            onPressed: () {
              switchExtention();
            },
          ),
    );
  }

  Widget _getMainInputField() {
    Widget widget ;
    if(this.inputBarStatus == InputBarStatus.Voice) {
      widget = Container(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Text("按住 说话",textAlign: TextAlign.center),
          onLongPress: () {
            _onVoiceGesLongPress();
          },
          onLongPressEnd: (LongPressEndDetails details) {
            _onVoiceGesLongPressEnd();
          },
        ),
      );
    }else {
      widget = Container(
          child: this.textField,
        );
    }
    return Container(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        border:  new Border.all(color: Colors.black54, width: 0.5),
        borderRadius:  BorderRadius.circular(8)
      ),
      child: widget ,
    ) ;
  }

  void _notifyInputStatusChanged(InputBarStatus status) {
    this.inputBarStatus = status;
    if(this.delegate != null) {
      this.delegate.inputStatusDidChange(status);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: <Widget>[
          _getVoiceButton(),
          Expanded(
            child : _getMainInputField()
          ),
          _getExtentionButton()
        ],
      ),
    );
  }
}

enum InputBarStatus{
  Normal,//正常
  Voice,//语音输入
  Extention,//扩展栏
}

abstract class BottomInputBarDelegate {
  void inputStatusDidChange(InputBarStatus status);
  void willSendText(String text);
  void willSendVoice(String path,int duration);
  void didTapExtentionButton();
}



