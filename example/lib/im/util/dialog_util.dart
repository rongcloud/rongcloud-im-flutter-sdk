import 'package:flutter/material.dart';

class DialogUtil {
  static void showAlertDiaLog(BuildContext context, String content, {String title = ''}) {
    showDialog(
        barrierDismissible: false, // 设置点击 dialog 外部不取消 dialog，默认能够取消
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title),
              titleTextStyle: TextStyle(color: Colors.black),
              content: Text(content),
              contentTextStyle: TextStyle(color: Colors.black),
              backgroundColor: Colors.white,
              elevation: 8.0, // 投影的阴影高度
              semanticLabel: 'Label', // 这个用于无障碍下弹出 dialog 的提示
              shape: Border.all(),
              actions: <Widget>[
                FlatButton(
                    onPressed: () => Navigator.pop(context), child: Text("确定")),
              ],
            ));
  }
}
