# 融云 IM Flutter plugin

本文档讲解了如何使用 IM 的 Flutter Plugin，基于融云 iOS/Android 平台的 IMLib SDK

[Flutter 官网](https://flutter.dev/)

[融云 iOS 文档集成](https://docs.rongcloud.cn/v4/views/im/noui/guide/private/connection/connect/ios.html)

[融云 Android 文档集成](https://docs.rongcloud.cn/v4/views/im/noui/guide/private/connection/connect/android.html)

源码地址 [Github](https://github.com/rongcloud/rongcloud-im-flutter-sdk)，任何问题可以通过 Github Issues 提问

# 前期准备

[融云官网](https://developer.rongcloud.cn/signup/?utm_source=IMfluttergithub&utm_term=Imsign) 申请开发者账号

通过管理后台的 "基本信息"->"App Key" 获取 AppKey

通过管理后台的 "IM 服务"—>"API 调用"->"用户服务"->"获取 Token"，通过用户 id 获取 IMToken


# 依赖 IM Flutter plugin

在项目的 `pubspec.yaml` 中写如下依赖

```dart
dependencies:
  flutter:
    sdk: flutter

rongcloud_im_plugin: ^4.0.3
```

然后在项目路径执行 `flutter packages get` 来下载 Flutter Plugin

> **从 2.0.0 开始废弃核心类 RongcloudImPlugin，新的核心类名为 RongIMClient**


> **从 1.1.0 开始为方便排查 Android 问题将 IM Flutter SDK Android 的包名改为 io.rong.flutter.imlib**

# 集成步骤


## 1.初始化 SDK

```dart
RongIMClient.init(RongAppKey);
```

## 2.连接 IM

```dart
RongIMClient.connect(RongIMToken, (int code, String userId) {
  print('connect result ' + code.toString());
  EventBus.instance.commit(EventKeys.UpdateNotificationQuietStatus, {});
if (code == 31004 || code == 12) {
  Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (context) => new LoginPage()), (route) => route == null);
} else if (code == 0) {
  print("connect userId" + userId);
  // 连接成功后打开数据库
  // _initUserInfoCache();
}
```

# API 调用

## 断开 IM 连接

```dart
//needPush 断开连接之后是否需要远程推送
RongIMClient.disconnect(bool needPush)
```

## 发送消息

发送文本消息

```dart
onSendMessage() async{
      TextMessage txtMessage = new TextMessage();
      txtMessage.content = "这条消息来自 Flutter";
      Message msg = await RongIMClient.sendMessage(RCConversationType.Private, privateUserId, txtMessage);
      print("send message start senderUserId = "+msg.senderUserId);
  }
```
发送图片消息

```dart
onSendImageMessage() async {
    ImageMessage imgMessage = new ImageMessage();
    imgMessage.localPath = "image/local/path.jpg";
    Message msg = await RongIMClient.sendMessage(RCConversationType.Private, privateUserId, imgMessage);
    print("send image message start senderUserId = "+msg.senderUserId);
  }

```

发送 Gif 消息

```dart
onSendGifMessage() async {
    GIFMessage gifMessage = GifMessage.obtain("gif/local/path.jpg");
    Message msg = await RongIMClient.sendMessage(RCConversationType.Private, privateUserId, gifMessage);
    print("send gif message start senderUserId = "+msg.senderUserId);
  }

```

发送小视频消息

详细参见[小视频消息文档](https://github.com/rongcloud/rongcloud-im-flutter-sdk/blob/master/doc/%E5%B0%8F%E8%A7%86%E9%A2%91.md)

发送文件消息

```dart
onSendFileMessage() async {
    // localPath 为文件本地路径,注意 Android 必须以 file:// 开头
    FileMessage fileMessage = FileMessage.obtain(localPaht);
    // 文件后缀如 "png" "txt"
    fileMessage.mType = "XXX";
    Message msg = await RongIMClient.sendMessage(
              conversationType, targetId, fileMessage);
  }

```

发送结果回调

```dart
//消息发送结果回调
    RongIMClient.onMessageSend = (int messageId,int status,int code) {
      print("send message messsageId:"+messageId.toString()+" status:"+status.toString()+" code:"+code.toString());
    };
```

媒体消息媒体文件上传进度

```dart
//媒体消息（图片/语音消息）上传媒体进度的回调
    RongIMClient.onUploadMediaProgress = (int messageId,int progress) {
      print("upload media messsageId:"+messageId.toString()+" progress:"+progress.toString());
    };
```

## 接收消息

> **注：以下两个接收消息的回调只能实现一个，否则会出现重复收到消息的情况**

如果离线消息量不大，可以使用下面这个回调；

```dart
//消息接收回调
    RongIMClient.onMessageReceived = (Message msg,int left) {
      print("receive message messsageId:"+msg.messageId.toString()+" left:"+left.toString());
    };
```

下面这个回调是 SDK 分批拉取离线消息，当离线消息量巨大的时候，建议当 left == 0 且 hasPackage == false 时刷新会话列表：

```dart
//消息接收回调
    RongIMClient.onMessageReceivedWrapper = (Message msg, int left, bool hasPackage, bool offline) {
      print("receive message messsageId:"+msg.messageId.toString()+" left:"+left.toString());
    };
```

## 历史消息

获取本地历史消息

```dart
onGetHistoryMessages() async {
    List msgs = await RongIMClient.getHistoryMessage(RCConversationType.Private, privateUserId, 0, 10);
    print("get history message");
    for(Message m in msgs) {
      print("sentTime = "+m.sentTime.toString());
    }
  }
```

获取远端历史消息

```dart
RongIMClient.getRemoteHistoryMessages(1, "1001", 0, 20,(List<Message> msgList,int code) {
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

```dart
RongIMClient.insertOutgoingMessage(RCConversationType.Private, "1001", 10, msgT, 0, (msg,code){
      print("insertOutgoingMessage " + msg.content.encode() + " code " + code.toString());

    });
```

插入收到的消息

```dart
RongIMClient.insertIncomingMessage(RCConversationType.Private, "1002", "1002", 1, msgT , 0, (msg,code){
      print("insertIncomingMessage " + msg.content.encode() + " code " + code.toString());
    });
```

删除特定会话消息

```dart
RongIMClient.deleteMessages(RCConversationType.Private, "2002", (int code) {

});
```

批量删除消息

```dart
List<int> mids =  new List();
mids.add(1);
RongIMClient.deleteMessageByIds(mids, (int code) {

});
```

## 未读数

获取特定会话的未读数

```dart
RongIMClient.getUnreadCount(RCConversationType.Private, "targetId", (int count,int code) {
      if( 0 == code) {
        print("未读数为"+count.toString());
      }
    });
```

获取特定会话类型的未读数

```dart
RongIMClient.getUnreadCountConversationTypeList([RCConversationType.Private,RCConversationType.Group], true, (int count, int code) {
      if( 0 == code) {
        print("未读数为"+count.toString());
      }
    });
```

获取所有未读数

```dart
RongIMClient.getTotalUnreadCount((int count, int code) {
      if( 0 == code) {
        print("未读数为"+count.toString());
      }
    });
```

## 会话列表

获取会话列表

```dart
onGetConversationList() async {
    List conversationList = await RongIMClient.getConversationList([RCConversationType.Private,RCConversationType.Group,RCConversationType.System]);

    for(Conversation con in cons) {
      print("conversation latestMessageId " + con.latestMessageId.toString());
    }
  }
```

删除指定会话

```dart
RongIMClient.removeConversation(RCConversationType.Private, "1001", (success) {
      if(success) {
        print("删除会话成功");
      }
    });
```

## 黑名单

把用户加入黑名单

```dart
RongIMClient.addToBlackList(blackUserId, (int code) {
      print("_addBlackList:" + blackUserId + " code:" + code.toString());
    });
```

把用户移除黑名单

```dart
RongIMClient.removeFromBlackList(blackUserId, (int code) {
      print("_removeBalckList:" + blackUserId + " code:" + code.toString());
    });
```

查询特定用户的黑名单状态

```dart
RongIMClient.getBlackListStatus(blackUserId,
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

```dart
RongIMClient.getBlackList((List/*<String>*/ userIdList, int code) {
      print("_getBlackList:" + userIdList.toString() + " code:" + code.toString());
      userIdList.forEach((userId) {
        print("userId:"+userId);
      });
    });
```

## 加入聊天室

```dart
onJoinChatRoom() {
    RongIMClient.joinChatRoom("testchatroomId", 10);
  }
```

加入聊天室回调

```dart
//加入聊天室结果回调
    RongIMClient.onJoinChatRoom = (String targetId,int status) {
      print("join chatroom:"+targetId+" status:"+status.toString());
    };
```

## 退出聊天室

```dart
onQuitChatRoom() {
    RongIMClient.quitChatRoom("testchatroomId");
  }
```

退出聊天室回调

```dart
//退出聊天室结果回调
    RongIMClient.onQuitChatRoom = (String targetId,int status) {
      print("quit chatroom:"+targetId+" status:"+status.toString());
    };
```

## 获取聊天室信息

```dart
onGetChatRoomInfo() async {
    ChatRoomInfo chatRoomInfo = await RongIMClient.getChatRoomInfo("testchatroomId", 10, RCChatRoomMemberOrder.Desc);
    print("onGetChatRoomInfo targetId ="+chatRoomInfo.targetId);
  }
```

## Native 向 Flutter 传递数据

iOS 端传递数据:

```objective-c
[[RCIMFlutterWrapper sharedWrapper] sendDataToFlutter:@{@"key":@"ios"}];

```

Android 端传递数据:

```java
Map map = new HashMap();
map.put("key","android");
RCIMFlutterWrapper.getInstance().sendDataToFlutter(map);
```

Flutter 端接收数据:

```dart
RongIMClient.onDataReceived = (Map map) {
  print("object onDataReceived " + map.toString());
};
```

## 单聊已读回执

发送已读回执:

```dart
RongIMClient.sendReadReceiptMessage(conversationType, targetId, timestamp, (int code){
  if (code == 0) {
    print('sendReadReceiptMessageSuccess');
  } else {
    print('sendReadReceiptMessageFailed:code = + $code');
  }
});
```

接收已读回执:

```
RongIMClient.onReceiveReadReceipt = (Map map) {
  print("object onReceiveReadReceipt " + map.toString());
};
```


## 群组已读回执

[如何实现群组已读回执](https://github.com/rongcloud/rongcloud-im-flutter-sdk/blob/master/doc/%E7%BE%A4%E7%BB%84%E5%B7%B2%E8%AF%BB%E5%9B%9E%E6%89%A7.md)


## 消息撤回
### 撤回消息调用如下接口会返回 RecallNotificationMessage 类型的消息体，需要把原有消息的内容替换，刷新 ui 显示为此类型消息的展示
```dart
void _recallMessage(Message message) async {
    RecallNotificationMessage recallNotifiMessage =
        await RongIMClient.recallMessage(message, "");
    if (recallNotifiMessage != null) {
      message.content = recallNotifiMessage;
      _insertOrReplaceMessage(message);
    } else {
      showShortToast("撤回失败");
    }
  }
```
## 草稿


## 输入状态监听


## 聊天室属性自定义

详细参见[聊天室存储相关接口](https://github.com/rongcloud/rongcloud-im-flutter-sdk/blob/master/doc/%E8%81%8A%E5%A4%A9%E5%AE%A4%E5%B1%9E%E6%80%A7%E8%87%AA%E5%AE%9A%E4%B9%89.md)

## 多端阅读消息数同步

详细参见[多端阅读消息数同步](https://github.com/rongcloud/rongcloud-im-flutter-sdk/blob/master/doc/%E5%90%8C%E6%AD%A5%E4%BC%9A%E8%AF%9D%E5%B7%B2%E8%AF%BB%E7%8A%B6%E6%80%81.md)

## 消息搜索
### 1.搜索关键词相关的会话信息
```dart
static void searchConversations(
      String keyword,
      List conversationTypes,
      List objectNames,
      Function(int code, List searchConversationResult) finished)
```
### 2.在根据搜索会话返回的信息，针对某个会话搜索相应会话的消息
```dart
static void searchMessages(
      int conversationType,
      String targetId,
      String keyword,
      int count,
      int beginTime,
      Function(List/*<Message>*/ msgList, int code) finished) 
```

## 全局消息提醒

全局屏蔽某个时间段的消息提醒

```dart
void _setNotificationQuietHours() {
    RongIMClient.setNotificationQuietHours("09:00:00", 600,
        (int code) {
      String toast = "设置全局屏蔽某个时间段的消息提醒:\n" +
          (code == 0 ? "设置成功" : "设置失败, code:" + code.toString());
      print(toast);
    });
  }
```

查询已设置的全局时间段消息提醒屏蔽

```dart
  void _getNotificationQuietHours() {
    RongIMClient.getNotificationQuietHours(
        (int code, String startTime, int spansMin) {
      String toast = "查询已设置的全局时间段消息提醒屏蔽\n: startTime:" +
          startTime +
          " spansMin:" +
          spansMin.toString() +
          (code == 0 ? "" : "\n设置失败, code:" + code.toString());
      print(toast);
    });
  }
```

删除已设置的全局时间段消息提醒屏蔽

```dart
  void _removeNotificationQuietHours() {
    RongIMClient.removeNotificationQuietHours((int code) {
      String toast = "删除已设置的全局时间段消息提醒屏蔽:\n" +
          (code == 0 ? "删除成功" : "删除失败, code:" + code.toString());
      print(toast);
    });
  }
```


## 获取会话中@提醒自己的消息

```dart
getUnreadMentionedMessages(int conversationType, String targetId) {
  Future<List> messages = RongIMClient.getUnreadMentionedMessages(conversationType, targetId);
  print("get unread mentioned messages = " + messages.toString());
}
```


## 发送群定向消息

1. 此方法用于在群组中发送消息给其中的部分用户，其它用户不会收到这条消息。
2. 此方法目前仅支持群组。
3. 群定向消息不存储到云端，通过“单群聊消息云存储”服务无法获取到定向消息。

```dart
onSendDirectionalMessage() async {
    TextMessage txtMessage = new TextMessage();
    txtMessage.content = "这条消息来自 Flutter 的群定向消息";
    Message message = await RongIMClient.sendDirectionalMessage(
        RCConversationType.Group, targetId, ['UserId1', 'UserId2'], txtMessage);
    print("send directional message start senderUserId = " + msg.senderUserId);
  }
```

## 设置断线重连时是否踢出当前正在重连的设备

设置 enable 为 YES 时，SDK 重连的时候发现此时已有别的设备连接成功，不再强行踢出已有设备，而是踢出重连设备。

```dart
RongIMClient.setReconnectKickEnable(true);
```

## 获取当前 SDK 的连接状态

```dart
void getConnectionStatus() async {
  int status = await RongIMClient.getConnectionStatus();
  print('getConnectionStatus: $status');
}
```


## 取消下载中的媒体文件

```dart
RongIMClient.cancelDownloadMediaMessage(100);
```

## 从服务器端获取聊天室的历史消息

```dart
void _getChatRoomHistoryMessage() {
  RongIMClient.getRemoteChatroomHistoryMessages(
      targetId, 0, 20, RCTimestampOrder.RC_Timestamp_Desc,
      (List/*<Message>*/ msgList, int syncTime, int code) {
    DialogUtil.showAlertDiaLog(
        context,
        "获取聊天室历史消息：code：" +
            CodeUtil.codeString(code) +
            "，msgListCount：${msgList.length} 条消息\n" +
            "，msgList：$msgList" +
            "，syncTime：$syncTime");
  });
}
```

## 通过 messageUId(发送 message 成功后，服务器会给每个 message 分配一个唯一 messageUId)获取消息实体

```dart
Message msg = await RongIMClient.getMessageByUId(message.messageUId);
```

## 删除指定的一条或者一组消息。会同时删除本地和远端消息(会话类型不支持聊天室)

```dart
RongIMClient.deleteRemoteMessages(conversationType, targetId, messageList, (code){
    print("result: $code");
    });
```

## 清空指定会话类型，targetId 的某一会话所有聊天消息记录

```dart
RongIMClient.clearMessages(con.conversationType, con.targetId, (code) {
    print("result:$code");
    });
```

## 设置本地消息的附加信息（message.extra）

```dart
RongIMClient.setMessageExtra(int messageId, value, (code) {
    print("result:$code");
    });
```

## 根据 messageId 设置接收到的消息状态。用于UI标记消息为已读，已下载等状态

```dart
RongIMClient.setMessageReceivedStatus(message.messageId, 1, (code) async{
    print("setMessageReceivedStatus result:$code");
    });
```

## 根据 messageId 设置消息的发送状态。用于UI标记消息为正在发送，对方已接收等状态。

```dart
RongIMClient.setMessageSentStatus(message.messageId, 1, (code) async{
    print("setMessageReceivedStatus result:$code");
    });
```

## 清空会话类型列表中的所有会话及会话信息

```dart
RongIMClient.clearConversations(conversations, (code) async{
    print("clearConversations result:$code");
    });
```

## 获取本地时间与服务器时间的差值。 消息发送成功后，sdk 会与服务器同步时间，消息所在数据库中存储的时间就是服务器时间。

```dart
int deltaTime = await RongIMClient.getDeltaTime()
```

## 设置当前用户离线消息补偿时间

```dart
RongIMClient.setOfflineMessageDuration(3, (code, result){
    print("setOfflineMessageDuration code:$code result:$result");
    });
```

## 获取当前用户离线消息的存储时间，取值范围为int值1~7天

```dart
int duration = await RongIMClient.getOfflineMessageDuration();
```

更多接口请[参考](https://github.com/rongcloud/rongcloud-im-flutter-sdk)

[常见问题](https://github.com/rongcloud/rongcloud-im-flutter-sdk/tree/master/doc)
