# 融云 IM flutter plugin

本文档讲解了如何使用 IM 的 flutter plugin

[flutter 官网](https://flutter.dev/)

[融云 iOS 文档集成](https://www.rongcloud.cn/docs/ios.html)

[融云 Android 文档集成](https://www.rongcloud.cn/docs/android.html)


# 前期准备

[融云官网](https://www.rongcloud.cn) 申请开发者账号

通过管理后台的 "基本信息"->"App Key" 获取 appkey

通过管理后台的 "IM 服务"—>"API 调用"->"用户服务"->"获取 Token"，通过用户 id 获取 IMToken


# 依赖 IMKit flutter plugin

在项目的 `pubspec.yaml` 中写如下依赖

```
dependencies:
  flutter:
    sdk: flutter

  rongcloud_im_plugin: ^0.0.16
```

然后在项目路径执行 `flutter packages get` 来下载 flutter plugin

# 集成步骤


## 1.初始化 SDK

```
RongcloudImPlugin.init(RongAppKey);
```

## 2.配置 SDK

### 2.1 在项目目录创建 `assets` 文件夹，并将 `RCFlutterConf.json` 放入该文件夹

### 2.2 在项目 `pubspec.yaml` 中的写入下面的配置

```
assets:
  - assets/RCFlutterConf.json
```

### 2.3 代码

```
String confString = await DefaultAssetBundle.of(context).loadString("assets/RCFlutterConf.json");
Map confMap = json.decode(confString.toString());
RongcloudImPlugin.config(confMap);
```

## 3.连接 IM

```
int rc = await RongcloudImPlugin.connect(RongIMToken);
print('connect result');
print(rc);
```

# API 调用

## 断开 IM 连接

```
RongcloudImPlugin.disconnect(bool needPush)
```

## 发送消息

发送文本消息

```
onSendMessage() async{
      TextMessage txtMessage = new TextMessage();
      txtMessage.content = "这条消息来自 flutter";
      Message msg = await RongcloudImPlugin.sendMessage(RCConversationType.Private, privateUserId, txtMessage);
      print("send message start senderUserId = "+msg.senderUserId);
  }
```
发送图片消息

```
onSendImageMessage() async {
    ImageMessage imgMessage = new ImageMessage();
    imgMessage.localPath = "image/local/path.jpg";
    Message msg = await RongcloudImPlugin.sendMessage(RCConversationType.Private, privateUserId, imgMessage);
    print("send image message start senderUserId = "+msg.senderUserId);
  }

```

## 获取历史消息

```
onGetHistoryMessages() async {
    List msgs = await RongcloudImPlugin.getHistoryMessage(RCConversationType.Private, privateUserId, 0, 10);
    print("get history message");
    for(Message m in msgs) {
      print("sentTime = "+m.sentTime.toString());
    }
  }
```

## 获取会话列表

```
onGetConversationList() async {
    List cons = await RongcloudImPlugin.getConversationList();
    for(Conversation con in cons) {
      print("conversation latestMessageId " + con.latestMessageId.toString());
    }
  }
```

## 加入聊天室

```
onJoinChatRoom() {
    RongcloudImPlugin.joinChatRoom("testchatroomId", 10);
  }
```

## 退出聊天室

```
onQuitChatRoom() {
    RongcloudImPlugin.quitChatRoom("testchatroomId");
  }
```

## 获取聊天室信息

```
onGetChatRoomInfo() async {
    ChatRoomInfo chatRoomInfo = await RongcloudImPlugin.getChatRoomInfo("testchatroomId", 10, RCChatRoomMemberOrder.Desc);
    print("onGetChatRoomInfo targetId ="+chatRoomInfo.targetId);
  }
```


## 设置 native 调用的 handler，并响应

设置 handler

```
RongcloudImPlugin.setRCNativeMethodCallHandler(_handler);
```

响应 handler

```
Future<dynamic> _handler(MethodCall methodCall) {
    //当 im SDK 需要展示用户信息的时候，会回调此方法
    if (RCMethodCallBackKey.RefrechUserInfo == methodCall.method) {
      //开发者需要将用户信息传递给 SDK
      //如果本地有该用户的信息，那么直接传递给 SDK
      //如果本地没有该用户的信息，从 APP 服务获取后传递给 SDK
      String userId = methodCall.arguments;
      String name = "张三";
      String portraitUrl = "https://www.rongcloud.cn/pc/images/lizhi-icon.png";
      RongcloudImPlugin.refreshUserInfo(userId, name, portraitUrl);
    } else if(RCMethodCallBackKey.ReceiveMessage == methodCall.method) {
      //收到消息原生会触发此方法
      Map map = methodCall.arguments;
      print("messageMap="+map.toString());
      int left = map["left"];
      print("left="+left.toString());
      String messageString= map["message"];
      Message msg = MessageFactory.instance.string2Message(messageString);

      //会话类型，单聊/群聊/聊天室
      print("conversationType = "+msg.conversationType.toString());
      print("targetId = "+msg.targetId);
      print("senderUserId="+msg.senderUserId);
    }else if(RCMethodCallBackKey.SendMessage == methodCall.method) {
      //发送消息会触发此回调，通知 flutter 层消息发送结果
      // {"messageId":12,"status":30}
      // messageId 为本地数据库自增字段
      // status 结果参见 RCMessageSentStatus 的枚举值
      Map map = methodCall.arguments;
      print("message sent result "+ map.toString());
    }else if(RCMethodCallBackKey.JoinChatRoom == methodCall.method) {
      //加入聊天室的回调
      //targetId 聊天室 id
      //status 参见 RCOperationStatus
      //{"targetId":targetId,"status":0};
      Map map = methodCall.arguments;
      print("join chatroom resulut ="+map.toString());
    }else if(RCMethodCallBackKey.QuitChatRoom == methodCall.method) {
      //退出聊天室的回调
      //targetId 聊天室 id
      //status 参见 RCOperationStatus
      //{"targetId":targetId,"status":0};
      Map map = methodCall.arguments;
      print("quit chatroom resulut ="+map.toString());
    }else if(RCMethodCallBackKey.UploadMediaProgress == methodCall.method) {
      //上传图片进度的回调
      //{"messageId",messageId,"progress",99}
      Map map = methodCall.arguments;
      print("upload image message progress = "+map.toString());
    }
  }
```