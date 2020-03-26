import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'item/bottom_tool_bar.dart';
import 'package:path/path.dart' as path;

import '../util/style.dart';
import 'item/bottom_input_bar.dart';
import 'item/message_content_list.dart';
import 'item/widget_util.dart';

import '../util/user_info_datesource.dart';
import '../util/media_util.dart';
import '../util/event_bus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

enum ConversationStatus {
  Normal, //正常
  VoiceRecorder, //语音输入，页面中间回弹出录音的 gif
}

class ConversationPage extends StatefulWidget {
  final Map arguments;
  ConversationPage({Key key, this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _ConversationPageState(arguments: this.arguments);
}

class _ConversationPageState extends State<ConversationPage>
    implements
        BottomInputBarDelegate,
        MessageContentListDelegate,
        BottomToolBarDelegate {
  Map arguments;
  int conversationType;
  String targetId;

  List phrasesList = new List(); // 快捷回复，短语数组
  List messageDataSource = new List(); //消息数组
  List<Widget> extWidgetList = new List(); //加号扩展栏的 widget 列表
  ConversationStatus currentStatus; //当前输入工具栏的状态
  String textDraft = ''; //草稿内容
  BottomInputBar bottomInputBar;
  BottomToolBar bottomToolBar;
  String titleContent;
  InputBarStatus currentInputStatus;
  ListView phrasesListView;

  MessageContentList messageContentList;
  BaseInfo info;

  bool multiSelect = false; //是否是多选模式
  List selectedMessageIds =
      new List(); //已经选择的所有消息Id，只有在 multiSelect 为 YES,才会有有效值
  List userIdList = new List();

  _ConversationPageState({this.arguments});
  @override
  void initState() {
    super.initState();
    _requestPermissions();

    messageContentList = MessageContentList(
        messageDataSource, multiSelect, selectedMessageIds, this);
    conversationType = arguments["coversationType"];
    targetId = arguments["targetId"];
    currentStatus = ConversationStatus.Normal;
    bottomInputBar = BottomInputBar(this);
    bottomToolBar = BottomToolBar(this);

    if (conversationType == RCConversationType.Private) {
      this.info = UserInfoDataSource.getUserInfo(targetId);
    } else {
      this.info = UserInfoDataSource.getGroupInfo(targetId);
    }

    titleContent = '与 $targetId 的会话';

    //增加 IM 监听
    _addIMHandler();
    //获取默认的历史消息
    onGetHistoryMessages();
    //增加加号扩展栏的 widget
    _initExtentionWidgets();
    //获取草稿内容
    onGetTextMessageDraft();
  }

  @override
  void dispose() {
    super.dispose();
    if (textDraft == null) {
      textDraft = '';
    }
    RongcloudImPlugin.saveTextMessageDraft(
        conversationType, targetId, textDraft);
    RongcloudImPlugin.clearMessagesUnreadStatus(conversationType, targetId);
    EventBus.instance.commit(EventKeys.ConversationPageDispose, null);
    EventBus.instance.removeListener(EventKeys.ReceiveMessage);
    EventBus.instance.removeListener(EventKeys.ReceiveReadReceipt);
    EventBus.instance.removeListener(EventKeys.ReceiveReceiptRequest);
    EventBus.instance.removeListener(EventKeys.ReceiveReceiptResponse);
    MediaUtil.instance.stopPlayAudio();
  }

  void _pullMoreHistoryMessage() async {
    //todo 加载更多历史消息
  }

  ///请求相应的权限，只会在此一次触发
  void _requestPermissions() {
    MediaUtil.instance.requestPermissions();
  }

  _addIMHandler() {
    EventBus.instance.addListener(EventKeys.ReceiveMessage, (map) {
      Message msg = map["message"];
      // int left = map["left"];
      if (msg.targetId == this.targetId) {
        _insertOrReplaceMessage(msg);
      }
      _sendReadReceipt();
    });

    EventBus.instance.addListener(EventKeys.ReceiveReadReceipt, (map) {
      String tId = map["tId"];
      if (tId == this.targetId){
        onGetHistoryMessages();
      }
    });

    EventBus.instance.addListener(EventKeys.ReceiveReceiptRequest, (map) {
      String tId = map["targetId"];
      String messageUId = map["messageUId"];
      if (tId == this.targetId) {
        _sendReadReceiptResponse(messageUId);
      }
    });

    EventBus.instance.addListener(EventKeys.ReceiveReceiptResponse, (map) {
      String tId = map["targetId"];
      print("ReceiveReceiptResponse" + tId + this.targetId);
      if (tId == this.targetId) {
        onGetHistoryMessages();
      }
    });

    RongcloudImPlugin.onMessageSend =
        (int messageId, int status, int code) async {
      Message msg = await RongcloudImPlugin.getMessage(messageId);
      if (msg.targetId == this.targetId) {
        _insertOrReplaceMessage(msg);
      }
    };

    RongcloudImPlugin.onTypingStatusChanged =
        (int conversationType, String targetId, List typingStatus) async {
      if (conversationType == this.conversationType &&
          targetId == this.targetId) {
        if (typingStatus.length > 0) {
          TypingStatus status = typingStatus[typingStatus.length - 1];
          if (status.typingContentType == TextMessage.objectName) {
            titleContent = '对方正在输入...';
          } else if (status.typingContentType == VoiceMessage.objectName ||
              status.typingContentType == 'RC:VcMsg') {
            titleContent = '对方正在讲话...';
          }
        } else {
          titleContent = '与 $targetId 的会话';
        }
        _refreshUI();
      }
    };

    RongcloudImPlugin.onRecallMessageReceived = (Message message) async {
      if (message != null) {
        if (message.targetId == this.targetId) {
          _insertOrReplaceMessage(message);
        }
      }
    };
  }

  onGetHistoryMessages() async {
    print("get history message");

    List msgs = await RongcloudImPlugin.getHistoryMessage(
        conversationType, targetId, 0, 20);
    if (msgs != null) {
      msgs.sort((a, b) => b.sentTime.compareTo(a.sentTime));
      messageDataSource = msgs;
    }
    _sendReadReceipt();
    _refreshMessageContentListUI();
  }

  onGetTextMessageDraft() async {
    textDraft =
        await RongcloudImPlugin.getTextMessageDraft(conversationType, targetId);
    if (bottomInputBar != null) {
      bottomInputBar.setTextContent(textDraft);
    }
    // _refreshUI();
  }

  void _insertOrReplaceMessage(Message message) {
    int index = -1;
    for (int i = 0; i < messageDataSource.length; i++) {
      Message msg = messageDataSource[i];
      if (msg.messageId == message.messageId) {
        index = i;
        break;
      }
    }
    //如果数据源中相同 id 消息，那么更新对应消息，否则插入消息
    if (index >= 0) {
      messageDataSource[index] = message;
    } else {
      messageDataSource.insert(0, message);
    }
    _refreshMessageContentListUI();
  }

  Widget _getExtentionWidget() {
    if (currentInputStatus == InputBarStatus.Extention) {
      return Container(
          height: 180,
          child: GridView.count(
            physics: new NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            padding: EdgeInsets.all(10),
            children: extWidgetList,
          ));
    } else if (currentInputStatus == InputBarStatus.Phrases) {
      return Container(height: 180, child: _buildPhrasesList());
    } else {
      if (currentInputStatus == InputBarStatus.Voice) {
        bottomInputBar.refreshUI();
      }
      return WidgetUtil.buildEmptyWidget();
    }
  }

  ListView _buildPhrasesList() {
    if (phrasesListView != null) {
      return phrasesListView;
    }
    return ListView.separated(
        key: UniqueKey(),
        controller: ScrollController(),
        itemCount: phrasesList.length,
        itemBuilder: (BuildContext context, int index) {
          if (phrasesList.length != null && phrasesList.length > 0) {
            String contentStr = phrasesList[index];
            return GestureDetector(
                onTap: () {
                  _clickPhrases(contentStr);
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Text(contentStr,
                      style: new TextStyle(
                        fontSize: 14, //字体大���
                      )),
                  height: 36,
                ));
          } else {
            return WidgetUtil.buildEmptyWidget();
          }
        },
        separatorBuilder: (BuildContext context, int index) {
          return Container(
            color: Color(0xffC8C8C8),
            height: 0.5,
          );
        });
  }

  void _clickPhrases(String contentStr) async {
    currentInputStatus = InputBarStatus.Normal;
    TextMessage msg = new TextMessage();
    msg.content = contentStr;
    Message message =
        await RongcloudImPlugin.sendMessage(conversationType, targetId, msg);
    _insertOrReplaceMessage(message);
  }

  void _deleteMessage(Message message) {
    //删除消息完成需要刷新消息数据源
    RongcloudImPlugin.deleteMessageByIds([message.messageId], (int code) {
      onGetHistoryMessages();
    });
  }

  void _recallMessage(Message message) async {
    RecallNotificationMessage recallNotifiMessage =
        await RongcloudImPlugin.recallMessage(message, "");
    if (recallNotifiMessage != null) {
      message.content = recallNotifiMessage;
      _insertOrReplaceMessage(message);
    } else {
      showShortToast("撤回失败");
    }
  }

  void showShortToast(String message) {
    Fluttertoast.showToast(
        msg: message, toastLength: Toast.LENGTH_SHORT, timeInSecForIos: 1);
  }

  /// 禁止随意调用 setState 接口刷新 UI，必须调用该接口刷新 UI
  void _refreshUI() {
    setState(() {});
  }

  void _refreshMessageContentListUI() {
    messageContentList.updateData(
        messageDataSource, multiSelect, selectedMessageIds);
  }

  void _initExtentionWidgets() {
    Widget imageWidget =
        WidgetUtil.buildExtentionWidget(Icons.photo, "相册", () async {
      String imgPath = await MediaUtil.instance.pickImage();
      if (imgPath == null) {
        return;
      }
      print("imagepath " + imgPath);
      if (imgPath.endsWith("gif")) {
        GifMessage gifMsg = GifMessage.obtain(imgPath);
        Message msg = await RongcloudImPlugin.sendMessage(
          conversationType, targetId, gifMsg);
        _insertOrReplaceMessage(msg);
      } else {
        ImageMessage imgMsg = ImageMessage.obtain(imgPath);
        Message msg = await RongcloudImPlugin.sendMessage(
          conversationType, targetId, imgMsg);
        _insertOrReplaceMessage(msg);
      }
    });

    Widget cameraWidget =
        WidgetUtil.buildExtentionWidget(Icons.camera, "相机", () async {
      String imgPath = await MediaUtil.instance.takePhoto();
      if (imgPath == null) {
        return;
      }
      print("imagepath " + imgPath);
      String temp = imgPath.replaceAll("file://", "");
      // 保存不需要 file 开头的路径
      _saveImage(temp);
      ImageMessage imgMsg = ImageMessage.obtain(imgPath);
      Message msg = await RongcloudImPlugin.sendMessage(
          conversationType, targetId, imgMsg);
      _insertOrReplaceMessage(msg);
    });

    Widget videoWidget =
        WidgetUtil.buildExtentionWidget(Icons.video_call, "视频", () async {
      print("push to video record page");
      Map map = {"coversationType": conversationType, "targetId": targetId};
      Navigator.pushNamed(context, "/video_record", arguments: map);
    });

    Widget fileWidget =
        WidgetUtil.buildExtentionWidget(Icons.folder, "文件", () async {
      List<File> files = await MediaUtil.instance.pickFiles();
      if (files != null && files.length > 0) {
        for (File file in files) {
          String localPaht = file.path;
          String name = path.basename(localPaht);
          int lastDotIndex = name.lastIndexOf(".");
          FileMessage fileMessage = FileMessage.obtain(localPaht);
          fileMessage.mType = name.substring(lastDotIndex + 1);
          Message msg = await RongcloudImPlugin.sendMessage(
              conversationType, targetId, fileMessage);
          _insertOrReplaceMessage(msg);
          // 延迟400秒，防止过渡频繁的发送消息导致发送失败的问题
          sleep(Duration(milliseconds: 400));
        }
      }
    });

    extWidgetList.add(imageWidget);
    extWidgetList.add(cameraWidget);
    extWidgetList.add(videoWidget);
    extWidgetList.add(fileWidget);

    //初始化短语
    for (int i = 0; i < 10; i++) {
      phrasesList.add('快捷回复测试用例 $i');
    }
  }

  void _saveImage(String imagePath) async {
    final result = await ImageGallerySaver.saveFile(imagePath);
    print("save image result: " + result.toString());
  }

  void _sendReadReceipt() {
    if (conversationType == RCConversationType.Private) {
      for (int i = 0; i < messageDataSource.length; i++) {
        Message message = messageDataSource[i];
        if (message.messageDirection == RCMessageDirection.Receive) {
          RongcloudImPlugin.sendReadReceiptMessage(
              this.conversationType, this.targetId, message.sentTime,
              (int code) {
            if (code == 0) {
              print('sendReadReceiptMessageSuccess');
            } else {
              print('sendReadReceiptMessageFailed:code = + $code');
            }
          });
          break;
        }
      }
    } else if (conversationType == RCConversationType.Group) {
      _sendReadReceiptResponse(null);
    }
    _syncReadStatus();
  }

  void _syncReadStatus() {
    for (int i = 0; i < messageDataSource.length; i++) {
      Message message = messageDataSource[i];
      if (message.messageDirection == RCMessageDirection.Receive) {
        RongcloudImPlugin.syncConversationReadStatus(
            this.conversationType, this.targetId, message.sentTime, (int code) {
          if (code == 0) {
            print('syncConversationReadStatusSuccess');
          } else {
            print('syncConversationReadStatusFailed:code = + $code');
          }
        });
        break;
      }
    }
  }

  ///长按录制语音的 gif 动画
  Widget _buildExtraCenterWidget() {
    if (this.currentStatus == ConversationStatus.VoiceRecorder) {
      return WidgetUtil.buildVoiceRecorderWidget();
    } else {
      return WidgetUtil.buildEmptyWidget();
    }
  }

  void _showExtraCenterWidget(ConversationStatus status) {
    this.currentStatus = status;
    _refreshUI();
  }

  // 底部输入栏
  Widget _buildBottomInputBar() {
    if (multiSelect == true) {
      return bottomToolBar;
    } else {
      return bottomInputBar;
    }
  }

  void _pushToDebug() {
    Map arg = {"coversationType": conversationType, "targetId": targetId};
    Navigator.pushNamed(context, "/chat_debug", arguments: arg);
  }

  // AppBar 右侧按钮
  List _buildRightButtons() {
    if (multiSelect == true) {
      return <Widget>[
        FlatButton(
          child: Text("取消"),
          textColor: Colors.white,
          onPressed: () {
            multiSelect = false;
            selectedMessageIds.clear();
            _refreshMessageContentListUI();
            _refreshUI();
          },
        )
      ];
    } else {
      return <Widget>[
        IconButton(
          icon: Icon(Icons.more),
          onPressed: () {
            _pushToDebug();
          },
        ),
      ];
    }
  }

  void _sendReadReceiptResponse(String messageUId) {
    List readReceiptList = List();
    for (Message message in this.messageDataSource) {
      if ((messageUId != null && message.messageUId == messageUId) ||
          (message.readReceiptInfo != null &&
              message.readReceiptInfo.isReceiptRequestMessage &&
              !message.readReceiptInfo.hasRespond &&
              message.messageDirection == RCMessageDirection.Receive)) {
        readReceiptList.add(message);
      }
    }
    if (readReceiptList.length > 0) {
      RongcloudImPlugin.sendReadReceiptResponse(
          this.conversationType, this.targetId, readReceiptList, (int code) {
        if (code == 0) {
          print('sendReadReceiptResponseSuccess');
        } else {
          print('sendReadReceiptResponseFailed:code = + $code');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(titleContent),
          actions: _buildRightButtons(),
        ),
        body: Container(
          child: Stack(
            children: <Widget>[
              SafeArea(
                child: Column(
                  children: <Widget>[
                    Flexible(
                      child: Column(
                        children: <Widget>[Flexible(child: messageContentList)],
                      ),
                    ),
                    Container(
                      height: multiSelect ? 55 : 82,
                      child: _buildBottomInputBar(),
                    ),
                    _getExtentionWidget(),
                  ],
                ),
              ),
              _buildExtraCenterWidget(),
            ],
          ),
        ));
  }

  @override
  void didTapMessageItem(Message message) {
    print("didTapMessageItem " + message.objectName);
    if (message.content is VoiceMessage) {
      VoiceMessage msg = message.content;
      if (msg.localPath != null && msg.localPath.isNotEmpty && File(msg.localPath).existsSync()) {
        MediaUtil.instance.startPlayAudio(msg.localPath);
      } else {
        MediaUtil.instance.startPlayAudio(msg.remoteUrl);
        RongcloudImPlugin.downloadMediaMessage(message);
      }
      
    } else if (message.content is ImageMessage || message.content is GifMessage) {
      Navigator.pushNamed(context, "/image_preview", arguments: message);
    } else if (message.content is SightMessage) {
      Navigator.pushNamed(context, "/video_play", arguments: message);
    } else if (message.content is FileMessage) {
      Navigator.pushNamed(context, "/file_preview", arguments: message);
    } else if (message.content is RichContentMessage) {
      RichContentMessage msg = message.content;
      Navigator.pushNamed(context, "/webview", arguments: msg.url);
    }
  }

  @override
  void didSendMessageRequest(Message message) {
    print("didSendMessageRequest " + message.objectName);
    RongcloudImPlugin.sendReadReceiptRequest(message, (int code) {
      if (0 == code) {
        print("sendReadReceiptRequest success");
        onGetHistoryMessages();
      } else {
        print("sendReadReceiptRequest error");
      }
    });
  }

  @override
  void didTapMessageReadInfo(Message message) {
    print("didTapMessageReadInfo " + message.objectName);
    Navigator.pushNamed(context, "/message_read_page", arguments: message);
  }

  @override
  void didLongPressMessageItem(Message message, Offset tapPos) {
    Map<String, String> actionMap = {
      RCLongPressAction.DeleteKey: RCLongPressAction.DeleteValue,
      RCLongPressAction.MutiSelectKey: RCLongPressAction.MutiSelectValue
    };
    if (message.messageDirection == RCMessageDirection.Send) {
      actionMap[RCLongPressAction.RecallKey] = RCLongPressAction.RecallValue;
    }
    WidgetUtil.showLongPressMenu(context, tapPos, actionMap, (String key) {
      if (key == RCLongPressAction.DeleteKey) {
        _deleteMessage(message);
      } else if (key == RCLongPressAction.RecallKey) {
        _recallMessage(message);
      } else if (key == RCLongPressAction.MutiSelectKey) {
        this.multiSelect = true;
        currentInputStatus = InputBarStatus.Normal;
        _refreshMessageContentListUI();
        _refreshUI();
      }
      print("当前选中的是 " + key);
    });
  }

  @override
  void didTapUserPortrait(String userId) {
    print("点击了用户头像 " + userId);
  }

  @override
  void didTapItem(Message message) {
    if (multiSelect) {
      final alreadySaved = selectedMessageIds.contains(message.messageId);
      if (alreadySaved) {
        selectedMessageIds.remove(message.messageId);
      } else {
        selectedMessageIds.add(message.messageId);
      }
    }
  }

  @override
  void didLongPressUserPortrait(String userId, Offset tapPos) {
    if (conversationType == RCConversationType.Group) {
      BaseInfo targetInfo = UserInfoDataSource.getUserInfo(userId);
      String content = "@" + userId + " " + targetInfo.name + " ";
      bottomInputBar.setTextContent(content);
      userIdList.add(userId);
    }
    print("长按头像");
  }

  @override
  void willSendText(String text) async {
    TextMessage msg = new TextMessage();
    msg.content = text;

    if (conversationType == RCConversationType.Group) {
      // 群组发送消息携带用户信息
      List<String> tapUserIdList = List();
      for (String userId in this.userIdList) {
        if (text.contains(userId) && (!tapUserIdList.contains(userId))) {
          tapUserIdList.add(userId);
        }
      }
      if (tapUserIdList.length > 0) {
        MentionedInfo mentionedInfo = new MentionedInfo();
        mentionedInfo.type = RCMentionedType.Users;
        mentionedInfo.userIdList = tapUserIdList;
        mentionedInfo.mentionedContent = "这是 mentionedContent";
        msg.mentionedInfo = mentionedInfo;
      }
    }

    Message message =
        await RongcloudImPlugin.sendMessage(conversationType, targetId, msg);
    userIdList.clear();
    _insertOrReplaceMessage(message);
  }

  @override
  void willSendVoice(String path, int duration) async {
    VoiceMessage msg = VoiceMessage.obtain(path, duration);
    Message message =
        await RongcloudImPlugin.sendMessage(conversationType, targetId, msg);
    _insertOrReplaceMessage(message);
  }

  @override
  void didTapExtentionButton() {}

  @override
  void inputStatusDidChange(InputBarStatus status) {
    currentInputStatus = status;
    _refreshUI();
    bottomInputBar.refreshUI();
  }

  @override
  void onTextChange(String text) {
    // print('input ' + text);
    textDraft = text;
    RongcloudImPlugin.sendTypingStatus(
        conversationType, targetId, TextMessage.objectName);
  }

  @override
  void willStartRecordVoice() {
    _showExtraCenterWidget(ConversationStatus.VoiceRecorder);
    RongcloudImPlugin.sendTypingStatus(conversationType, targetId, 'RC:VcMsg');
  }

  @override
  void willStopRecordVoice() {
    _showExtraCenterWidget(ConversationStatus.Normal);
  }

  @override
  void didTapDelegate() {
    List<int> messageIds = new List<int>.from(selectedMessageIds);
    multiSelect = false;
    RongcloudImPlugin.deleteMessageByIds(messageIds, (int code) {
      if (code == 0) {
        onGetHistoryMessages();
      }
    });
  }

  @override
  void willpullMoreHistoryMessage() {
    _pullMoreHistoryMessage();
  }
}
