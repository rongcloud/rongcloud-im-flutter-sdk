import 'dart:io';

import 'package:flutter/widgets.dart';

import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:video_player/video_player.dart';

class VideoPlayPage extends StatefulWidget {
  final Message message;
  const VideoPlayPage({Key key, this.message}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _VideoPlayPageState(message);
  }
}

class _VideoPlayPageState extends State<VideoPlayPage> {
  final Message message;

  VideoPlayerController videoPlayerController;
  SightMessage sightMessage;

  _VideoPlayPageState(this.message);

  @override
  void initState() {
    super.initState();
    initVideoController();
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    super.dispose();
  }

  void initVideoController() async {
    sightMessage = message.content;
    if (sightMessage.localPath != null && sightMessage.localPath != "") {
      videoPlayerController =
          VideoPlayerController.file(File(sightMessage.localPath));
    } else {
      //TODO 是否需要做缓存？ VideoPlayerController.network 每次都会下载一遍视频
      videoPlayerController =
          VideoPlayerController.network(sightMessage.remoteUrl);
    }
    videoPlayerController.initialize();
    await videoPlayerController.play();
    setState(() {});
  }

  void onPop() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        VideoPlayer(videoPlayerController),
        Container(
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
                    width: 25,
                    height: 25,
                    child: Image.asset(
                        "assets/images/sight_top_toolbar_close.png")),
              )
            ],
          ),
        )
      ],
    );
  }
}
