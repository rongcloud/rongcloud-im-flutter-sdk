import 'dart:developer' as developer;
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

///媒体工具，负责申请权限，选照片，拍照，录音，播放语音
class MediaUtil {
  String pageName = "example.MediaUtil";

  factory MediaUtil() => _getInstance()!;

  static MediaUtil? get instance => _getInstance();
  static MediaUtil? _instance;

  AudioPlayer player = AudioPlayer();

  MediaUtil._internal() {
    // 初始化
  }

  static MediaUtil? _getInstance() {
    if (_instance == null) {
      _instance = new MediaUtil._internal();
    }
    return _instance;
  }

  //请求权限：相册，相机，麦克风
  void requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [Permission.photos, Permission.camera, Permission.microphone, Permission.storage].request();
    for (var status in statuses.keys) {
      developer.log(status.toString() + "：" + statuses[status].toString(), name: pageName);
    }
  }

  //拍照，成功则返回照片的本地路径，注：Android 必须要加 file:// 头
  Future<String?> takePhoto() async {
    File? imgfile = (await ImagePicker().pickImage(source: ImageSource.camera)) as File?;
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
  Future<String?> pickImage() async {
    XFile? imgfile = await ImagePicker().pickImage(source: ImageSource.gallery);
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
  Future<List<File>?> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    List<File>? files = result?.paths.map((path) => File(path!)).toList();
    return files;
  }

  //开始录音
  void startRecordAudio() async {
    developer.log("debug 准备录音并检查权限", name: pageName);
    // Check and request permission
    bool hasPermission = await Record().hasPermission();

    if (hasPermission) {
      developer.log("debug 录音权限已开启", name: pageName);
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path + "/" + DateTime.now().millisecondsSinceEpoch.toString() + ".aac";
      developer.log("debug 开始录音", name: pageName);
      // Start recording
      await Record().start(
        path: tempPath, // required
        encoder: AudioEncoder.AAC, // by default
      );
    } else {
      Fluttertoast.showToast(
        msg: "录音权限未开启",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[800],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  //录音结束，通过 finished 返回本地路径和语音时长，注：Android 必须要加 file:// 头
  void stopRecordAudio(Function(String? path, int? duration) finished) async {
    String? audioPath = await Record().stop();
    Duration? durationA = await player.setFilePath(audioPath!);

    int duration = durationA!.inSeconds;

    developer.log("Stop recording: path = $audioPath，duration = $duration", name: pageName);
    developer.log("Stop recording: duration = $duration", name: pageName);
    if (duration > 0) {
      String? path = audioPath;
      if (path == null) {
        finished(null, 0);
      }
      if (TargetPlatform.android == defaultTargetPlatform) {
        path = "file://" + path;
      }
      finished(path, duration);
    } else {
      Fluttertoast.showToast(
        msg: "说话时间太短",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[800],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  //播放语音
  void startPlayAudio(String path) {
    if (player.playing) {
      stopPlayAudio();
    }
    player.setFilePath(path);
    player.play();
  }

  //停止播放语音
  void stopPlayAudio() {
    player.stop();
  }

  String? getCorrectedLocalPath(String? localPath) {
    String? path = localPath;
    //Android 本地路径需要删除 file:// 才能被 File 对象识别
    if (TargetPlatform.android == defaultTargetPlatform) {
      path = localPath!.replaceFirst("file://", "");
    }
    return path;
  }
}
