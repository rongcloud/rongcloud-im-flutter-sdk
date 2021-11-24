import 'dart:async'; //timer
import 'dart:developer' as developer;
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:video_player/video_player.dart';

import '../../util/style.dart';
import 'record_bottom_item.dart';
import 'record_top_item.dart';

class VideoRecordPage extends StatefulWidget {
  final Map? arguments;

  VideoRecordPage({Key? key, this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VideoRecordPageState(arguments: this.arguments);
  }
}

class _VideoRecordPageState extends State<VideoRecordPage> implements VideoBottomToolBarDelegate, TopRecordItemDelegate {
  String pageName = "example.VideoRecordPage";
  Map? arguments;
  int? conversationType;
  String? targetId;
  int recodeTime = 0;
  Timer? timer;
  bool? isSecretChat = false;

  CameraController? cameraController;
  VideoPlayerController? videoPlayerController;
  late List<CameraDescription> cameras;
  String? videoPath;
  TopRecordItem? topitem;

  _VideoRecordPageState({this.arguments});

  @override
  void initState() {
    super.initState();
    conversationType = arguments!["coversationType"];
    targetId = arguments!["targetId"];
    isSecretChat = arguments!["isSecretChat"];
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
    cameraController!.initialize().then((_) {
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
    CameraDescription curDes = cameraController!.description;
    CameraDescription targetDes = cameras[0];
    if (cameras[0].name == curDes.name) {
      targetDes = cameras[1];
    }

    await cameraController?.dispose();

    cameraController = CameraController(targetDes, ResolutionPreset.medium);

    cameraController?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  Future<void> startVideoRecording() async {
    if (!cameraController!.value.isInitialized) {
      developer.log("Error: select a camera first.", name: pageName);
      return;
    }

    if (cameraController!.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController?.startVideoRecording();
    } on CameraException catch (e) {
      developer.log(e.toString(), name: pageName);
      return;
    }

    return;
  }

  Future<void> stopVideoRecording() async {
    if (!cameraController!.value.isRecordingVideo) {
      return;
    }

    try {
      XFile? file = await cameraController?.stopVideoRecording();
      videoPath = file?.path;
    } on CameraException catch (e) {
      developer.log(e.toString(), name: pageName);
      return;
    }

    developer.log("rc videoPath $videoPath", name: pageName);

    videoPlayerController = VideoPlayerController.file(File(videoPath!));
    await videoPlayerController?.initialize();
    await videoPlayerController?.play();
    setState(() {});
    return;
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void resetData() {
    recodeTime = 0;
    videoPath = null;
    videoPlayerController?.pause();
    videoPlayerController = null;
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
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
                  aspectRatio: MediaQuery.of(context).size.width / MediaQuery.of(context).size.height,
                  child: Center(
                      child: Stack(
                    children: <Widget>[_getCameraPreviewWidget(), topitem!],
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
    Widget widget = CameraPreview(cameraController!);
    if (videoPath != null) {
      widget = VideoPlayer(videoPlayerController!);
    }
    return Transform.scale(
      scale: 1 / cameraController!.value.aspectRatio,
      child: Center(
        child: AspectRatio(
          aspectRatio: cameraController!.value.aspectRatio,
          child: widget,
        ),
      ),
    );
  }

  void startTimer() {
    if (timer == null) {
      recodeTime++;
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
    timer?.cancel();
    timer = null;
  }

  bool _stoped = false;

  @override
  void didLongPressCamera() async {
    _stoped = false;
    developer.log("onLongPressCamera", name: pageName);
    topitem?.updateRecordState(RecordState.RecordLoading);
    videoPath = null;
    await startVideoRecording();
    if (!_stoped) {
      startTimer();
      topitem?.updateRecordState(RecordState.Recording);
    }
  }

  @override
  Future<bool> didLongPressEndCamera() async {
    _stoped = true;
    developer.log("onLongPressEndCamera", name: pageName);
    await stopVideoRecording();
    stopTimer();
    if (recodeTime <= 0) {
      Fluttertoast.showToast(msg: "录制时间太短！");
      resetData();
      topitem?.updateRecordState(RecordState.Normal);
      return true;
    } else {
      topitem?.updateRecordState(RecordState.Preview);
      return false;
    }
  }

  //录制视频后取消
  @override
  void didCancelEvent() {
    developer.log("onCancelEvent", name: pageName);
    topitem?.updateRecordState(RecordState.Normal);
    stopTimer();
    resetData();
    setState(() {});
  }

  //录制视频后完成
  @override
  void didFinishEvent() {
    developer.log("onFinishEvent", name: pageName);
    if (videoPath != null) {
      developer.log("onFinishEvent con $conversationType targetId $targetId", name: pageName);
      SightMessage sightMessage = SightMessage.obtain(videoPath!, recodeTime);
      if (sightMessage.duration != null && sightMessage.duration! > 0) {
        if (conversationType == RCConversationType.Private) {
          sightMessage.destructDuration = isSecretChat! ? RCDuration.MediaMessageBurnDuration + recodeTime : 0;
        }
        RongIMClient.sendMessage(conversationType!, targetId!, sightMessage);
        _saveVideo(videoPath!);
      } else {
        developer.log("sightMessage duration is 0", name: pageName);
        Fluttertoast.showToast(msg: "视频时长太短！");
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
