import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../util/style.dart';
import '../../util/time.dart';

class WidgetUtil {
  /// 会话页面加号扩展栏里面的 widget，上面图片，下面文本
  static Widget buildExtentionWidget(IconData icon, String text, Function() clicked) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 8,
        ),
        InkWell(
          onTap: () {
            if (clicked != null) {
              clicked();
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: RCLayout.ExtIconLayoutSize,
              height: RCLayout.ExtIconLayoutSize,
              color: Colors.white,
              child: Icon(
                icon,
                size: RCFont.ExtIconSize,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(text, style: TextStyle(fontSize: RCFont.ExtTextFont))
      ],
    );
  }

  /// 用户头像
  static Widget buildUserPortrait(String? path) {
    Widget? protraitWidget;
    if (path == null || path.isEmpty) {
      protraitWidget = Image.asset("assets/images/default_portrait.png", fit: BoxFit.fill);
    } else {
      if (path.startsWith("http")) {
        protraitWidget = CachedNetworkImage(
          fit: BoxFit.fill,
          imageUrl: path,
        );
      } else {
        File file = File(path);
        if (file.existsSync()) {
          protraitWidget = Image.file(
            file,
            fit: BoxFit.fill,
          );
        }
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: RCLayout.ConListPortraitSize,
        width: RCLayout.ConListPortraitSize,
        child: protraitWidget,
      ),
    );
  }

  /// 会话页面录音时的 widget，gif 动画
  static Widget buildVoiceRecorderWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(50, 0, 50, 200),
      alignment: Alignment.center,
      child: Container(
        width: 150,
        height: 150,
        child: Image.asset("assets/images/voice_recoder.gif"),
      ),
    );
  }

  /// 消息 item 上的时间
  static Widget buildMessageTimeWidget(int sentTime) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          alignment: Alignment.center,
          width: RCLayout.MessageTimeItemWidth,
          height: RCLayout.MessageTimeItemHeight,
          color: Color(RCColor.MessageTimeBgColor),
          child: Text(
            TimeUtil.convertTime(sentTime),
            style: TextStyle(color: Colors.white, fontSize: RCFont.MessageTimeFont),
          ),
        ),
      ),
    );
  }

  /// 长按的 menu，用于处理会话列表页面和会话页面的长按
  static void showLongPressMenu(
      BuildContext context, Offset tapPos, Map<String, String> map, Function(String? key) onSelected) {
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final RelativeRect position =
        RelativeRect.fromLTRB(tapPos.dx, tapPos.dy, overlay.size.width - tapPos.dx, overlay.size.height - tapPos.dy);
    List<PopupMenuEntry<String>> items = [];
    map.keys.forEach((String key) {
      PopupMenuItem<String> p = PopupMenuItem(
        child: Container(
          alignment: Alignment.center,
          child: Text(
            map[key]!,
            textAlign: TextAlign.center,
          ),
        ),
        value: key,
      );
      items.add(p);
    });
    showMenu<String>(context: context, position: position, items: items).then<String>((String? selectedStr) {
      if (onSelected != null) {
        if (selectedStr == null) {
          selectedStr = RCLongPressAction.UndefinedKey;
        }
        onSelected(selectedStr);
      }
      return selectedStr!;
    });
  }

  /// onTaped 点击事件，0~n 代表点击了对应下标，-1 代表点击了白透明空白区域，暂无用
  static Widget buildLongPressDialog(List<String> titles, Function(int index) onTaped) {
    List<Widget> wList = [];
    for (int i = 0; i < titles.length; i++) {
      Widget w = Container(
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            if (onTaped != null) {
              onTaped(i);
            }
          },
          child: Container(
            height: 40,
            alignment: Alignment.center,
            child: new Text(
              titles[i],
              style: new TextStyle(fontSize: 18.0),
            ),
          ),
        ),
      );
      wList.add(w);
    }
    Widget bgWidget = Opacity(
      opacity: 0.3,
      child: GestureDetector(
        onTap: () {
          if (onTaped != null) {
            onTaped(-1);
          }
        },
        child: Container(
          padding: EdgeInsets.all(0),
          color: Colors.black,
        ),
      ),
    );
    return Stack(
      children: <Widget>[
        bgWidget, //半透明 widget
        new Center(
          //保证控件居中效果
          child: Container(
              width: 120,
              height: 60.0 * titles.length,
              color: Colors.white,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: wList,
              )),
        )
      ],
    );
  }

  /// 空白 widget ，用于处理非法参数时的占位
  static Widget buildEmptyWidget() {
    return Container(
      height: 1,
      width: 1,
    );
  }
}
