# 融云 IM Flutter plugin

本文档讲解了如何使用 IM 的 Flutter Plugin，基于融云 iOS/Android 平台的 IMLib SDK

[Flutter 官网](https://flutter.dev/)

[融云 iOS 文档集成](https://www.rongcloud.cn/docs/ios.html)

[融云 Android 文档集成](https://www.rongcloud.cn/docs/android.html)

源码地址 [Github](https://github.com/rongcloud/rongcloud-im-flutter-sdk)，任何问题可以通过 Github Issues 提问

# 前期准备

[融云官网](https://developer.rongcloud.cn/signup/?utm_source=IMfluttergithub&utm_term=Imsign) 申请开发者账号

通过管理后台的 "基本信息"->"App Key" 获取 AppKey

通过管理后台的 "IM 服务"—>"API 调用"->"用户服务"->"获取 Token"，通过用户 id 获取 IMToken


# 依赖 IM Flutter plugin

在项目的 `pubspec.yaml` 中写如下依赖

```
dependencies:
  flutter:
    sdk: flutter

  rongcloud_im_plugin: ^1.1.0
```

然后在项目路径执行 `flutter packages get` 来下载 Flutter Plugin

> **从 1.1.0 开始为方便排查 Android 问题将 IM Flutter SDK Android 的包名改为 io.rong.flutter.imlib**

# 集成步骤


## 1.初始化 SDK

```
RongcloudImPlugin.init(RongAppKey);
```

## 2.连接 IM

```
int rc = await RongcloudImPlugin.connect(RongIMToken);
print('connect result');
print(rc);
```

# API 调用

## 断开 IM 连接

```
//needPush 断开连接之后是否需要远程推送
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

发送小视频消息

详细参见[小视频消息文档](doc/小视频.md)

发送结果回调

```
//消息发送结果回调
    RongcloudImPlugin.onMessageSend = (int messageId,int status,int code) {
      print("send message messsageId:"+messageId.toString()+" status:"+status.toString()+" code:"+code.toString());
    };
```

媒体消息媒体文件上传进度

```
//媒体消息（图片/语音消息）上传媒体进度的回调
    RongcloudImPlugin.onUploadMediaProgress = (int messageId,int progress) {
      print("upload media messsageId:"+messageId.toString()+" progress:"+progress.toString());
    };
```

## 接收消息

```
//消息接收回调
    RongcloudImPlugin.onMessageReceived = (Message msg,int left) {
      print("receive message messsageId:"+msg.messageId.toString()+" left:"+left.toString());
    };
```

## 历史消息

获取本地历史消息

```
onGetHistoryMessages() async {
    List msgs = await RongcloudImPlugin.getHistoryMessage(RCConversationType.Private, privateUserId, 0, 10);
    print("get history message");
    for(Message m in msgs) {
      print("sentTime = "+m.sentTime.toString());
    }
  }
```

获取远端历史消息

```
RongcloudImPlugin.getRemoteHistoryMessages(1, "1001", 0, 20,(List<Message> msgList,int code) {
      if(code == 0) {
        for(Message msg in msgList) {
          print("getRemoteHistoryMessages  success "+ msg.messageId.toString());
        }
      }else {
        print("getRemoteHistoryMessages error "+code.toString());
      }
    });
```

插入发出的消息

```
RongcloudImPlugin.insertOutgoingMessage(RCConversationType.Private, "1001", 10, msgT, 0, (msg,code){
      print("insertOutgoingMessage " + msg.content.encode() + " code " + code.toString());

    });
```

插入收到的消息

```
RongcloudImPlugin.insertIncomingMessage(RCConversationType.Private, "1002", "1002", 1, msgT , 0, (msg,code){
      print("insertIncomingMessage " + msg.content.encode() + " code " + code.toString());
    });
```

删除特定会话消息

```
RongcloudImPlugin.deleteMessages(RCConversationType.Private, "2002", (int code) {

});
```

批量删除消息

```
List<int> mids =  new List();
mids.add(1);
RongcloudImPlugin.deleteMessageByIds(mids, (int code) {

});
```

## 未读数

获取特定会话的未读数

```
RongcloudImPlugin.getUnreadCount(RCConversationType.Private, "targetId", (int count,int code) {
      if( 0 == code) {
        print("未读数为"+count.toString());
      }
    });
```

获取特定会话类型的未读数

```
RongcloudImPlugin.getUnreadCountConversationTypeList([RCConversationType.Private,RCConversationType.Group], true, (int count, int code) {
      if( 0 == code) {
        print("未读数为"+count.toString());
      }
    });
```

获取所有未读数

```
RongcloudImPlugin.getTotalUnreadCount((int count, int code) {
      if( 0 == code) {
        print("未读数为"+count.toString());
      }
    });
```

## 会话列表

获取会话列表

```
onGetConversationList() async {
    List conversationList = await RongcloudImPlugin.getConversationList([RCConversationType.Private,RCConversationType.Group,RCConversationType.System]);

    for(Conversation con in cons) {
      print("conversation latestMessageId " + con.latestMessageId.toString());
    }
  }
```

删除指定会话

```
RongcloudImPlugin.removeConversation(RCConversationType.Private, "1001", (success) {
      if(success) {
        print("删除会话成功");
      }
    });
```

## 黑名单

把用户加入黑名单

```
RongcloudImPlugin.addToBlackList(blackUserId, (int code) {
      print("_addBlackList:" + blackUserId + " code:" + code.toString());
    });
```

把用户移除黑名单

```
RongcloudImPlugin.removeFromBlackList(blackUserId, (int code) {
      print("_removeBalckList:" + blackUserId + " code:" + code.toString());
    });
```

查询特定用户的黑名单状态

```
RongcloudImPlugin.getBlackListStatus(blackUserId,
        (int blackStatus, int code) {
      if (0 == code) {
        if (RCBlackListStatus.In == blackStatus) {
          print("用户:" + blackUserId + " 在黑名单中");
        } else {
          print("用户:" + blackUserId + " 不在黑名单中");
        }
      } else {
        print("用户:" + blackUserId + " 黑名单状态查询失败" + code.toString());
      }
    });
```

查询已经设置的黑名单列表

```
RongcloudImPlugin.getBlackList((List/*<String>*/ userIdList, int code) {
      print("_getBlackList:" + userIdList.toString() + " code:" + code.toString());
      userIdList.forEach((userId) {
        print("userId:"+userId);
      });
    });
```

## 加入聊天室

```
onJoinChatRoom() {
    RongcloudImPlugin.joinChatRoom("testchatroomId", 10);
  }
```

加入聊天室回调

```
//加入聊天室结果回调
    RongcloudImPlugin.onJoinChatRoom = (String targetId,int status) {
      print("join chatroom:"+targetId+" status:"+status.toString());
    };
```

## 退出聊天室

```
onQuitChatRoom() {
    RongcloudImPlugin.quitChatRoom("testchatroomId");
  }
```

退出聊天室回调

```
//退出聊天室结果回调
    RongcloudImPlugin.onQuitChatRoom = (String targetId,int status) {
      print("quit chatroom:"+targetId+" status:"+status.toString());
    };
```

## 获取聊天室信息

```
onGetChatRoomInfo() async {
    ChatRoomInfo chatRoomInfo = await RongcloudImPlugin.getChatRoomInfo("testchatroomId", 10, RCChatRoomMemberOrder.Desc);
    print("onGetChatRoomInfo targetId ="+chatRoomInfo.targetId);
  }
```

## Native 向 Flutter 传递数据

iOS 端传递数据:

``` 
[[RCIMFlutterWrapper sharedWrapper] sendDataToFlutter:@{@"key":@"ios"}];

```

Android 端传递数据:

```
Map map = new HashMap();
map.put("key","android");
RCIMFlutterWrapper.getInstance().sendDataToFlutter(map);
```

Flutter 端接收数据:

```
RongcloudImPlugin.onDataReceived = (Map map) {
  print("object onDataReceived " + map.toString());
};
```

## 单聊已读回执

发送已读回执:

```
RongcloudImPlugin.sendReadReceiptMessage(conversationType, targetId, timestamp, (int code){
  if (code == 0) {
    print('sendReadReceiptMessageSuccess');
  } else {
    print('sendReadReceiptMessageFailed:code = + $code');
  }
});
```

接收已读回执:

```
RongcloudImPlugin.onReceiveReadReceipt = (Map map) {
  print("object onReceiveReadReceipt " + map.toString());
};
```

更多接口请[参考](https://github.com/rongcloud/rongcloud-im-flutter-sdk)

[常见问题](./doc)
