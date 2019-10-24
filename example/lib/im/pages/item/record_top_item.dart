import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

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
  TopRecordItemDelegate delegate;
  _TopRecordItemState(TopRecordItemDelegate delegate) {
    this.delegate = delegate;
  }
  RecordState currentRecordState = RecordState.Normal;
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
              child: Image.asset("assets/images/sight_top_toolbar_close.png"),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Expanded(
            child: Container(
              child: currentRecordState == RecordState.Recording
                  ? recordLine()
                  : null,
            ),
          ),
          GestureDetector(
            onTap: () {
              currentRecordState == RecordState.Normal
                  ? onSwitchCamera()
                  : null;
            },
            child: Container(
              width: 35,
              height: 35,
              child: currentRecordState == RecordState.Normal
                  ? Image.asset("assets/images/sight_camera_switch.png")
                  : null,
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
      print("没有实现 didPop");
    }
  }

  void onSwitchCamera() {
    if (delegate != null) {
      delegate.didSwitchCamera();
    } else {
      print("没有实现 didSwitchCamera");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

abstract class TopRecordItemDelegate {
  //长按相机按钮
  void didPop();
  //长按结束
  void didSwitchCamera();
}
