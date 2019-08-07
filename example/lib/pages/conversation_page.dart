import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
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
  LongPress,//长按，页面中间会弹出半透明的选择框
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
  ScrollController _controller = ScrollController();
  bool showExtentionWidget = false;
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

    _controller.addListener(() {
      print(
          'scroller 最大值 addListener maxScrollExtent${_controller.position.maxScrollExtent}');
      print('scroller 最大值 addListener pixels${_controller.position.pixels}');
    });
    print("get history message11111");
  }

  void _requestPermissions() {
    MediaUtil.instance.requestPermissions();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('scroller 最大值 oldWidget ${_controller.position.maxScrollExtent}');
  }

  _addIMHandler() {
    RongcloudImPlugin.onMessageReceived = (Message msg, int left) {
      if (msg.targetId == this.targetId) {
        msgList.add(msg);
      }
      //  _controller.jumpTo(0);
      setState(() {});
      _scrollToBottom(100);
    };

    RongcloudImPlugin.onMessageSend = (int messageId, int status, int code) async {
      Message msg = await RongcloudImPlugin.getMessage(messageId);
      if(msg.targetId == this.targetId) {
        msgList.add(msg);
      }

      setState(() {});
      _scrollToBottom(100);
    };
  }

  onGetHistoryMessages() async {
    List msgs = await RongcloudImPlugin.getHistoryMessage(
        conversationType, targetId, 0, 20);
    print("get history message");

    List msg = new List();

    for (Message m in msgs) {
      msg.insert(0, m);
    }
    print(msg);

    setState(() {
      msgList = msg;
      print('scroller   setState 1${_controller.position.maxScrollExtent}');
    });

    print(
        'scroller 最大值onGetHistoryMessages ${_controller.position.maxScrollExtent}');
    // _controller.jumpTo(_controller.position.maxScrollExtent);

    _scrollToBottom(10);
  }

  void _scrollToBottom(int milliseconds) {
    Timer(Duration(milliseconds: milliseconds),
        () => _controller.jumpTo(_controller.position.maxScrollExtent));
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    //  msgList.add(msgList[0]);
    setState(() {});
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    // items.add((items.length+1).toString());
    // if(mounted)

    msgList.add(msgList[0]);
    setState(() {});
    _refreshController.loadComplete();
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

  Widget _buildExtraCenterWidget() {
    if(this.currentStatus == ConversationStatus.LongPress) {
      return WidgetUtil.buildLongPressDialog(["删除消息"],(int index){
        //todo
        print("_buildLongPressDialog "+index.toString());
        _showExtraCenterWidget(ConversationStatus.Normal);
      });
    }else if(this.currentStatus == ConversationStatus.VoiceRecorder) {
      return WidgetUtil.buildVoiceRecorderWidget();
    }else {
      return WidgetUtil.buildEmptyWidget();
    }
  }

  void _showExtraCenterWidget(ConversationStatus status) {
    this.currentStatus = status;
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('与${this.user.name}的会话'),
      ),
      body:Container(
        child: Stack(
          children: <Widget>[
            SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: SmartRefresher(
                      enablePullDown: true,
                      onRefresh: _onRefresh,
                      child: ListView.builder(
                        key: UniqueKey(),
                        controller: _controller,
                        itemCount: msgList.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (msgList.length != null && msgList.length > 0) {
                            return ConversationItem(this,msgList[index],_needShowTime(index));
                          } else {
                            return null;
                          }
                        },
                      ),
                      controller: _refreshController,
                    ),
                  ),
                  Container(
                    height: 55,
                    child: BottomInputBar(this),
                  ),
                  _getExtentionWidget()
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
  void didLongPressMessageItem(Message message) {
    _showExtraCenterWidget(ConversationStatus.LongPress);
  }

  @override
  void willSendText(String text) {
    TextMessage msg = new TextMessage();
    msg.content = text;
    RongcloudImPlugin.sendMessage(conversationType, targetId, msg);
  }

  @override
  void willSendVoice(String path,int duration) {
    VoiceMessage msg = VoiceMessage.obtain(path, duration);
    RongcloudImPlugin.sendMessage(conversationType, targetId, msg);
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
    setState(() {
      
    });
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
