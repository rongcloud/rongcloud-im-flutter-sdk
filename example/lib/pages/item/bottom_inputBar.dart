import 'package:flutter/material.dart';

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

  _BottomInputBarState(BottomInputBarDelegate delegate) {
    this.delegate = delegate;
    this.textField = TextField(
      onSubmitted: _clickSendMessage,
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.black12
            )
          ),
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
  }

  switchExtention() {
    print("switchExtention");
  }

  Widget _getTextField() {
    return Container(
          padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: this.textField,
        );
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellowAccent,
      child: Row(
        children: <Widget>[
          _getVoiceButton(),
          Expanded(
            child: _getTextField(),
          ),
          _getExtentionButton()
        ],
      ),
    );
  }
}

abstract class BottomInputBarDelegate {
  void willSendText(String text);
}



