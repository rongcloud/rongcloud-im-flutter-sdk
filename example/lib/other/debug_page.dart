import 'package:flutter/material.dart';

class DebugPage extends StatelessWidget {
  List titles ;

  DebugPage() {
    titles = ["加入黑名单","移除黑名单","查看黑名单状态","获取黑名单列表"];
  }

  void _didTap(int index) {
    print("did tap debug "+titles[index]);
    switch (index) {
      case 0: _addBlackList();break;
      case 1: _removeBalckList();break;
      case 2: _getBlackStatus();break;
      case 1: _getBlackList();break;
    }

  }

  void _addBlackList() {

  }

  void _removeBalckList() {

  }

  void _getBlackStatus() {

  }

  void _getBlackList() {

  }
   
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Debug"),
      ),
      body: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: titles.length,
        itemBuilder: (BuildContext context,int index) {
          return MaterialButton(
            onPressed: () {
              _didTap(index);
            },
            child: Text(titles[index]),
            color: Colors.blue,
          );
        },
      ),
    );
  }
  
}