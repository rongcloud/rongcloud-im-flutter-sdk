import 'dart:io';
import 'dart:async'; //timer

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'record_top_item.dart';
import 'record_bottom_item.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../../util/style.dart';
import 'dart:developer' as developer;

class VideoRecordPage extends StatefulWidget {
  final Map arguments;

  VideoRecordPage({Key key, this.arguments}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _VideoRecordPageState(arguments: this.arguments);
  }
}

class _VideoRecordPageState extends State<VideoRecordPage>
    implements VideoBottomToolBarDelegate, TopRecordItemDelegate {
  String pageName = "example.VideoRecordPage";
  Map arguments;
  int conversationType;
  String targetId;
  int recodeTime = 0;
  Timer timer;
  bool isSecretChat = false;

  CameraController cameraController;
  VideoPlayerController videoPlayerController;
  List<CameraDescription> cameras;
  String videoPath;
  TopRecordItem topitem;

  _VideoRecordPageState({this.arguments});

  @override
  void initState() {
    super.initState();
    conversationType = arguments["coversationType"];
    targetId = arguments["targetId"];
    isSecretChat = arguments["isSecretChat"];
    initCamera();
    topitem = TopRecordItem(this);
  }

  @override
  void dispose() {
    cameraController?.dispose();
    videoPlayerController?.dispose();
    super.dispose();
  }

  void initCamera() async {
    cameras = await availableCameras();
    cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  void onPop() {
    developer.log("onPop", name: pageName);
    resetData();
    Navigator.pop(context);
  }

  void onSwitchCamera() async {
    developer.log("onSwitchCamera", name: pageName);
    CameraDescription curDes = cameraController.description;
    CameraDescription targetDes = cameras[0];
    if (cameras[0].name == curDes.name) {
      targetDes = cameras[1];
    }
    if (cameraController != null) {
      await cameraController.dispose();
    }

    cameraController = CameraController(targetDes, ResolutionPreset.medium);

    cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  Future<String> startVideoRecording() async {
    if (!cameraController.value.isInitialized) {
      developer.log("Error: select a camera first.", name: pageName);
      return null;
    }

    final Directory extDir = await getTemporaryDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      videoPath = filePath;
      await cameraController.startVideoRecording(filePath);
    } on CameraException catch (e) {
      developer.log(e.toString(), name: pageName);
      return null;
    }
    return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (!cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      await cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      developer.log(e.toString(), name: pageName);
      return null;
    }

    developer.log("rc videoPath $videoPath", name: pageName);

    videoPlayerController = VideoPlayerController.file(File(videoPath));
//    await videoPlayerController.setLooping(true);
    await videoPlayerController.initialize();
    await videoPlayerController.play();
    setState(() {});
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void resetData() {
    videoPath = null;
    if (videoPlayerController != null &&
        videoPlayerController.value != null &&
        videoPlayerController.value.isPlaying) {
      videoPlayerController.pause();
    }
    videoPlayerController = null;
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController == null) {
      return Container();
    }
    if (!cameraController.value.isInitialized) {
      return Container();
    }

    return Container(
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                child: AspectRatio(
                  aspectRatio: MediaQuery.of(context).size.width /
                      MediaQuery.of(context).size.height,
                  child: Center(
                      child: Stack(
                    children: <Widget>[_getCameraPreviewWidget(), topitem],
                  )),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  child: BottomRecordItem(this),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _getCameraPreviewWidget() {
    Widget widget = CameraPreview(cameraController);
    if (videoPath != null) {
      widget = VideoPlayer(videoPlayerController);
    }
    return Transform.scale(
      scale: 1 / cameraController.value.aspectRatio,
      child: Center(
        child: AspectRatio(
          aspectRatio: cameraController.value.aspectRatio,
          child: widget,
        ),
      ),
    );
  }

  void startTimer() {
    if (timer == null) {
      timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
        recodeTime++;
        developer.log("!!!!timer + $recodeTime", name: pageName);
        if (recodeTime >= 10) {
          didLongPressEndCamera();
        }
      });
    }
  }

  void stopTimer() {
    timer.cancel();
  }

  @override
  void didLongPressCamera() {
    developer.log("onLongPressCamera", name: pageName);
    videoPath = null;

    topitem.updateRecordState(RecordState.Recording);
    startVideoRecording().then((String filePath) {
      // if (mounted) setState(() {});
      if (filePath != null)
        developer.log("Saving video to $filePath", name: pageName);
    });

    startTimer();
  }

  @override
  void didLongPressEndCamera() {
    topitem.updateRecordState(RecordState.Preview);
    developer.log("onLongPressEndCamera", name: pageName);
    stopVideoRecording().then((_) {
      // if (mounted) setState(() {});
      developer.log("Video recorded to: $videoPath", name: pageName);
    });
    stopTimer();
  }

  //录制视频后取消
  @override
  void didCancelEvent() {
    developer.log("onCancelEvent", name: pageName);
    topitem.updateRecordState(RecordState.Normal);
    resetData();
    setState(() {});
  }

  //录制视频后完成
  @override
  void didFinishEvent() {
    developer.log("onFinishEvent", name: pageName);
    if (videoPath != null) {
      developer.log("onFinishEvent con $conversationType targetId $targetId",
          name: pageName);
      SightMessage sightMessage = SightMessage.obtain(videoPath, recodeTime);
      if (sightMessage.duration != null && sightMessage.duration > 0) {
        if (conversationType == RCConversationType.Private) {
          sightMessage.destructDuration = isSecretChat
              ? RCDuration.MediaMessageBurnDuration + recodeTime
              : 0;
        }
        // Message message = Message();
        // message.conversationType = conversationType;
        // message.targetId = targetId;
        // message.objectName = SightMessage.objectName;
        // message.content = sightMessage;
        // RongIMClient.sendIntactMessageWithCallBack(message, "", "",
        //     (int messageId, int status, int code) {
        //   String result = "messageId:$messageId status:$status code:$code";
        // });
        RongIMClient.sendMessage(conversationType, targetId, sightMessage);
        _saveVideo(videoPath);
      } else {
        developer.log("sightMessage duration is 0", name: pageName);
      }
      onPop();
    } else {
      developer.log("onFinishEvent videoPath is null", name: pageName);
    }
  }

  void _saveVideo(String videoPath) async {
    final result = await ImageGallerySaver.saveFile(videoPath);
    developer.log("save video result: " + result.toString(), name: pageName);
  }

  @override
  void didPop() {
    onPop();
  }

  @override
  void didSwitchCamera() {
    onSwitchCamera();
  }
}
