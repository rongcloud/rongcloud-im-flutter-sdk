import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';

///媒体工具，负责申请权限，选照片，拍照，录音，播放语音
class MediaUtil {
  FlutterSound flutterSound = new FlutterSound();

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
  void requestPermissions() {
    PermissionHandler().requestPermissions([
      PermissionGroup.photos,
      PermissionGroup.camera,
      PermissionGroup.microphone,
      PermissionGroup.storage
    ]);
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
    print("debug 准备录音并检查权限");
    bool hasPermission = await FlutterAudioRecorder.hasPermissions;
    if (hasPermission) {
      print("debug 录音权限已开启");
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path +
          "/" +
          DateTime.now().millisecondsSinceEpoch.toString() +
          ".aac";
      _recorder = FlutterAudioRecorder(tempPath,
          audioFormat: AudioFormat.AAC); // or AudioFormat.WAV
      await _recorder.initialized;
      await _recorder.start();
      print("debug 开始录音");
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
    print("Stop recording: ${result.path}");
    print("Stop recording: ${result.duration}");
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
    if (flutterSound.isPlaying) {
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
