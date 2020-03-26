import 'package:flutter/material.dart';

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
            iconSize: 32,
            onPressed: () {
              tapDelegate();
            },
          ),
        ],
      ),
    );
  }

  void tapDelegate() {
    if (this.delegate != null) {
      this.delegate.didTapDelegate();
    } else {
      print("没有实现 BottomToolBarDelegate");
    }
  }
}

abstract class BottomToolBarDelegate {
  void didTapDelegate();
}
