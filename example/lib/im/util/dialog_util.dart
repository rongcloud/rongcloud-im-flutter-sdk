import 'package:flutter/material.dart';

class DialogUtil {
  static void showAlertDiaLog(BuildContext context, String content,
      {String title = '', TextButton confirmButton}) {
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
                confirmButton != null
                    ? confirmButton
                    : TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("确定")),
              ],
            ));
  }

  static void showBottomSheetDialog(
      BuildContext mContext, Map<String, Function()> tips) {
    if (tips == null || tips.length <= 0) {
      return;
    }
    showModalBottomSheet(
      context: mContext,
      builder: (context) => Container(
        child: ListView.separated(
            key: UniqueKey(),
            controller: ScrollController(),
            itemCount: tips.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                  child: Container(
                      alignment: Alignment.center,
                      height: 60,
                      child: Text(tips.keys.toList()[index])),
                  onTap: () {
                    Function() clickEvent = tips.values.toList()[index];
                    if (clickEvent != null) {
                      Navigator.pop(mContext);
                      clickEvent();
                    }
                  });
            },
            separatorBuilder: (BuildContext context, int index) {
              return Container(
                color: Color(0xffC8C8C8),
                height: 0.5,
              );
            }),
        height: (60 * tips.length * 1.0),
      ),
    );
  }
}
