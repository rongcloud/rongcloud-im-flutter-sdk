import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import '../util/media_util.dart';

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
    RongcloudImPlugin.onMessageSend =
        (int messageId, int status, int code) async {
          Message message = await RongcloudImPlugin.getMessage(messageId);
          if(message.content is VoiceMessage) {
            VoiceMessage msg = message.content;
            print("voice localPath "+msg.localPath);
            print("voice duration "+msg.duration.toString());
            print("voice remoteUrl "+msg.remoteUrl);
          }else if(message.content is ImageMessage) {
            ImageMessage msg = message.content;
            print("image localPath "+(msg.localPath == null? "":msg.localPath));
            print("image remoteUrl "+msg.imageUri);
          }
    };
  }

  getImages() async {
    String imgPath = await MediaUtil.instance.pickImage();
    if(imgPath == null) {
      return;
    }

    print("imagepath " + imgPath);
    ImageMessage imgMsg = ImageMessage.obtain(imgPath);
    Message msg = await RongcloudImPlugin.sendMessage(
        RCConversationType.Private, "test", imgMsg);
  }

  takePhotos() async {
    String imgPath = await MediaUtil.instance.takePhoto();
    if(imgPath == null) {
      return;
    }

    print("imagepath " + imgPath);
    ImageMessage imgMsg = ImageMessage.obtain(imgPath);
    Message msg = await RongcloudImPlugin.sendMessage(
        RCConversationType.Private, "test", imgMsg);
  }

  startRecordAudio() async {
    MediaUtil.instance.startRecordAudio();
  }

  stopRecordAudio() async {
    MediaUtil.instance.stopRecordAudio((String path,int duration) {
      if(path != null) {
        VoiceMessage message = VoiceMessage.obtain(path, 10);
        RongcloudImPlugin.sendMessage(RCConversationType.Private, "test", message);
      }
    }); 
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
        children: <Widget>[
          MaterialButton(
            color: Colors.blue,
            textColor: Colors.white,
            child: new Text("相册"),
            onPressed: () {
              getImages();
            },
          ),
          MaterialButton(
            color: Colors.blue,
            textColor: Colors.white,
            child: new Text("拍照"),
            onPressed: () {
              takePhotos();
            },
          ),
          MaterialButton(
            color: Colors.blue,
            textColor: Colors.white,
            child: new Text("录音开始"),
            onPressed: () {
              startRecordAudio();
            },
          ),MaterialButton(
            color: Colors.blue,
            textColor: Colors.white,
            child: new Text("录音结束"),
            onPressed: () {
              stopRecordAudio();
            },
          ),
        ],
      )

    );
  }
}
