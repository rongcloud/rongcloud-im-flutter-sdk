import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
    File imgfile = await ImagePicker.pickImage(source: ImageSource.gallery);
    String imgPath = imgfile.path;
    if (TargetPlatform.android == defaultTargetPlatform) {
       imgPath = "file://" + imgfile.path;
    }

    print("imagepath " + imgPath);
    ImageMessage imgMsg = new ImageMessage();
    imgMsg.localPath = imgPath;
    Message msg = await RongcloudImPlugin.sendMessage(
        RCConversationType.Private, "test", imgMsg);
  }

  startRecordAudio() async {
    await PermissionHandler().requestPermissions([PermissionGroup.microphone]);
    bool hasPermissions = await AudioRecorder.hasPermissions;

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path+"/"+DateTime.now().millisecondsSinceEpoch.toString()+".aac";
    await AudioRecorder.start(path: tempPath, audioOutputFormat: AudioOutputFormat.AAC);
  }

  stopRecordAudio() async {
    Recording recording = await AudioRecorder.stop();
    String path = recording.path;
    if (TargetPlatform.android == defaultTargetPlatform) {
       path = "file://" + path;
    }
    VoiceMessage message = VoiceMessage.build(path, 10);
    RongcloudImPlugin.sendMessage(RCConversationType.Private, "test", message);
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
