
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class ImagePreviewPage extends StatefulWidget {
  final Message message;
  const ImagePreviewPage({Key key, this.message}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ImagePreviewPageState(message);
  }
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  final Message message;

  _ImagePreviewPageState(this.message);

  //优先加载本地路径图片，否则加载网络图片
  Widget getImageWidget() {
    ImageMessage msg = message.content;
    Widget widget;
    if(msg.localPath != null) {
      File file = File(msg.localPath);
      if(file != null) {
        widget = Image.file(file);
      }else {
        widget = Image.network(msg.imageUri);
      }
    }else {
      widget = Image.network(msg.imageUri);
    }
    return widget;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("图片预览"),
      ),
      body: Container(
        child: getImageWidget(),
      ),
    );
  }
  
}