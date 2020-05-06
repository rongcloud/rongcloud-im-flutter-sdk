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
    print("onPop");
    resetData();
    Navigator.pop(context);
  }

  void onSwitchCamera() async {
    print("onSwitchCamera");
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
      print('Error: select a camera first.');
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
      print(e);
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
      print(e);
      return null;
    }

    print("rc videoPath $videoPath");

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
        print('!!!!timer + $recodeTime');
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
    print("onLongPressCamera");
    videoPath = null;

    topitem.updateRecordState(RecordState.Recording);
    startVideoRecording().then((String filePath) {
      // if (mounted) setState(() {});
      if (filePath != null) print('Saving video to $filePath');
    });

    startTimer();
  }

  @override
  void didLongPressEndCamera() {
    topitem.updateRecordState(RecordState.Preview);
    print("onLongPressEndCamera");
    stopVideoRecording().then((_) {
      // if (mounted) setState(() {});
      print('Video recorded to: $videoPath');
    });
    stopTimer();
  }

  //录制视频后取消
  @override
  void didCancelEvent() {
    print("onCancelEvent");
    topitem.updateRecordState(RecordState.Normal);
    resetData();
    setState(() {});
  }

  //录制视频后完成
  @override
  void didFinishEvent() {
    print("onFinishEvent");
    if (videoPath != null) {
      print("onFinishEvent con $conversationType targetId $targetId");
      SightMessage sightMessage = SightMessage.obtain(videoPath, recodeTime);
      if (conversationType == RCConversationType.Private) {
        sightMessage.destructDuration =
            isSecretChat ? RCDuration.MediaMessageBurnDuration + recodeTime : 0;
      }
      RongIMClient.sendMessage(conversationType, targetId, sightMessage);
      _saveVideo(videoPath);
      onPop();
    } else {
      print("onFinishEvent videoPath is null");
    }
  }

  void _saveVideo(String videoPath) async {
    final result = await ImageGallerySaver.saveFile(videoPath);
    print("save video result: " + result.toString());
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
