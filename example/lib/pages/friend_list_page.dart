
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class FriendListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _FriendListPageState();
  }
}


class _FriendListPageState extends State<FriendListPage> {

@override
  void initState() {
    super.initState();
    addIMhandler();
  }

  addIMhandler() async {
    RongcloudImPlugin.onMessageSend = (int messageId, int status, int code) async {
      List msgs = await RongcloudImPlugin.getHistoryMessage(RCConversationType.Private, "test", messageId, 15);
      for(Message msg in msgs) {
        if(msg.content is ImageMessage) {
          ImageMessage imgMsg =  msg.content;
          print("imgMsg "+imgMsg.imageUri);
        }
      }
    };
  }


  getImages() async {
    File imgfile = await ImagePicker.pickImage(source: ImageSource.gallery);
    String imgPath = "file:/"+imgfile.path;
    print("imagepath "+imgPath);
    ImageMessage imgMsg = new ImageMessage();
    imgMsg.localPath = imgPath;
    Message msg = await RongcloudImPlugin.sendMessage(RCConversationType.Private, "test", imgMsg);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MaterialButton(
        color: Colors.blue,
        textColor: Colors.white,
        child: new Text("相册"),
        onPressed: () {
          getImages();
        },
      ),
    );
  }
  
}