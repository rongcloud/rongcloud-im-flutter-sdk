
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
  
  @override
  Widget build(BuildContext context) {
    ImageMessage msg = message.content;
    File file = File(msg.localPath);
    return Scaffold(
      appBar: AppBar(
        title: Text("图片预览"),
      ),
      body: Container(
        child: file == null? Image.network(msg.imageUri): Image.file(file),
      ),
    );
  }
  
}