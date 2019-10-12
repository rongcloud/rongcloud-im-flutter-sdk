import 'package:flutter/widgets.dart';

import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

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

  _VideoPlayPageState(this.message);

  @override
  Widget build(BuildContext context) {
    return Text("_VideoPlayPageState");
  }
}