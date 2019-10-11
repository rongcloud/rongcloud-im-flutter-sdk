import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class VideoRecordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _VideoRecordPageState();
  }
}

class _VideoRecordPageState extends State<VideoRecordPage> {
  CameraController cameraController;
  List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  void dispose() {
    cameraController?.dispose();
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

  void onRecordCancel() {
    print("onRecordCancel");
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

  void onTapCamera() {
    print("onTapCamera");
  }

  void onLongPressCamera() {
    print("onLongPressCamera");
  }

  void onLongPressEndCamera() {
    print("onLongPressEndCamera");
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
          _getCameraPreview(),
          _getSwitchCameraIcon(),
          _getBottomToolbar(),
        ],
      )),
    );
  }

  Widget _getCameraPreview() {
    return CameraPreview(cameraController);
  }

  Widget _getSwitchCameraIcon() {
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
              onRecordCancel();
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

  Widget _getBottomToolbar() {
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
}
