import 'dart:ui';
import 'package:flutter/material.dart';

class BottomRecordItem extends StatefulWidget {
  VideoBottomToolBarDelegate delegate;
  BottomRecordItem(VideoBottomToolBarDelegate delegate) {
    this.delegate = delegate;
  }
  @override
  _BottomRecordItemState createState() => _BottomRecordItemState(this.delegate);
}

class _BottomRecordItemState extends State<BottomRecordItem>
    with TickerProviderStateMixin {
  VideoBottomToolBarDelegate delegate;
  double percentage = 0.0;
  int timerValue = 0;
  bool isBegin = false;
  AnimationController percentageAnimationController;
  bool isFinishRecord = false;

  _BottomRecordItemState(VideoBottomToolBarDelegate delegate) {
    this.delegate = delegate;
  }

  @override
  void initState() {
    super.initState();
  }

  Widget _getBottomChoiceToolbar() {
    double itemWidth = 70;
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  onCancelEvent();
                },
                child: Container(
                  width: itemWidth,
                  height: itemWidth,
                  child: Image.asset("assets/images/sight_preview_cancel.png"),
                ),
              ),
              SizedBox(
                width: 100,
              ),
              GestureDetector(
                onTap: () {
                  onFinishEvent();
                },
                child: Container(
                  width: itemWidth,
                  height: itemWidth,
                  child: Image.asset("assets/images/sight_preview_done.png"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _getBottomToolbarWidget() {
    Widget widget = _getBottomRecordToolbar();

    if (isFinishRecord == true) {
      widget = _getBottomChoiceToolbar();
    }

    return widget;
  }

  Widget _getBottomRecordToolbar() {
    return Container(
      child: Column(
        children: <Widget>[
          GestureDetector(
              onTap: () {
                onTapCamera();
              },
              onLongPress: () {
                onLongPressCamera();
              },
              onLongPressEnd: (LongPressEndDetails details) {
                onLongPressEndCamera();
              },
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    child: Image.asset("assets/images/sight_preview_done.png"),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  onLongPressCamera() {
    setState(() {
      isBegin = true;
      // percentageAnimationController.forward(from: 0.0);
    });

    if (delegate != null) {
      delegate.didLongPressCamera();
    } else {
      print("没有实现 didLongPressCamera");
    }
  }

  onLongPressEndCamera() {
    setState(() {
      isFinishRecord = true;
      // percentageAnimationController.stop();
    });
    if (delegate != null) {
      delegate.didLongPressEndCamera();
    } else {
      print("没有实现 didLongPressEndCamera");
    }
  }

  onTapCamera() {}

  onCancelEvent() {
    if (delegate != null) {
      delegate.didCancelEvent();
    } else {
      print("没有实现 didLongPressEndCamera");
    }
  }

  onFinishEvent() {
    if (delegate != null) {
      delegate.didFinishEvent();
    } else {
      print("没有实现 didLongPressEndCamera");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _getBottomToolbarWidget(),
    );
  }
}

abstract class VideoBottomToolBarDelegate {
  //长按相机按钮
  void didLongPressCamera();
  //长按结束
  void didLongPressEndCamera();
  //取消发送
  void didCancelEvent();
  //发送
  void didFinishEvent();
}
