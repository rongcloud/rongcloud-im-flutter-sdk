import 'package:flutter/material.dart';
import '../../util/style.dart';
import 'dart:developer' as developer;

class BottomToolBar extends StatefulWidget {
  BottomToolBarDelegate delegate;
  BottomToolBar(BottomToolBarDelegate delegate) {
    this.delegate = delegate;
  }

  @override
  State<StatefulWidget> createState() {
    return _BottomToolBarState(delegate);
  }
}

class _BottomToolBarState extends State<BottomToolBar> {
  String pageName = "example.BottomToolBar";
  BottomToolBarDelegate delegate;
  _BottomToolBarState(BottomToolBarDelegate delegate) {
    this.delegate = delegate;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            iconSize: RCLayout.BottomIconLayoutSize,
            onPressed: () {
              tapDelete();
            },
          ),
          IconButton(
            icon: Icon(Icons.forward),
            iconSize: RCLayout.BottomIconLayoutSize,
            onPressed: () {
              tapForward();
            },
          ),
        ],
      ),
    );
  }

  void tapDelete() {
    if (this.delegate != null) {
      this.delegate.didTapDelete();
    } else {
      developer.log("没有实现 BottomToolBarDelegate", name: pageName);
    }
  }

  void tapForward() {
    if (this.delegate != null) {
      this.delegate.didTapForward();
    } else {
      developer.log("没有实现 BottomToolBarDelegate", name: pageName);
    }
  }
}

abstract class BottomToolBarDelegate {
  void didTapDelete();
  void didTapForward();
}
