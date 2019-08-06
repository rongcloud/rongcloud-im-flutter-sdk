
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import '../../util/time.dart';
import '../../util/style.dart';

class WidgetUtil {
  ///扩展栏里面的 widget
  static Widget buildExtentionWidget(IconData icon,String text,Function()clicked) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 8,
        ),
        InkWell(
          onTap: () {
            if(clicked != null) {
              clicked();
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 40,
              height: 40,
              color: Colors.white,
              child: Icon(icon,size: 28,),
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(text,style:TextStyle(fontSize:12))
      ],
    );
  }

  ///用户头像
  static Widget buildUserPortrait(String path) {
    Widget protraitWidget = Image.asset("assets/images/default_portrait.png",fit: BoxFit.fill);
    if(path.startsWith("http")) {
      protraitWidget = CachedNetworkImage(
          fit: BoxFit.fill,
          imageUrl: path,
        );
    }else {
      File file = File(path);
      if(file.existsSync()) {
        protraitWidget = Image.file(file,fit: BoxFit.fill,);
      }
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 45,
        width: 45,
        child: protraitWidget,
      ),
    );
  }

  /// 会话页面录音时的 widget
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

  ///消息上的时间
  static Widget buildMessageTimeWidget(int sentTime) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          alignment: Alignment.center,
          width: 80,
          color: Color(UIColor.MessageTimeBgColor),
          child: Text(TimeUtil.convertTime(sentTime),style: TextStyle(color: Colors.white,fontSize: 12),),
        ),
      );
  }
}