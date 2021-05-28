import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer;

///媒体工具，负责申请权限，选照片，拍照，录音，播放语音
class MediaUtil {
  FlutterSound flutterSound = new FlutterSound();

  String pageName = "example.MediaUtil";
  factory MediaUtil() => _getInstance();
  static MediaUtil get instance => _getInstance();
  static MediaUtil _instance;

  FlutterAudioRecorder _recorder;
  MediaUtil._internal() {
    // 初始化
  }
  static MediaUtil _getInstance() {
    if (_instance == null) {
      _instance = new MediaUtil._internal();
    }
    return _instance;
  }

  //请求权限：相册，相机，麦克风
  void requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.photos,
      Permission.camera,
      Permission.microphone,
      Permission.storage
    ].request();
    for (var status in statuses.keys) {
      developer.log(status.toString() + "：" + statuses[status].toString(),
          name: pageName);
    }
  }

  //拍照，成功则返回照片的本地路径，注：Android 必须要加 file:// 头
  Future<String> takePhoto() async {
    File imgfile = await ImagePicker.pickImage(source: ImageSource.camera);
    if (imgfile == null) {
      return null;
    }
    String imgPath = imgfile.path;
    if (TargetPlatform.android == defaultTargetPlatform) {
      imgPath = "file://" + imgfile.path;
    }
    return imgPath;
  }

  //从相册选照片，成功则返回照片的本地路径，注：Android 必须要加 file:// 头
  Future<String> pickImage() async {
    File imgfile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imgfile == null) {
      return null;
    }
    String imgPath = imgfile.path;
    if (TargetPlatform.android == defaultTargetPlatform) {
      imgPath = "file://" + imgfile.path;
    }
    return imgPath;
  }

  //选择本地文件，成功返回文件信息
  Future<List<File>> pickFiles() async {
    List<File> files = await FilePicker.getMultiFile();
    return files;
  }

  //开始录音
  void startRecordAudio() async {
    developer.log("debug 准备录音并检查权限", name: pageName);
    bool hasPermission = await FlutterAudioRecorder.hasPermissions;
    if (hasPermission) {
      developer.log("debug 录音权限已开启", name: pageName);
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path +
          "/" +
          DateTime.now().millisecondsSinceEpoch.toString() +
          ".aac";
      _recorder = FlutterAudioRecorder(tempPath,
          audioFormat: AudioFormat.AAC); // or AudioFormat.WAV
      await _recorder.initialized;
      await _recorder.start();
      developer.log("debug 开始录音", name: pageName);
    } else {
      Fluttertoast.showToast(
          msg: "录音权限未开启",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.grey[800],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  //录音结束，通过 finished 返回本地路径和语音时长，注：Android 必须要加 file:// 头
  void stopRecordAudio(Function(String path, int duration) finished) async {
    var result = await _recorder.stop();
    developer.log(
        "Stop recording: path = ${result.path}，duration = ${result.duration}",
        name: pageName);
    developer.log("Stop recording: duration = ${result.duration}",
        name: pageName);
    if (result.duration.inSeconds > 0) {
      String path = result.path;
      if (path == null) {
        if (finished != null) {
          finished(null, 0);
        }
      }
      if (TargetPlatform.android == defaultTargetPlatform) {
        path = "file://" + path;
      }
      if (finished != null) {
        finished(path, result.duration.inSeconds);
      }
    } else {
      Fluttertoast.showToast(
          msg: "说话时间太短",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.grey[800],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  //播放语音
  void startPlayAudio(String path) {
    if (flutterSound.audioState == t_AUDIO_STATE.IS_PLAYING) {
      stopPlayAudio();
    }
    flutterSound.startPlayer(path);
  }

  //停止播放语音
  void stopPlayAudio() {
    flutterSound.stopPlayer();
  }

  String getCorrectedLocalPath(String localPath) {
    String path = localPath;
    //Android 本地路径需要删除 file:// 才能被 File 对象识别
    if (TargetPlatform.android == defaultTargetPlatform) {
      path = localPath.replaceFirst("file://", "");
    }
    return path;
  }
}
