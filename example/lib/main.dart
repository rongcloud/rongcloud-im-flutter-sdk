import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert' show json;
import 'package:flutter/services.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'test_message.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const String privateUserId = "ios";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    //融云 appkey
    String RongAppKey = 'pvxdm17jxjaor';
    //用户 id
    String userId = 'android';
    //通过用户 id 生成的对应融云 token
    String RongIMToken = '/GAO1QE3NeKdxZ8EFWZnXSBpWcymqs7mr0LfCBn63cWXAWvMuW73BKKASyaZmGFGhVYuRiYRxSacloyurITSuw==';

    //1.初始化 im SDK
    RongcloudImPlugin.init(RongAppKey);

    //2.配置 im SDK
    String confString = await DefaultAssetBundle.of(context)
        .loadString("assets/RCFlutterConf.json");
    Map confMap = json.decode(confString.toString());
    RongcloudImPlugin.config(confMap);

    //设置导航服务器和上传文件服务器信息
    //必须在 init 之后 ，connect 之前调用
    //1、如果使用https，则设置为https://cn.xxx.com:port或https://cn.xxx.com格式，其中域名部分也可以是IP，如果不指定端口，将默认使用443端口。
    //2、如果使用http，则设置为cn.xxx.com:port或cn.xxx.com格式，其中域名部分也可以是IP，如果不指定端口，将默认使用80端口。
    // String naviServer = "";
    // String fileServer = "";
    // RongcloudImPlugin.setServerInfo(naviServer, fileServer);

    //3.连接 im SDK
    int rc = await RongcloudImPlugin.connect(RongIMToken);
    print('connect result');
    print(rc);

    //4.刷新当前用户的用户信息
    String portraitUrl = "https://www.rongcloud.cn/pc/images/huawei-icon.png";
    RongcloudImPlugin.updateCurrentUserInfo(userId, "李四", portraitUrl);

    //5.设置监听回调，处理 native 层传递过来的事件
    _addNativeEventHandler();

    List conversationList = await RongcloudImPlugin.getConversationList();
    print("getConversationList + " + conversationList.toString());

    RongcloudImPlugin.getTotalUnreadCount((num, code) {
      print("getTotalUnreadCount " + num.toString() + " code " + code.toString());
    });

    RongcloudImPlugin.getUnreadCount(RCConversationType.Private, '1001', (num,code) {
      print("getUnreadCount " + num.toString() + " code " + code.toString());
    });

    RongcloudImPlugin.getUnreadCountConversationTypeList([RCConversationType.Private,RCConversationType.Group], true, (num,code){
      print("getUnreadCountConversationTypeList " + num.toString() + " code " + code.toString());
    });

    //发送语音消息
    // VoiceMessage voiceMsg = new VoiceMessage();
    // voiceMsg.localPath = "local/path/to/voice/file";
    // voiceMsg.duration = 5;
    // Message msg = await RongcloudImPlugin.sendMessage(RCConversationType.Private, "1002", voiceMsg);
    // print("sendVoiceMessage " + msg.messageId.toString());

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    TextMessage msgT = new TextMessage();
    msgT.content = "xxxxxxxxx";
    RongcloudImPlugin.insertIncomingMessage(RCConversationType.Private, "1002", "1002", 1, msgT , 0, (msg,code){
      print("insertIncomingMessage " + msg.content.encode() + " code " + code.toString());
    });

    RongcloudImPlugin.insertOutgoingMessage(RCConversationType.Private, "1001", 10, msgT, 0, (msg,code){
      print("insertOutgoingMessage " + msg.content.encode() + " code " + code.toString());
    });


    List msgList = await RongcloudImPlugin.getHistoryMessage(RCConversationType.Private, "1002", 0, 0);
    print("getHistoryMessage " + msgList.length.toString());

    RongcloudImPlugin.removeConversation(RCConversationType.Private, "1001", (success) {
      if(success) {
        print("删除会话成功");
      }
    });

    RongcloudImPlugin.getBlockedConversationList([RCConversationType.Private,RCConversationType.Group], (List<Conversation> conversationList, int code) {
      if(code == 0 && conversationList != null) {
        for(Conversation con in conversationList) {
          print("getBlockedConversationList  success "+ con.targetId.toString());
        }
      }else {
        print("getBlockedConversationList error "+code.toString());
      }
    });

    setState(() {});
  }

  _addNativeEventHandler() {
    //消息发送结果回调
    RongcloudImPlugin.onMessageSend = (int messageId,int status,int code) {
      print("send message messsageId:"+messageId.toString()+" status:"+status.toString()+" code:"+code.toString());
    };

    //消息接收回调
    RongcloudImPlugin.onMessageReceived = (Message msg,int left) {
      print("receive message messsageId:"+msg.messageId.toString()+" left:"+left.toString());
    };

    //媒体消息（图片/语音消息）上传媒体进度的回调
    RongcloudImPlugin.onUploadMediaProgress = (int messageId,int progress) {
      print("upload media messsageId:"+messageId.toString()+" progress:"+progress.toString());
    };

    //加入聊天室结果回调
    RongcloudImPlugin.onJoinChatRoom = (String targetId,int status) {
      print("join chatroom:"+targetId+" status:"+status.toString());
    };

    //退出聊天室结果回调
    RongcloudImPlugin.onQuitChatRoom = (String targetId,int status) {
      print("quit chatroom:"+targetId+" status:"+status.toString());
    };
  }

  onSendMessage() async {
    TextMessage txtMessage = new TextMessage();
    txtMessage.content = "这条消息来自 flutter";
    Message msg = await RongcloudImPlugin.sendMessage(
        RCConversationType.Private, privateUserId, txtMessage);
    print("send message start senderUserId = " + msg.senderUserId);
  }

  onSendImageMessage() async {
    // ImageMessage imgMessage = new ImageMessage();
    // imgMessage.localPath = "image/local/path.jpg";
    // Message msg = await RongcloudImPlugin.sendMessage(
    //     RCConversationType.Private, privateUserId, imgMessage);
    // print("send image message start senderUserId = " + msg.senderUserId);
  }

  onSendVoiceMessage() async {
    VoiceMessage voiceMsg = new VoiceMessage();
    voiceMsg.localPath = "voice/local/path";
    voiceMsg.duration = 13;
    Message msg = await RongcloudImPlugin.sendMessage(
        RCConversationType.Private, privateUserId, voiceMsg);
    if (msg != null) {
      print("send voice message start senderUserId = " + msg.senderUserId);
    }
  }

  onSendTestMessage() async {
    TestMessage testMessage = new TestMessage();
    testMessage.content = "这条消息是 flutter 内自定义的消息，还需要再原生的页面注册";
    Message msg = await RongcloudImPlugin.sendMessage(
        RCConversationType.Private, privateUserId, testMessage);
    print("send test message start senderUserId = " + msg.senderUserId);
  }

  onGetHistoryMessages() async {
    List msgs = await RongcloudImPlugin.getHistoryMessage(
        RCConversationType.Private, privateUserId, 0, 10);
    print("get history message");
    for (Message m in msgs) {
      print("sentTime = " + m.sentTime.toString());
    }
  }

  onGetConversationList() async {
    List cons = await RongcloudImPlugin.getConversationList();
    for (Conversation con in cons) {
      print("conversation latestMessageId " + con.latestMessageId.toString());
    }
  }

  onJoinChatRoom() {
    RongcloudImPlugin.joinChatRoom("testchatroomId", 10);
  }

  onGetRemoteMessage() {
    RongcloudImPlugin.getRemoteHistoryMessages(RCConversationType.Private, "1001", 0, 20,(List<Message> msgList,int code) {
      if(code == 0 && msgList != null) {
        if (msgList.length > 0) {
          for(Message msg in msgList) {
            print("getRemoteHistoryMessages  success "+ msg.messageId.toString());
          }
        }
      }else {
        print("getRemoteHistoryMessages error "+code.toString());
      }
    });
  }

  onQuitChatRoom() {
    RongcloudImPlugin.quitChatRoom("testchatroomId");
  }

  onGetChatRoomInfo() async {
    ChatRoomInfo chatRoomInfo = await RongcloudImPlugin.getChatRoomInfo(
        "testchatroomId", 10, RCChatRoomMemberOrder.Desc);
    print("onGetChatRoomInfo targetId =" + chatRoomInfo.targetId);
  }

  @override
  Widget build(BuildContext context) {
    // return MaterialApp(
    //   title: 'Flutter Demo',
    //   theme: ThemeData(
    //     primarySwatch: Colors.blue,
    //   ),
    //   home: IndexPage(),
    // );
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: 700,
              child: Column(
                children: <Widget>[
                  Row(children: <Widget>[]),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              onPressed: () => onSendMessage(),
                              child: Text("sendMessage"),
                              color: Colors.blueAccent,
                              textColor: Colors.white,
                            ),
                          )
                        ],
                      )),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              onPressed: () => onSendVoiceMessage(),
                              child: Text("onSendVoiceMessage"),
                              color: Colors.blueAccent,
                              textColor: Colors.white,
                            ),
                          )
                        ],
                      )),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              onPressed: () => onSendTestMessage(),
                              child: Text("onSendTestMessage"),
                              color: Colors.blueAccent,
                              textColor: Colors.white,
                            ),
                          )
                        ],
                      )),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              onPressed: () => onGetHistoryMessages(),
                              child: Text("onGetHistoryMessages"),
                              color: Colors.blueAccent,
                              textColor: Colors.white,
                            ),
                          )
                        ],
                      )),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              onPressed: () => onGetConversationList(),
                              child: Text("onGetConversationList"),
                              color: Colors.blueAccent,
                              textColor: Colors.white,
                            ),
                          )
                        ],
                      )),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              onPressed: () => onJoinChatRoom(),
                              child: Text("onJoinChatRoom"),
                              color: Colors.blueAccent,
                              textColor: Colors.white,
                            ),
                          )
                        ],
                      )),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              onPressed: () => onGetRemoteMessage(),
                              child: Text("onGetRemoteMessage"),
                              color: Colors.blueAccent,
                              textColor: Colors.white,
                            ),
                          )
                        ],
                      )),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              onPressed: () => onGetChatRoomInfo(),
                              child: Text("onGetChatRoomInfo"),
                              color: Colors.blueAccent,
                              textColor: Colors.white,
                            ),
                          )
                        ],
                      ))
                ],
              )),
        ),
      ),
    );
  }
}
