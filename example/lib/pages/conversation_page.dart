import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_im_plugin_example/util/style.dart';
import 'package:rongcloud_im_plugin_example/util/time.dart';
import 'package:rongcloud_im_plugin_example/util/user_info_datesource.dart';
import 'item/conversation_item.dart';
import 'item/bottom_inputBar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../util/media_util.dart';
import 'item/widget_util.dart';

enum ConversationStatus{
  Normal,//正常
  VoiceRecorder,//语音输入，页面中间回弹出录音的 gif
}

class ConversationPage extends StatefulWidget {
  final Map arguments;
  ConversationPage({Key key, this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _ConversationPageState(arguments: this.arguments);
}

class _ConversationPageState extends State<ConversationPage> implements ConversationItemDelegate,BottomInputBarDelegate {
  Map arguments;
  int conversationType;
  String targetId;
  List msgList = new List();
  ScrollController _scrollController = ScrollController();
  bool showExtentionWidget = false;
  bool hasLeftMesssage = true;
  ConversationStatus currentStatus;
  List<Widget> extWidgetList = new List();
  RefreshController _refreshController = RefreshController();
  UserInfo user;

  _ConversationPageState({this.arguments});
  @override
  void initState() {
    super.initState();
    _requestPermissions();

    conversationType = arguments["coversationType"];
    targetId = arguments["targetId"];
    currentStatus = ConversationStatus.Normal;

    this.user = UserInfoDataSource.getUserInfo(targetId);

    _addIMHandler();
    onGetHistoryMessages();
    _initExtentionWidgets();

    _scrollController.addListener(() {
      //此处要用 == 而不是 >= 否则会触发多次
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _pullMoreHistoryMessage();
      }
    });
  }

  void _pullMoreHistoryMessage() async {
    if(msgList == null || msgList.length <=0){
      onGetHistoryMessages();
      return;
    }
    if(this.hasLeftMesssage == false) {
      print("本地已经没有更多的消息了");
      return;
    }

    int messageCount = 10;

    Message lastMsg = msgList.last;
    List msgs = await RongcloudImPlugin.getHistoryMessage(conversationType, targetId, lastMsg.messageId, messageCount);
    for(Message m in msgs) {
      msgList.add(m);
    }

    //如果拉取的消息不满足规定的条数，那么说明本地已经没有更多的消息了
    if(msgs.length < messageCount) {
      this.hasLeftMesssage = false;
    }

    //按时间排序
    msgList.sort((a,b) => b.sentTime.compareTo(a.sentTime));
    
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    _refreshUI();
  }

  void _requestPermissions() {
    MediaUtil.instance.requestPermissions();
  }

  _addIMHandler() {
    RongcloudImPlugin.onMessageReceived = (Message msg, int left) {
      if (msg.targetId == this.targetId) {
        _insertOrReplaceMessage(msg);
      }
      _refreshUI();
    };

    RongcloudImPlugin.onMessageSend = (int messageId, int status, int code) async {
      Message msg = await RongcloudImPlugin.getMessage(messageId);
      if(msg.targetId == this.targetId) {
        _insertOrReplaceMessage(msg);
      }
      _refreshUI();
    };
  }

  onGetHistoryMessages() async {
    print("get history message");

    List msgs = await RongcloudImPlugin.getHistoryMessage(
        conversationType, targetId, 0, 20);
    if(msgs != null) {
      msgs.sort((a,b) => b.sentTime.compareTo(a.sentTime));
      msgList = msgs;
    }
    _refreshUI();
  }

  void _insertOrReplaceMessage(Message message) {
    int index = -1;
    for(int i=0;i<msgList.length;i++) {
      Message msg =  msgList[i];
      if(msg.messageId == message.messageId) {
        index = i;
        break;
      }
    }
    if(index >=0) {//如果数据源中相同 id 消息，那么更新对应消息，否则插入消息
      msgList[index] = message;
    }else {
      msgList.insert(0, message);
    }
    _refreshUI();
  }

  Widget _getExtentionWidget() {
    if(showExtentionWidget) {
      return Container(
        height: 180,
        child: GridView.count(
          crossAxisCount: 4,
          padding: EdgeInsets.all(10),
          children: extWidgetList,
        )
      );
    }else {
      return WidgetUtil.buildEmptyWidget();
    }
  }

  /// 禁止随意调用 setState 接口刷新 UI，必须调用该接口刷新 UI
  void _refreshUI() {
    setState(() {
    });
  }


  void _initExtentionWidgets() {
    Widget imageWidget = WidgetUtil.buildExtentionWidget(Icons.photo, "相册", () async {
      String imgPath = await MediaUtil.instance.pickImage();
      if(imgPath == null) {
        return;
      }
      print("imagepath " + imgPath);
      ImageMessage imgMsg = ImageMessage.obtain(imgPath);
      Message msg = await RongcloudImPlugin.sendMessage(
          conversationType, targetId, imgMsg);
      _insertOrReplaceMessage(msg);
    });

    Widget cameraWidget = WidgetUtil.buildExtentionWidget(Icons.camera, "相机", () async {
      String imgPath = await MediaUtil.instance.takePhoto();
      if(imgPath == null) {
        return;
      }

      print("imagepath " + imgPath);
      ImageMessage imgMsg = ImageMessage.obtain(imgPath);
      Message msg = await RongcloudImPlugin.sendMessage(
          conversationType, targetId, imgMsg);
      _insertOrReplaceMessage(msg);
    });

    extWidgetList.add(imageWidget);
    extWidgetList.add(cameraWidget);
  }

  bool _needShowTime(int index) {
    bool needShow = false;
    if(index == 0) {//第一条消息一定显示时间
      needShow = true;
    }else {//如果满足条件，则显示时间
      Message lastMessage = msgList[index-1];
      Message curMessage = msgList[index];
      if(TimeUtil.needShowTime(lastMessage.sentTime, curMessage.sentTime)) {
        needShow = true;
      }
    }
    return needShow;
  }

  ///长按录制语音的 gif 动画
  Widget _buildExtraCenterWidget() {
    if(this.currentStatus == ConversationStatus.VoiceRecorder) {
      return WidgetUtil.buildVoiceRecorderWidget();
    }else {
      return WidgetUtil.buildEmptyWidget();
    }
  }

  void _showExtraCenterWidget(ConversationStatus status) {
    this.currentStatus = status;
    _refreshUI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('与${this.user.name}的会话'),
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            SafeArea(
              child: Column(
                children: <Widget>[
                  Flexible(
                    child: Column(
                      children: <Widget>[
                        Flexible(
                          child: ListView.builder(
                            key: UniqueKey(),
                            shrinkWrap: true,

                            //因为消息超过一屏，ListView 很难滚动到最底部，所以要翻转显示，同时数据源也要逆序
                            reverse: true,
                            controller: _scrollController,
                            itemCount: msgList.length,
                            itemBuilder: (BuildContext context, int index) {
                              if (msgList.length != null && msgList.length > 0) {
                                return ConversationItem(this,msgList[index],_needShowTime(index));
                              } else {
                                return WidgetUtil.buildEmptyWidget();
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 55,
                    child: BottomInputBar(this),
                  ),
                  _getExtentionWidget(),
                ],
              ),
            ),
            _buildExtraCenterWidget(),
          ],
        ),
      )  
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  void didTapMessageItem(Message message) {
    print("didTapMessageItem "+message.content.getObjectName());
    if(message.content is VoiceMessage) {
      VoiceMessage msg = message.content;
      MediaUtil.instance.startPlayAudio(msg.remoteUrl);
    }else if(message.content is ImageMessage) {
      Navigator.pushNamed(context, "/image_preview",arguments: message);
    }
  }

  @override
  void didLongPressMessageItem(Message message,Offset tapPos) {
    Map<String,String> actionMap = {
      RCLongPressAction.CopyKey:RCLongPressAction.CopyValue,
      RCLongPressAction.DeleteKey:RCLongPressAction.DeleteValue
    };
    WidgetUtil.showLongPressMenu(context, tapPos,actionMap,(String key) {
      print("当前选中的是 "+ key);
    });
  }

  @override
  void willSendText(String text) async {
    TextMessage msg = new TextMessage();
    msg.content = text;
    Message message = await RongcloudImPlugin.sendMessage(conversationType, targetId, msg);
    _insertOrReplaceMessage(message);
  }

  @override
  void willSendVoice(String path,int duration) async {
    VoiceMessage msg = VoiceMessage.obtain(path, duration);
    Message message = await RongcloudImPlugin.sendMessage(conversationType, targetId, msg);
    _insertOrReplaceMessage(message);
  }

  @override
  void didTapExtentionButton() {
    
  }

  @override
  void inputStatusDidChange(InputBarStatus status) {
    if(status == InputBarStatus.Extention) {
      showExtentionWidget = true;
    }else {
      showExtentionWidget = false;
    }
    _refreshUI();
  }

  @override
  void willStartRecordVoice() {
    _showExtraCenterWidget(ConversationStatus.VoiceRecorder);
  }

  @override
  void willStopRecordVoice() {
    _showExtraCenterWidget(ConversationStatus.Normal);
  }
}
