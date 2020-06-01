import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'dart:developer' as developer;

enum RecordState {
  //正常 [返回,切换摄像头]
  Normal,
  //录制 [返回,进度条]
  Recording,
  //预览 [返回]
  Preview
}

class TopRecordItem extends StatefulWidget {
  TopRecordItemDelegate delegate;
  _TopRecordItemState state;
  TopRecordItem(TopRecordItemDelegate delegate) {
    this.delegate = delegate;
    this.state = _TopRecordItemState(delegate);
  }

  void updateRecordState(RecordState s) {
    state.updateRecordState(s);
  }

  @override
  _TopRecordItemState createState() => state;
}

class _TopRecordItemState extends State<TopRecordItem> {
  String pageName = "example.TopRecordItem";
  TopRecordItemDelegate delegate;

  RecordState currentRecordState = RecordState.Normal;

  _TopRecordItemState(TopRecordItemDelegate delegate) {
    this.delegate = delegate;
  }

  void updateRecordState(RecordState s) {
    setState(() {
      currentRecordState = s;
    });
  }

  Widget recordLine() {
    return LinearPercentIndicator(
      width: MediaQuery.of(context).size.width - 40 - 25 - 40 - 35 - 30,
      animation: true,
      animationDuration: 10000,
      percent: 1,
      progressColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 40,
          ),
          GestureDetector(
            onTap: () {
              onPop();
            },
            child: Container(
              width: 25,
              height: 25,
              child: currentRecordState != RecordState.Recording
                  ? Image.asset("assets/images/sight_top_toolbar_close.png")
                  : Container(),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Expanded(
            child: Container(
              child: currentRecordState == RecordState.Recording
                  ? recordLine()
                  : Container(),
            ),
          ),
          GestureDetector(
            onTap: () {
              currentRecordState == RecordState.Normal
                  ? onSwitchCamera()
                  : Container();
            },
            child: Container(
              width: 35,
              height: 35,
              child: currentRecordState == RecordState.Normal
                  ? Image.asset("assets/images/sight_camera_switch.png")
                  : Container(),
            ),
          ),
          SizedBox(
            width: 40,
          ),
        ],
      ),
    );
  }

  void onPop() {
    if (delegate != null) {
      delegate.didPop();
    } else {
      developer.log("没有实现 didPop", name: pageName);
    }
  }

  void onSwitchCamera() {
    if (delegate != null) {
      delegate.didSwitchCamera();
    } else {
      developer.log("没有实现 didSwitchCamera", name: pageName);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

abstract class TopRecordItemDelegate {
  //点击叉号按钮
  void didPop();
  //切换摄像头
  void didSwitchCamera();
}
