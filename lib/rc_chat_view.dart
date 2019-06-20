import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RCChatViewController {
  RCChatViewController._(int id)
      : _channel = MethodChannel('rc_chat_view_$id');

  final MethodChannel _channel;
}

typedef void RCChatViewWidgetCreatedCallback(RCChatViewController controller);

class RCChatViewPage extends StatefulWidget {
  final int conversationType;
  final String targetId;
  final RCChatViewWidgetCreatedCallback onChatViewWidgetCreated;

  const RCChatViewPage({
    Key key,
    this.conversationType,
    this.targetId,
    this.onChatViewWidgetCreated,
  }):super(key:key);

  @override
  State<StatefulWidget> createState() {
    return _RCChatViewPageState(this.conversationType,this.targetId);
  }
  
}

class _RCChatViewPageState extends State<RCChatViewPage> {
  int conversationType ;
  String targetId;

  _RCChatViewPageState(int conversationType,String targetId) {
    this.conversationType = conversationType;
    this.targetId = targetId;
  }
  
  @override
  Widget build(BuildContext context) {
    if(defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: "rc_chat_view",
        onPlatformViewCreated:_onPlatformViewCreated,
        creationParams: <String,dynamic>{
          "conversationType":conversationType,
          "targetId":targetId,

        },
        creationParamsCodec: new StandardMessageCodec(),
      );
    }else if(defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: "rc_chat_view",
        onPlatformViewCreated:_onPlatformViewCreated,
        creationParams: <String,dynamic>{
          "conversationType":conversationType,
          "targetId":targetId,

        },
        creationParamsCodec: new StandardMessageCodec(),
      );
    }
    return Text('chat view 还不支持 $defaultTargetPlatform ');
  }

  void _onPlatformViewCreated(int id){
    if(widget.onChatViewWidgetCreated == null){
      return;
    }
    widget.onChatViewWidgetCreated(new RCChatViewController._(id));
  }
  
}