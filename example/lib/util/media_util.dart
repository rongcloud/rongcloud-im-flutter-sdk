import 'package:flutter/foundation.dart';
import 'dart:io';

import 'package:audio_recorder/audio_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';

///媒体工具，负责申请权限，选照片，拍照，录音，播放语音
class MediaUtil {
  FlutterSound flutterSound = new FlutterSound();

  factory MediaUtil() => _getInstance();
  static MediaUtil get instance => _getInstance();
  static MediaUtil _instance;
  MediaUtil._internal() {
    // 初始化
  }
  static MediaUtil _getInstance() {
    if (_instance == null) {
      _instance = new MediaUtil._internal();
    }
    return _instance;
  }

  void requestPermissions() {
    PermissionHandler().requestPermissions([PermissionGroup.photos,PermissionGroup.camera,PermissionGroup.microphone]);
  }

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

  void startRecordAudio() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path +
        "/" +
        DateTime.now().millisecondsSinceEpoch.toString() +
        ".aac";
    await AudioRecorder.start(
        path: tempPath, audioOutputFormat: AudioOutputFormat.AAC);
  }

  void stopRecordAudio(Function(String path, int duration) finished) async {
    Recording recording = await AudioRecorder.stop();
    String path = recording.path;

    if (path == null) {
      if (finished != null) {
        finished(null, 0);
      }
    }

    if (TargetPlatform.android == defaultTargetPlatform) {
      path = "file://" + path;
    }
    if (finished != null) {
      finished(path, recording.duration.inSeconds);
    }
  }

  void startPlayAudio(String path) {
    if(flutterSound.isPlaying) {
      stopPlayAudio();
    }
    flutterSound.startPlayer(path);
  }

  void stopPlayAudio() {
    flutterSound.stopPlayer();
  }
}
