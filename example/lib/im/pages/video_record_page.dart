import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class VideoRecordPage extends StatefulWidget {
  final Map arguments;

  VideoRecordPage({Key key, this.arguments}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _VideoRecordPageState(arguments: this.arguments);
  }
}

class _VideoRecordPageState extends State<VideoRecordPage> {
  Map arguments;
  int conversationType;
  String targetId;

  CameraController cameraController;
  VideoPlayerController videoPlayerController;
  List<CameraDescription> cameras;
  String videoPath;
  String imagePath;

  _VideoRecordPageState({this.arguments});

  @override
  void initState() {
    super.initState();
    conversationType = arguments["coversationType"];
    targetId = arguments["targetId"];
    initCamera();
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

  void onTapCamera() async {
    print("onTapCamera");
    imagePath = null;
  }

  void onLongPressCamera() {
    print("onLongPressCamera");
    videoPath = null;
    startVideoRecording().then((String filePath) {
      // if (mounted) setState(() {});
      if (filePath != null) print('Saving video to $filePath');
    });
  }

  void onLongPressEndCamera() {
    print("onLongPressEndCamera");
    stopVideoRecording().then((_) {
      // if (mounted) setState(() {});
      print('Video recorded to: $videoPath');
    });
  }

  // 录制视频后取消
  void onCancelEvent() {
    print("onCancelEvent");
    resetData();
    setState(() {});
  }

  //录制视频后完成
  void onFinishEvent() {
    print("onFinishEvent");
    if (videoPath != null) {
      SightMessage sightMessage = SightMessage.obtain(videoPath, 5);
      print("onFinishEvent con $conversationType targetId $targetId");
      RongcloudImPlugin.sendMessage(conversationType, targetId, sightMessage);
      onPop();
    } else {
      print("onFinishEvent videoPath is null");
    }
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

  void resetData(){
    imagePath = null;
    videoPath = null;
    if(videoPlayerController.value.isPlaying) {
      videoPlayerController.pause();
    }
    videoPlayerController = null;
    cameraController = null;
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController == null) {
      return Container();
    }
    if (!cameraController.value.isInitialized) {
      return Container();
    }
    return AspectRatio(
      aspectRatio: cameraController.value.aspectRatio,
      child: Center(
          child: Stack(
        children: <Widget>[
          _getCameraPreviewWidget(),
          _getTopCameraIconWidget(),
          _getBottomToolbarWidget(),
        ],
      )),
    );
  }

  Widget _getCameraPreviewWidget() {
    Widget widget = CameraPreview(cameraController);
    if (imagePath != null) {
      widget = Image.file(File(imagePath));
    } else if (videoPath != null) {
      widget = VideoPlayer(videoPlayerController);
    }
    return widget;
  }

  Widget _getTopCameraIconWidget() {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 40,
          ),
          GestureDetector(
            onTap: () {
              onPop();
            },
            child: Container(
              width: 35,
              height: 35,
              child: Image.asset("assets/images/sight_top_toolbar_close.png"),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width - 160,
            height: 50,
          ),
          GestureDetector(
            onTap: () {
              onSwitchCamera();
            },
            child: Container(
              width: 50,
              height: 50,
              child: Image.asset("assets/images/sight_camera_switch.png"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getBottomToolbarWidget() {
    Widget widget = _getBottomRecordToolbar();
    if (videoPlayerController != null &&
        videoPlayerController.value.isPlaying) {
      widget = _getBottomChoiceToolbar();
    }
    return widget;
  }

  Widget _getBottomRecordToolbar() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height - 150,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  onTapCamera();
                },
                onLongPress: () {
                  onLongPressCamera();
                },
                onLongPressEnd: (LongPressEndDetails details) {
                  onLongPressEndCamera();
                },
                child: Container(
                  width: 70,
                  height: 70,
                  child: Image.asset("assets/images/sight_preview_tap.png"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _getBottomChoiceToolbar() {
    double itemWidth = 70;
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height - 150,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  onCancelEvent();
                },
                child: Container(
                  width: itemWidth,
                  height: itemWidth,
                  child: Image.asset("assets/images/sight_preview_cancel.png"),
                ),
              ),
              SizedBox(
                width: 100,
              ),
              GestureDetector(
                onTap: () {
                  onFinishEvent();
                },
                child: Container(
                  width: itemWidth,
                  height: itemWidth,
                  child: Image.asset("assets/images/sight_preview_done.png"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
