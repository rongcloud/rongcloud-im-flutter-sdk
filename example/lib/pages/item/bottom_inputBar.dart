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
  int inputBarStatus;

  _BottomInputBarState(BottomInputBarDelegate delegate) {
    this.delegate = delegate;
    this.inputBarStatus = InputBarStatus.Normal;

    this.textField = TextField(
      onSubmitted: _clickSendMessage,
      decoration: InputDecoration(
            border: InputBorder.none,
          ),
      );
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
    if(this.inputBarStatus != InputBarStatus.Voice) {
      this.inputBarStatus = InputBarStatus.Voice;
    }else {
      this.inputBarStatus = InputBarStatus.Normal;
    }
    setState(() {
      
    });
  }

  switchExtention() {
    print("switchExtention");
    if(this.inputBarStatus != InputBarStatus.Extention) {
      this.inputBarStatus = InputBarStatus.Extention;
    }else {
      this.inputBarStatus = InputBarStatus.Normal;
    }
    setState(() {
      
    });
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
      padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: MaterialButton(
            color: Colors.blue,
            textColor: Colors.white,
            child: new Text("音"),
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
      padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
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

class InputBarStatus {
  static const int Normal = 0;//正常
  static const int Voice = 1;//语音输入
  static const int Extention = 2;//扩展栏
}


abstract class BottomInputBarDelegate {
  void willSendText(String text);
  void willSendVoice(String path,int duration);
}



