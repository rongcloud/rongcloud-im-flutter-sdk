import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'item/widget_util.dart';
import '../../im/util/file.dart';
import 'package:open_file/open_file.dart';

class FilePreviewPage extends StatefulWidget {
  final Message message;
  const FilePreviewPage({Key key, this.message}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FilePreviewState(message);
  }
}

class _FilePreviewState extends State<FilePreviewPage> {
  final Message message;
  FileMessage fileMessage;
  static const int DOWNLOAD_SUCCESS = 0;
  static const int DOWNLOAD_PROGRESS = 10;
  static const int DOWNLOAD_CANCELED = 20;
  int currentStatus = -1;
  int mProgress;
  _FilePreviewState(this.message);

  @override
  void initState() {
    super.initState();
    fileMessage = message.content;
    _addIMHander();
  }

  @override
  Widget build(BuildContext context) {
    String fileStatuStr;
    if (currentStatus == DOWNLOAD_PROGRESS) {
      fileStatuStr = "正在下载...$mProgress%";
    } else {
      fileStatuStr = _isFileNeedDowload() ? "打开文件" : "开始下载";
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("文件预览"),
        ),
        body: Container(
          alignment: Alignment.center,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(top: 60),
                    child: Image.asset(
                      FileUtil.fileTypeImagePath(fileMessage.mName),
                      width: 70,
                      height: 70,
                    )),
                Container(
                    margin: EdgeInsets.only(top: 15),
                    child: Text(fileMessage.mName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16, color: const Color(0xff000000)))),
                Container(
                    margin: EdgeInsets.only(top: 15),
                    child: Text(FileUtil.formatFileSize(fileMessage.mSize),
                        style: TextStyle(
                            fontSize: 12, color: const Color(0xff888888)))),
                getProgress(),
                Container(
                    margin: EdgeInsets.fromLTRB(40, 50, 40, 0),
                    width: double.infinity,
                    height: 60,
                    child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Color(0xff4876FF)),
                        ),
                        onPressed: () {
                          _fileButtonClick();
                        },
                        child: Text(fileStatuStr,
                            style: TextStyle(
                                fontSize: 16,
                                color: const Color(0xFFFFFFFF))))),
              ]),
        ));
  }

  Widget getProgress() {
    if (currentStatus == DOWNLOAD_PROGRESS) {
      return Container(
        margin: EdgeInsets.only(top: 12),
        child: SizedBox(
          //限制进度条的高度
          height: 6.0,
          //限制进度条的宽度
          width: 300,
          child: new LinearProgressIndicator(
              //0~1的浮点数，用来表示进度多少;如果 value 为 null 或空，则显示一个动画，否则显示一个定值
              value: mProgress / 100,
              //背景颜色
              backgroundColor: const Color(0xff888888),
              //进度颜色
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue)),
        ),
      );
    }
    return WidgetUtil.buildEmptyWidget();
  }

  _addIMHander() {
    RongIMClient.onDownloadMediaMessageResponse =
        (int code, int progress, int messageId, Message message) async {
      if (this.message.messageId == messageId) {
        if (code == DOWNLOAD_SUCCESS) {
          FileMessage content = message.content;
          currentStatus = DOWNLOAD_SUCCESS;
          fileMessage.localPath = content.localPath;
        } else if (code == DOWNLOAD_PROGRESS) {
          currentStatus = DOWNLOAD_PROGRESS;
          mProgress = progress;
        } else if (code == DOWNLOAD_CANCELED) {
          currentStatus = DOWNLOAD_CANCELED;
        } else {
          currentStatus = -1;
        }
        _refreshUI();
      }
    };
  }

  _refreshUI() {
    setState(() {});
  }

  _fileButtonClick() {
    if (currentStatus != DOWNLOAD_PROGRESS) {
      if (!_isFileNeedDowload()) {
        _startDownload();
      } else {
        _openFile();
      }
    }
  }

  void _startDownload() async {
    if (await Permission.storage.status == PermissionStatus.granted) {
      RongIMClient.downloadMediaMessage(message);
    } else {
      Permission.storage.request();
    }
  }

  void _openFile() {
    String path = handlePath(fileMessage.localPath);
    OpenFile.open(path);
  }

  bool _isFileNeedDowload() {
    if (fileMessage != null) {
      String localPath = fileMessage.localPath;
      if (localPath != null && localPath.isNotEmpty) {
        File localFile = File(handlePath(localPath));
        bool isExists = localFile.existsSync();
        return isExists;
      }
    }
    return false;
  }

  String handlePath(String path) {
    if (path.startsWith("file://")) {
      return path.replaceAll("file://", "");
    }
    return path;
  }
}
