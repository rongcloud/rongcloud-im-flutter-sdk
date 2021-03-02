import 'package:flutter/services.dart';
import 'package:rongcloud_im_plugin/src/message/group_notification_message.dart';
import 'package:rongcloud_im_plugin/src/util/type_util.dart';
import '../rongcloud_im_plugin.dart';
import 'common_define.dart';
import 'util/message_factory.dart';
import 'method_key.dart';
import 'info/connection_status_convert.dart';
import 'dart:developer' as developer;

///消息解析函数
///[content] 待解析消息json字符串
///@return 实现MessageContent的自定义消息类
typedef MessageContent MessageDecoder(String content);

class RongIMClient {
  static final MethodChannel _channel =
      const MethodChannel('rongcloud_im_plugin');

  static Map sendMessageCallbacks = Map();

  static Map<String, MessageDecoder> messageDecoders =
      Map<String, MessageDecoder>();

  ///初始化 SDK
  ///
  ///[appkey] appkey
  static void init(String appkey) {
    _registerMessage();
    _channel.invokeMethod(RCMethodKey.Init, appkey);
    _addNativeMethodCallHandler();
  }

  ///注册Flutter端自定义消息
  ///[objectName] 希望注册的新消息类型,例如:RC:TxtMsg。
  ///[messageDecoder] 消息加息函数
  ///在 init 之后，connect 之前进行注册
  static void addMessageDecoder(
      String objectName, MessageDecoder messageDecoder) {
    messageDecoders[objectName] = messageDecoder;
  }

  /// 注册默认支持的消息
  static void _registerMessage() {
    addMessageDecoder(TextMessage.objectName, (content) {
      TextMessage msg = new TextMessage();
      msg.decode(content);
      return msg;
    });
    addMessageDecoder(ImageMessage.objectName, (content) {
      ImageMessage msg = new ImageMessage();
      msg.decode(content);
      return msg;
    });
    addMessageDecoder(VoiceMessage.objectName, (content) {
      VoiceMessage msg = new VoiceMessage();
      msg.decode(content);
      return msg;
    });
    addMessageDecoder(SightMessage.objectName, (content) {
      SightMessage msg = new SightMessage();
      msg.decode(content);
      return msg;
    });
    addMessageDecoder(RecallNotificationMessage.objectName, (content) {
      RecallNotificationMessage msg = new RecallNotificationMessage();
      msg.decode(content);
      return msg;
    });
    addMessageDecoder(ChatroomKVNotificationMessage.objectName, (content) {
      ChatroomKVNotificationMessage msg = new ChatroomKVNotificationMessage();
      msg.decode(content);
      return msg;
    });
    addMessageDecoder(FileMessage.objectName, (content) {
      FileMessage msg = new FileMessage();
      msg.decode(content);
      return msg;
    });
    addMessageDecoder(RichContentMessage.objectName, (content) {
      RichContentMessage msg = new RichContentMessage();
      msg.decode(content);
      return msg;
    });
    addMessageDecoder(GifMessage.objectName, (content) {
      GifMessage msg = new GifMessage();
      msg.decode(content);
      return msg;
    });
    addMessageDecoder(CombineMessage.objectName, (content) {
      CombineMessage msg = new CombineMessage();
      msg.decode(content);
      return msg;
    });
    addMessageDecoder(ReferenceMessage.objectName, (content) {
      ReferenceMessage msg = new ReferenceMessage();
      msg.decode(content);
      return msg;
    });
    addMessageDecoder(LocationMessage.objectName, (content) {
      LocationMessage msg = new LocationMessage();
      msg.decode(content);
      return msg;
    });
    addMessageDecoder(GroupNotificationMessage.objectName, (content) {
      GroupNotificationMessage msg = new GroupNotificationMessage();
      msg.decode(content);
      return msg;
    });
  }

  ///配置 SDK
  ///
  ///[conf] 具体配置
  static void config(Map conf) {
    _channel.invokeMethod(RCMethodKey.Config, conf);
  }

  ///连接 SDK
  ///
  ///[token] 融云 im token
  ///
  ///[finished] 返回 [RCErrorCode] 以及 userId
  static void connect(
      String token, Function(int code, String userId) finished) async {
    Map resultMap = await _channel.invokeMethod(RCMethodKey.Connect, token);
    int code = resultMap["code"];
    String userId = resultMap["userId"];
    if (finished != null) {
      finished(code, userId);
    }
  }

  ///断开连接
  ///
  ///[needPush] 断开连接之后是否需要远程推送
  static void disconnect(bool needPush) {
    _channel.invokeMethod(RCMethodKey.Disconnect, needPush);
  }

  ///设置服务器地址，仅限独立数据中心使用，使用前必须先联系商务开通，必须在 [init] 前调用
  ///
  ///[naviServer] 导航服务器地址，具体的格式参考下面的说明
  ///
  ///[fileServer] 文件服务器地址，具体的格式参考下面的说明
  ///
  /// naviServer 和 fileServer 的格式说明：
  ///1、如果使用https，则设置为https://cn.xxx.com:port或https://cn.xxx.com格式，其中域名部分也可以是IP，如果不指定端口，将默认使用443端口。
  ///2、如果使用http，则设置为cn.xxx.com:port或cn.xxx.com格式，其中域名部分也可以是IP，如果不指定端口，将默认使用80端口。
  ///
  static void setServerInfo(String naviServer, String fileServer) {
    Map map = {"naviServer": naviServer, "fileServer": fileServer};
    _channel.invokeMethod(RCMethodKey.SetServerInfo, map);
  }

  ///更新当前用户信息
  ///
  ///[userId] 用户 id
  ///
  ///[name] 用户名称
  ///
  ///[portraitUrl] 用户头像
  /// 此方法只针对iOS生效
  static void updateCurrentUserInfo(
      String userId, String name, String portraitUrl) {
    Map map = {"userId": userId, "name": name, "portraitUrl": portraitUrl};
    _channel.invokeMethod(RCMethodKey.SetCurrentUserInfo, map);
  }

  ///发送消息
  ///
  ///[conversationType] 会话类型，参见枚举 [RCConversationType]
  ///
  ///[targetId] 会话 id
  ///
  ///[content] 消息内容 参见 [MessageContent]
  static Future<Message> sendMessage(
      int conversationType, String targetId, MessageContent content,
      {bool disableNotification = false}) async {
    return sendMessageCarriesPush(conversationType, targetId, content, "", "",
        disableNotification: disableNotification);
  }

  ///发送消息
  ///
  ///[conversationType] 会话类型，参见枚举 [RCConversationType]
  ///
  ///[targetId] 会话 id
  ///
  ///[content] 消息内容 参见 [MessageContent]
  ///
  /// 当接收方离线并允许远程推送时，会收到远程推送。
  /// 远程推送中包含两部分内容，一是[pushContent]，用于显示；二是[pushData]，用于携带不显示的数据。
  ///
  /// SDK内置的消息类型，如果您将[pushContent]和[pushData]置为空或者为null，会使用默认的推送格式进行远程推送。
  /// 自定义类型的消息，需要您自己设置pushContent和pushData来定义推送内容，否则将不会进行远程推送。
  static Future<Message> sendMessageCarriesPush(
      int conversationType,
      String targetId,
      MessageContent content,
      String pushContent,
      String pushData,
      {bool disableNotification = false}) async {
    return sendMessageWithCallBack(
        conversationType, targetId, content, pushContent, pushData, null,
        disableNotification: disableNotification);
  }

  ///发送消息
  ///
  ///[conversationType] 会话类型，参见枚举 [RCConversationType]
  ///
  ///[targetId] 会话 id
  ///
  ///[content] 消息内容 参见 [MessageContent]
  ///
  ///[finished] 回调结果，告知 messageId(消息 id)、status(消息发送状态，参见枚举 [RCSentStatus]) 和 code(具体的错误码，0 代表成功)
  ///
  /// 当接收方离线并允许远程推送时，会收到远程推送。
  /// 远程推送中包含两部分内容，一是[pushContent]，用于显示；二是[pushData]，用于携带不显示的数据。
  ///
  /// SDK内置的消息类型，如果您将[pushContent]和[pushData]置为空或者为null，会使用默认的推送格式进行远程推送。
  /// 自定义类型的消息，需要您自己设置pushContent和pushData来定义推送内容，否则将不会进行远程推送。
  ///
  ///
  /// 发送消息之后有两种查看结果的方式：1、发送消息的 callback（消息插入数据库时会走一次 onMessageSend） 2、onMessageSend；推荐使用 callback 的方式
  /// 如果未实现此方法的 callback，则会通过 onMessageSend 返回发送消息的结果
  static Future<Message> sendMessageWithCallBack(
      int conversationType,
      String targetId,
      MessageContent content,
      String pushContent,
      String pushData,
      Function(int messageId, int status, int code) finished,
      {bool disableNotification = false}) async {
    if (conversationType == null || targetId == null || content == null) {
      developer.log(
          "send message fail: conversationType or targetId or content is null",
          name: "RongIMClient");
      return null;
    }
    if (pushContent == null) {
      pushContent = "";
    }
    if (pushData == null) {
      pushData = "";
    }
    String jsonStr = content.encode();
    String objName = content.getObjectName();

    // 此处获取当前时间戳传给原生方法，并且当做 sendMessageCallbacks 的 key 记录 finished
    DateTime time = DateTime.now();
    int timestamp = time.millisecondsSinceEpoch;

    Map map = {
      'conversationType': conversationType,
      'targetId': targetId,
      "content": jsonStr,
      "objectName": objName,
      "pushContent": pushContent,
      "pushData": pushData,
      "timestamp": timestamp,
      "disableNotification": disableNotification
    };

    if (finished != null) {
      sendMessageCallbacks[timestamp] = finished;
    }

    Map resultMap = await _channel.invokeMethod(RCMethodKey.SendMessage, map);
    if (resultMap == null) {
      return null;
    }
    String messageString = resultMap["message"];
    Message msg = MessageFactory.instance.string2Message(messageString);
    return msg;
  }

  ///发送消息
  ///
  ///[message] 将要发送的消息实体（需要保证 message 中的 conversationType，targetId，messageContent 是有效值)
  ///
  ///[finished] 回调结果，告知 messageId(消息 id)、status(消息发送状态，参见枚举 [RCSentStatus]) 和 code(具体的错误码，0 代表成功)
  ///
  /// 当接收方离线并允许远程推送时，会收到远程推送。
  /// 远程推送中包含两部分内容，一是[pushContent]，用于显示；二是[pushData]，用于携带不显示的数据。
  ///
  /// SDK内置的消息类型，如果您将[pushContent]和[pushData]置为空或者为null，会使用默认的推送格式进行远程推送。
  /// 自定义类型的消息，需要您自己设置pushContent和pushData来定义推送内容，否则将不会进行远程推送。
  ///
  ///
  /// 发送消息之后有两种查看结果的方式：1、发送消息的 callback（消息插入数据库时会走一次 onMessageSend） 2、onMessageSend；推荐使用 callback 的方式
  /// 如果未实现此方法的 callback，则会通过 onMessageSend 返回发送消息的结果
  static Future<Message> sendIntactMessageWithCallBack(
      Message message,
      String pushContent,
      String pushData,
      Function(int messageId, int status, int code) finished) async {
    if (message != null && message.conversationType == null ||
        message.targetId == null ||
        message.content == null) {
      developer.log(
          "send message fail: conversationType or targetId or content is null",
          name: "RongIMClient");
      return null;
    }
    if (pushContent == null) {
      pushContent = "";
    }
    if (pushData == null) {
      pushData = "";
    }

    // 此处获取当前时间戳传给原生方法，并且当做 sendMessageCallbacks 的 key 记录 finished
    DateTime time = DateTime.now();
    int timestamp = time.millisecondsSinceEpoch;

    Map map = MessageFactory.instance.message2Map(message);
    map['pushContent'] = pushContent;
    map['pushData'] = pushData;
    map['timestamp'] = timestamp;

    if (finished != null) {
      sendMessageCallbacks[timestamp] = finished;
    }

    Map resultMap =
        await _channel.invokeMethod(RCMethodKey.SendIntactMessage, map);
    if (resultMap == null) {
      return null;
    }
    String messageString = resultMap["message"];
    Message msg = MessageFactory.instance.string2Message(messageString);
    return msg;
  }

  ///发送定向消息
  ///
  ///[conversationType] 会话类型，参见枚举 [RCConversationType]
  ///
  ///[targetId] 会话 id
  ///
  ///[userIdList] 接收消息的用户 ID 列表
  ///
  ///[content] 消息内容 参见 [MessageContent]
  ///
  ///[pushContent] 接收方离线时需要显示的远程推送内容
  ///
  ///[pushData] 接收方离线时需要在远程推送中携带的非显示数据
  ///
  /// 此方法用于在群组中发送消息给其中的部分用户，其它用户不会收到这条消息。
  /// 目前仅支持群组。
  static Future<Message> sendDirectionalMessage(int conversationType,
      String targetId, List userIdList, MessageContent content,
      {String pushContent,
      String pushData,
      Function(int messageId, int status, int code) finished}) async {
    if (conversationType == null || targetId == null || content == null) {
      developer.log(
          "send directional message fail: conversationType or targetId or content is null",
          name: "RongIMClient");
      return null;
    }
    if (userIdList.length <= 0) {
      developer.log("userIdList 为空", name: "RongIMClient");
      return null;
    }
    if (pushContent == null) {
      pushContent = "";
    }
    if (pushData == null) {
      pushData = "";
    }
    String jsonStr = content.encode();
    String objName = content.getObjectName();

    // 此处获取当前时间戳传给原生方法，并且当做 sendMessageCallbacks 的 key 记录 finished
    DateTime time = DateTime.now();
    int timestamp = time.millisecondsSinceEpoch;

    Map map = {
      'conversationType': conversationType,
      'targetId': targetId,
      'userIdList': userIdList,
      "content": jsonStr,
      "objectName": objName,
      "pushContent": pushContent,
      "pushData": pushData,
      "timestamp": timestamp
    };

    if (finished != null) {
      sendMessageCallbacks[timestamp] = finished;
    }

    Map resultMap =
        await _channel.invokeMethod(RCMethodKey.SendDirectionalMessage, map);
    if (resultMap == null) {
      return null;
    }
    String messageString = resultMap["message"];
    Message msg = MessageFactory.instance.string2Message(messageString);
    return msg;
  }

  ///获取历史消息
  ///
  ///[conversationType] 会话类型，参见枚举 [RCConversationType]
  ///
  ///[targetId] 会话 id
  ///
  ///[messageId] 消息 id，每次进入聊天页面可以传 -1
  ///
  ///[count] 需要获取的消息数
  static Future<List> getHistoryMessage(
      int conversationType, String targetId, int messageId, int count) async {
    Map map = {
      'conversationType': conversationType,
      'targetId': targetId,
      "messageId": messageId,
      "count": count
    };
    List list = await _channel.invokeMethod(RCMethodKey.GetHistoryMessage, map);
    if (list == null) {
      return null;
    }
    List msgList = new List();
    for (String msgStr in list) {
      Message msg = MessageFactory.instance.string2Message(msgStr);
      msgList.add(msg);
    }
    return msgList;
  }

  ///获取特定方向的历史消息
  ///
  ///[conversationType] 会话类型，参见枚举 [RCConversationType]
  ///
  ///[targetId] 会话 id
  ///
  ///[sentTime] 消息的发送时间
  ///
  ///[beforeCount] 指定消息的前部分消息数量
  ///
  ///[afterCount] 指定消息的后部分消息数量
  ///
  ///[return] 获取到的消息列表
  static Future<List> getHistoryMessages(int conversationType, String targetId,
      int sentTime, int beforeCount, int afterCount) async {
    if (conversationType == null || targetId == null) {
      developer.log(
          "getHistoryMessages error: conversationType or targetId null",
          name: "RongIMClient");
      return null;
    }
    Map map = {
      'conversationType': conversationType,
      'targetId': targetId,
      "sentTime": TypeUtil.getProperInt(sentTime),
      "beforeCount": TypeUtil.getProperInt(beforeCount),
      "afterCount": TypeUtil.getProperInt(afterCount),
    };
    List list =
        await _channel.invokeMethod(RCMethodKey.GetHistoryMessages, map);
    if (list == null) {
      return null;
    }
    List msgList = new List();
    for (String msgStr in list) {
      Message msg = MessageFactory.instance.string2Message(msgStr);
      msgList.add(msg);
    }
    return msgList;
  }

  ///清除历史消息
  ///
  ///[conversationType] 会话类型，参见枚举 [RCConversationType]
  ///
  ///[targetId] 会话 id
  ///
  ///[recordTime] 清除消息时间戳，【0 <= recordTime <= 当前会话最后一条消息的 sentTime,0 清除所有消息，其他值清除小于等于 recordTime 的消息】
  ///
  ///[clearRemote] 是否同时删除服务端消息
  ///
  ///[finished] 回调结果
  ///
  /// 此方法可以清除服务器端历史消息和本地消息，如果清除服务器端消息必须先开通历史消息云存储功能。例如，您不想从服务器上获取更多的历史消息，通过指定 recordTime 并设置 clearRemote 为 YES 清除消息，成功后只能获取该时间戳之后的历史消息。如果 clearRemote 传 NO，只会清除本地消息。
  static clearHistoryMessages(int conversationType, String targetId,
      int recordTime, bool clearRemote, Function(int code) finished) async {
    if (conversationType == null || targetId == null) {
      developer.log(
          "clearHistoryMessages error: conversationType or targetId null",
          name: "RongIMClient");
      return null;
    }
    Map map = {
      'conversationType': conversationType,
      'targetId': targetId,
      "recordTime": TypeUtil.getProperInt(recordTime),
      "clearRemote": clearRemote,
    };

    int code =
        await _channel.invokeMethod(RCMethodKey.ClearHistoryMessages, map);
    if (finished != null) {
      finished(code);
    }
  }

  ///获取本地单条消息
  ///
  ///[messageId] 消息 id
  static Future<Message> getMessage(int messageId) async {
    Map map = {"messageId": messageId};
    String msgStr = await _channel.invokeMethod(RCMethodKey.GetMessage, map);
    if (msgStr == null) {
      return null;
    }
    Message msg = MessageFactory.instance.string2Message(msgStr);
    return msg;
  }

//  ///获取会话列表
//  static Future<List> getConversationList() async {
//    List list = await _channel.invokeMethod(RCMethodKey.GetConversationList);
//    if (list == null) {
//      return null;
//    }
//    List conList = new List();
//    for (String conStr in list) {
//      Conversation con = MessageFactory.instance.string2Conversation(conStr);
//      conList.add(con);
//    }
//    return conList;
//  }

  ///根据传入的会话类型来获取会话列表
  ///
  /// [conversationTypeList] 会话类型数组，参见枚举 [RCConversationType]
  static Future<List /*Conversation*/ > getConversationList(
      List<int /*RCConversationType*/ > conversationTypeList) async {
    Map map = {"conversationTypeList": conversationTypeList};
    List list =
        await _channel.invokeMethod(RCMethodKey.GetConversationList, map);
    if (list == null) {
      return null;
    }
    List conList = new List();
    for (String conStr in list) {
      Conversation con = MessageFactory.instance.string2Conversation(conStr);
      conList.add(con);
    }
    return conList;
  }

  ///根据传入的会话类型来分页获取会话列表
  ///
  /// [conversationTypeList] 会话类型数组，参见枚举 [RCConversationType]
  ///
  /// [count] 需要获取的会话个数，当实际取回的会话个数小于 count 值时，表明已取完数据
  ///
  /// [startTime] 会话的时间戳，获取这个时间戳之前的会话列表，第一次传 0
  static Future<List /*Conversation*/ > getConversationListByPage(
      List<int /*RCConversationType*/ > conversationTypeList,
      int count,
      int startTime) async {
    Map map = {
      "conversationTypeList": conversationTypeList,
      "count": count,
      "startTime": startTime
    };
    List list =
        await _channel.invokeMethod(RCMethodKey.GetConversationListByPage, map);
    if (list == null) {
      return null;
    }
    List conList = new List();
    for (String conStr in list) {
      Conversation con = MessageFactory.instance.string2Conversation(conStr);
      conList.add(con);
    }
    return conList;
  }

  ///获取特定会话的详细信息
  ///
  ///[conversationType] 会话类型，参见枚举 [RCConversationType]
  ///
  ///[targetId] 会话 id
  ///
  ///[return] 返回结果为会话的详细数据，如果不存在该会话，那么会返回 null
  static Future<Conversation> getConversation(
      int conversationType, String targetId) async {
    if (conversationType == null || targetId == null) {
      developer.log(
          "getConversation error, conversationType or targetId is null",
          name: "RongIMClient");
      return null;
    }
    Map param = {"conversationType": conversationType, "targetId": targetId};
    String conStr =
        await _channel.invokeMethod(RCMethodKey.GetConversation, param);
    Conversation con = MessageFactory.instance.string2Conversation(conStr);
    return con;
  }

  ///删除指定会话
  ///
  ///[conversationType] 会话类型，参见枚举 [RCConversationType]
  ///
  ///[targetId] 会话 id
  ///
  ///[finished] 回调结果，告知结果成功与否
  static void removeConversation(int conversationType, String targetId,
      Function(bool success) finished) async {
    Map map = {'conversationType': conversationType, 'targetId': targetId};
    bool success =
        await _channel.invokeMethod(RCMethodKey.RemoveConversation, map);
    if (finished != null) {
      finished(success);
    }
  }

  ///清除会话的未读消息
  ///
  ///[conversationType] 会话类型，参见枚举 [RCConversationType]
  ///
  ///[targetId] 会话 id
  static Future<bool> clearMessagesUnreadStatus(
      int conversationType, String targetId) async {
    Map map = {'conversationType': conversationType, 'targetId': targetId};
    bool rc =
        await _channel.invokeMethod(RCMethodKey.ClearMessagesUnreadStatus, map);
    return rc;
  }

  ///加入聊天室
  ///
  ///[targetId] 聊天室 id
  ///
  ///[messageCount] 需要获取的聊天室历史消息数量 0<=messageCount<=50
  /// -1 代表不获取历史消息
  /// 0 代表默认 10 条
  ///
  /// 会通过 [onJoinChatRoom] 回调加入的结果
  static void joinChatRoom(String targetId, int messageCount) {
    Map map = {"targetId": targetId, "messageCount": messageCount};
    _channel.invokeMethod(RCMethodKey.JoinChatRoom, map);
  }

  ///加入已存在的聊天室
  ///
  ///[targetId] 聊天室 id
  ///
  ///[messageCount] 需要获取的聊天室历史消息数量 0<=messageCount<=50
  /// -1 代表不获取历史消息
  /// 0 代表默认 10 条
  ///
  /// 会通过 [onJoinChatRoom] 回调加入的结果
  static void joinExistChatRoom(String targetId, int messageCount) {
    if (targetId == null || messageCount == null) {
      developer.log("send message fail: targetId or messageCount is null",
          name: "RongIMClient");
      return;
    }
    Map map = {"targetId": targetId, "messageCount": messageCount};
    _channel.invokeMethod(RCMethodKey.JoinExistChatRoom, map);
  }

  ///退出聊天室
  ///
  ///[targetId] 聊天室 id
  ///
  /// 会通过 [onQuitChatRoom] 回调退出的结果
  static void quitChatRoom(String targetId) {
    Map map = {"targetId": targetId};
    _channel.invokeMethod(RCMethodKey.QuitChatRoom, map);
  }

  ///获取聊天室信息
  ///
  ///[targetId] 聊天室 id
  ///
  ///[memeberCount] 需要获取的聊天室成员个数 0<=memeberCount<=20
  ///
  ///[memberOrder] 获取的成员加入聊天室的顺序，参见枚举 [RCChatRoomMemberOrder]
  ///
  static Future /*ChatRoomInfo*/ getChatRoomInfo(
      String targetId, int memeberCount, int memberOrder) async {
    if (memeberCount > 20) {
      memeberCount = 20;
    }
    Map map = {
      "targetId": targetId,
      "memeberCount": memeberCount,
      "memberOrder": memberOrder
    };
    Map resultMap =
        await _channel.invokeMethod(RCMethodKey.GetChatRoomInfo, map);
    return MessageFactory.instance.map2ChatRoomInfo(resultMap);
  }

  /// 返回一个[Map] {"code":...,"messages":...,"isRemaining":...}
  /// code:是否获取成功
  /// messages:获取到的历史消息数组,
  /// isRemaining:是否还有剩余消息 YES 表示还有剩余，NO 表示无剩余
  ///
  /// [conversationType]  会话类型，参见枚举 [RCConversationType]
  ///
  /// [targetId]          聊天室的会话ID
  ///
  /// [recordTime]        起始的消息发送时间戳，毫秒
  ///
  /// [count]             需要获取的消息数量， 0 < count <= 200
  ///
  /// 此方法从服务器端获取之前的历史消息，但是必须先开通历史消息云存储功能。
  /// 例如，本地会话中有10条消息，您想拉取更多保存在服务器的消息的话，recordTime应传入最早的消息的发送时间戳，count传入1~20之间的数值。
  static void getRemoteHistoryMessages(
      int conversationType,
      String targetId,
      int recordTime,
      int count,
      Function(List/*<Message>*/ msgList, int code) finished) async {
    Map map = {
      'conversationType': conversationType,
      'targetId': targetId,
      'recordTime': recordTime,
      'count': count
    };
    Map resultMap = await _channel.invokeMethod(
        RCMethodCallBackKey.GetRemoteHistoryMessages, map);
    int code = resultMap["code"];
    if (code == 0) {
      List msgStrList = resultMap["messages"];
      if (msgStrList == null) {
        if (finished != null) {
          finished(null, code);
        }
        return;
      }
      List l = new List();
      for (String msgStr in msgStrList) {
        Message m = MessageFactory.instance.string2Message(msgStr);
        l.add(m);
      }
      if (finished != null) {
        finished(l, code);
      }
    } else {
      if (finished != null) {
        finished(null, code);
      }
    }
  }

  /// 插入一条收到的消息
  ///
  /// [conversationType] 会话类型，参见枚举 [RCConversationType]
  ///
  /// [targetId] 会话 id
  ///
  /// [senderUserId] 发送者 id
  ///
  /// [receivedStatus] 接收状态 参见枚举 [RCReceivedStatus]
  ///
  /// [content] 消息内容，参见 [MessageContent]
  ///
  /// [sendTime] 发送时间
  ///
  /// [finished] 回调结果，会告知具体的消息和对应的错�����码
  static void insertIncomingMessage(
      int conversationType,
      String targetId,
      String senderUserId,
      int receivedStatus,
      MessageContent content,
      int sendTime,
      Function(Message msg, int code) finished) async {
    String jsonStr = content.encode();
    String objName = content.getObjectName();
    Map map = {
      "conversationType": conversationType,
      "targetId": targetId,
      "senderUserId": senderUserId,
      "rececivedStatus": receivedStatus,
      "objectName": objName,
      "content": jsonStr,
      "sendTime": sendTime
    };
    Map msgMap =
        await _channel.invokeMethod(RCMethodKey.InsertIncomingMessage, map);
    String msgString = msgMap["message"];
    int code = msgMap["code"];
    if (msgString == null) {
      if (finished != null) {
        finished(null, code);
      }
      return;
    }
    Message message = MessageFactory.instance.string2Message(msgString);
    if (finished != null) {
      finished(message, code);
    }
  }

  /// 插入一条发出的消息
  ///
  /// [conversationType] 会话类型，参见枚举 [RCConversationType]
  ///
  /// [targetId] 会话 id
  ///
  /// [sendStatus] 发送状态，参见枚举 [RCSentStatus]
  ///
  /// [content] 消息内容，参见 [MessageContent]
  ///
  /// [sendTime] 发送时间
  ///
  /// [finished] 回调结果，会告知具体的消息和对应的错误码
  static void insertOutgoingMessage(
      int conversationType,
      String targetId,
      int sendStatus,
      MessageContent content,
      int sendTime,
      Function(Message msg, int code) finished) async {
    String jsonStr = content.encode();
    String objName = content.getObjectName();
    Map map = {
      "conversationType": conversationType,
      "targetId": targetId,
      "sendStatus": sendStatus,
      "objectName": objName,
      "content": jsonStr,
      "sendTime": sendTime
    };
    Map msgMap =
        await _channel.invokeMethod(RCMethodKey.InsertOutgoingMessage, map);
    String msgString = msgMap["message"];
    int code = msgMap["code"];
    if (msgString == null) {
      if (finished != null) {
        finished(null, code);
      }
      return;
    }
    Message message = MessageFactory.instance.string2Message(msgString);
    if (finished != null) {
      finished(message, code);
    }
  }

  /// 删除特定会话的消息
  ///
  /// [conversationType] 会话类型，参见枚举 [RCConversationType]
  ///
  /// [targetId] 会话 id
  static void deleteMessages(int conversationType, String targetId,
      Function(int code) finished) async {
    Map map = {"conversationType": conversationType, "targetId": targetId};
    int code = await _channel.invokeMethod(RCMethodKey.DeleteMessages, map);
    if (finished != null) {
      finished(code);
    }
  }

  /// 批量删除消息
  ///
  /// [messageIds] 需要删除的 messageId List
  static void deleteMessageByIds(
      List<int> messageIds, Function(int code) finished) async {
    Map map = {"messageIds": messageIds};
    int code = await _channel.invokeMethod(RCMethodKey.DeleteMessageByIds, map);
    if (finished != null) {
      finished(code);
    }
  }

  /// 获取会话里第一条未读消息。
  ///
  /// [conversationType] 会话类型
  /// [targetId] 会话 ID
  static Future<Message> getFirstUnreadMessage(
      int conversationType, String targetId) async {
    Map map = {"conversationType": conversationType, "targetId": targetId};
    String msgStr =
        await _channel.invokeMethod(RCMethodKey.GetFirstUnreadMessage, map);
    if (msgStr == null) {
      return null;
    }
    Message msg = MessageFactory.instance.string2Message(msgStr);
    return msg;
  }

  /// 获取所有的未读数
  ///
  /// [finished] 回调结果，code 为 0 代表正常
  static void getTotalUnreadCount(
      Function(int count, int code) finished) async {
    Map map = await _channel.invokeMethod(RCMethodKey.GetTotalUnreadCount);
    if (finished != null) {
      finished(map["count"], map["code"]);
    }
  }

  /// 获取单个会话的未读数
  ///
  /// [conversationType] 会话类型，参见枚举 [RCConversationType]
  ///
  /// [targetId] 会话 id
  ///
  /// [finished] 回调结果，code 为 0 代表正常
  static void getUnreadCount(int conversationType, String targetId,
      Function(int count, int code) finished) async {
    Map map = {"conversationType": conversationType, "targetId": targetId};
    Map unreadMap =
        await _channel.invokeMethod(RCMethodKey.GetUnreadCountTargetId, map);
    if (finished != null) {
      finished(unreadMap["count"], unreadMap["code"]);
    }
  }

  /// 批量获取特定某些会话的未读数
  ///
  /// [conversationTypeList] 会话类型数组，参见枚举 [RCConversationType]
  ///
  /// [isContain] 是否包含免打扰会话
  ///
  /// [finished] 回调结果，code 为 0 代表正常
  static void getUnreadCountConversationTypeList(List<int> conversationTypeList,
      bool isContain, Function(int count, int code) finished) async {
    Map map = {
      "conversationTypeList": conversationTypeList,
      "isContain": isContain
    };
    Map unreadMap = await _channel.invokeMethod(
        RCMethodKey.GetUnreadCountConversationTypeList, map);
    if (finished != null) {
      finished(unreadMap["count"], unreadMap["code"]);
    }
  }

  /// 设置会话的提醒状态
  ///
  /// [conversationType] 会话类型，参见枚举 [RCConversationType]
  ///
  /// [targetId] 会话 id
  ///
  /// [finished] 回调结果，status 参见 [RCConversationNotificationStatus]，code 为 0 代表正常
  static void setConversationNotificationStatus(
      int conversationType,
      String targetId,
      bool isBlocked,
      Function(int status, int code) finished) async {
    Map map = {
      "conversationType": conversationType,
      "targetId": targetId,
      "isBlocked": isBlocked
    };
    Map statusMap = await _channel.invokeMethod(
        RCMethodKey.SetConversationNotificationStatus, map);
    if (finished != null) {
      finished(statusMap["status"], statusMap["code"]);
    }
  }

  /// 获取会话的提醒状态
  ///
  /// [conversationType] 会话类型，参见枚举 [RCConversationType]
  ///
  /// [targetId] 会话 id
  ///
  /// [finished] 回调结果，status 参见 [RCConversationNotificationStatus]，code 为 0 代表正常
  static void getConversationNotificationStatus(int conversationType,
      String targetId, Function(int status, int code) finished) async {
    Map map = {"conversationType": conversationType, "targetId": targetId};
    Map statusMap = await _channel.invokeMethod(
        RCMethodKey.GetConversationNotificationStatus, map);
    if (finished != null) {
      finished(statusMap["status"], statusMap["code"]);
    }
  }

  /// 获取设置免打扰的会话列表
  ///
  /// [conversationTypeList] 会话类型数组，参见枚举 [RCConversationType]
  ///
  /// [finished] 回调结果，code 为 0 代表正常
  static void getBlockedConversationList(
      List<int> conversationTypeList,
      Function(List/*<Conversation>*/ convertionList, int code)
          finished) async {
    Map map = {"conversationTypeList": conversationTypeList};
    Map conversationMap = await _channel.invokeMethod(
        RCMethodKey.GetBlockedConversationList, map);

    List conversationList = conversationMap["conversationList"];
    if (conversationList == null) {
      if (finished != null) {
        finished(null, conversationMap["code"]);
      }
      return;
    }
    List conList = new List();
    for (String conStr in conversationList) {
      Conversation con = MessageFactory.instance.string2Conversation(conStr);
      conList.add(con);
    }
    if (finished != null) {
      finished(conList, conversationMap["code"]);
    }
  }

  /// 设置会话置顶
  ///
  /// [conversationType] 会话类型，参见枚举 [RCConversationType]
  ///
  /// [targetId] 会话 id
  ///
  /// [isTop] 是否设置置顶
  ///
  /// [finished] 回调结果，code 为 0 代表正常
  static void setConversationToTop(int conversationType, String targetId,
      bool isTop, Function(bool status, int code) finished) async {
    Map map = {
      "conversationType": conversationType,
      "targetId": targetId,
      "isTop": isTop
    };
    Map conversationMap =
        await _channel.invokeMethod(RCMethodKey.SetConversationToTop, map);
    if (finished != null) {
      finished(conversationMap["status"], conversationMap["code"]);
    }
  }
//
//  /// TODO 安卓没有此接口
//  static void getTopConversationList(List<int> conversationTypeList, Function(List<Conversation> convertionList, int code) finished) async {
//    Map map = {
//      "conversationTypeList": conversationTypeList
//    };
//    Map conversationMap = await _channel.invokeMethod(RCMethodKey.GetTopConversationList, map);
//
//    List conversationList = conversationMap["conversationTypeList"];
//    List conList = new List();
//    for (String conStr in conversationList) {
//      Conversation con = MessageFactory.instance.string2Conversation(conStr);
//      conList.add(con);
//    }
//    if (finished != null) {
//      finished(conList, conversationMap["code"]);
//    }
//  }

  /// 将用户加入黑名单，黑名单针对用户 id 生效，即使换设备也依然生效。
  ///
  /// [userId] 需要加入黑名单的用户 id
  ///
  /// [finished] 回调结果，code 为 0 代表操作成功，其他值代表失败
  static void addToBlackList(String userId, Function(int code) finished) async {
    Map map = {"userId": userId};
    int code = await _channel.invokeMethod(RCMethodKey.AddToBlackList, map);
    if (finished != null) {
      finished(code);
    }
  }

  /// 将用户移除黑名单
  ///
  /// [userId] 需要移除黑名单的用户 id
  ///
  /// [finished] 回调结果，code 为 0 代表操作成功，其他值代表失败
  static void removeFromBlackList(
      String userId, Function(int code) finished) async {
    Map map = {"userId": userId};
    int code =
        await _channel.invokeMethod(RCMethodKey.RemoveFromBlackList, map);
    if (finished != null) {
      finished(code);
    }
  }

  /// 获取特定用户的黑名单状态
  ///
  /// [userId] 需要加入黑名单的用户 id
  ///
  /// [finished] 回调结果，code 为 0 代表操作成功，其他值代表失败
  ///
  /// [blackListStatus] 黑名单状态，0 代表在黑名单，1 代表不在黑名单，详细参见 [RCBlackListStatus]
  static void getBlackListStatus(
      String userId, Function(int blackListStatus, int code) finished) async {
    Map map = {"userId": userId};
    Map result =
        await _channel.invokeMethod(RCMethodKey.GetBlackListStatus, map);
    int status = result["status"];
    int code = result["code"];
    if (finished != null) {
      finished(status, code);
    }
  }

  /// 查询已经设置的黑名单列表
  ///
  /// [finished] 回调结果，code 为 0 代表操作成功，其他值代表失败
  ///
  /// [userIdList] 黑名单用户 id 列表
  static void getBlackList(
      Function(List/*<String>*/ userIdList, int code) finished) async {
    Map result = await _channel.invokeMethod(RCMethodKey.GetBlackList);
    List userIdList = result["userIdList"];
    int code = result["code"];
    if (finished != null) {
      finished(userIdList, code);
    }
  }

  /// 发送某个会话中消息阅读的回执
  ///
  /// [conversationType] 会话类型，参见枚举 [RCConversationType]
  ///
  /// [targetId] 会话 id
  ///
  /// [timestamp] 该会话已阅读的最后一条消息的发送时间戳
  ///
  /// [finished] 回调结果，code 为 0 代表操作成功，其他值代表失败
  /// 此接口只支持单聊
  static void sendReadReceiptMessage(int conversationType, String targetId,
      int timestamp, Function(int code) finished) async {
    Map map = {
      "conversationType": conversationType,
      "targetId": targetId,
      "timestamp": timestamp
    };

    Map result =
        await _channel.invokeMethod(RCMethodKey.SendReadReceiptMessage, map);
    int code = result["code"];
    if (finished != null) {
      finished(code);
    }
  }

  /// 请求消息阅读回执
  ///
  /// [message] 要求阅读回执的消息
  ///
  /// [timestamp] 该会话已阅读的最后一条消息的发送时间戳
  ///
  /// [finished] 回调结果，code 为 0 代表操作成功，其他值代表失败
  /// 此接口只支持群组
  static void sendReadReceiptRequest(
      Message message, Function(int code) finished) async {
    Map messageMap = MessageFactory.instance.message2Map(message);
    Map map = {"messageMap": messageMap};

    Map result =
        await _channel.invokeMethod(RCMethodKey.SendReadReceiptRequest, map);
    int code = result["code"];
    if (finished != null) {
      finished(code);
    }
  }

  /// 发送阅读回执
  ///
  /// [conversationType] 会话类型，参见枚举 [RCConversationType]
  ///
  /// [targetId] 会话 id
  ///
  /// [messageList] 已经阅读了的消息列表
  ///
  /// [finished] 回调结果，code 为 0 代表操作成功，其他值代表失败
  /// 此接口只支持群组
  static void sendReadReceiptResponse(int conversationType, String targetId,
      List messageList, Function(int code) finished) async {
    List messageMaps = List();
    for (Message message in messageList) {
      Map messageMap = MessageFactory.instance.message2Map(message);
      messageMaps.add(messageMap);
    }
    Map map = {
      "conversationType": conversationType,
      "targetId": targetId,
      "messageMapList": messageMaps
    };

    Map result =
        await _channel.invokeMethod(RCMethodKey.SendReadReceiptResponse, map);
    int code = result["code"];
    if (finished != null) {
      finished(code);
    }
  }

  /// 同步会话阅读状态
  ///
  /// [conversationType] 会话类型，参见枚举 [RCConversationType]
  ///
  /// [targetId] 会话 id
  ///
  /// [timestamp] 该会话已阅读的最后一条消息的发送时间戳
  ///
  /// [finished] 回调结果，code 为 0 代表操作成功，其他值代表失败
  ///
  static void syncConversationReadStatus(int conversationType, String targetId,
      int timestamp, Function(int code) finished) async {
    Map map = {
      "conversationType": conversationType,
      "targetId": targetId,
      "timestamp": timestamp
    };

    int result = await _channel.invokeMethod(
        RCMethodKey.SyncConversationReadStatus, map);
    if (finished != null) {
      finished(result);
    }
  }

  /// 全局屏蔽某个时间段的消息提醒
  ///
  /// [startTime] 开始屏蔽消息提醒的时间，格式为HH:MM:SS
  ///
  /// [spanMins] 需要屏蔽消息提醒的分钟数，0 < spanMins < 1440
  ///
  /// [finished] 回调结果，code 为 0 代表操作成功，其他值代表失败
  ///
  /// 此方法设置的屏蔽时间会在每天该时间段时生效。
  static void setNotificationQuietHours(
      String startTime, int spanMins, Function(int code) finished) async {
    Map map = {"startTime": startTime, "spanMins": spanMins};
    int result =
        await _channel.invokeMethod(RCMethodKey.SetNotificationQuietHours, map);
    if (finished != null) {
      finished(result);
    }
  }

  /// 删除已设置的全局时间段消息提醒屏蔽
  ///
  /// [finished] 回调结果，code 为 0 代表操作成功，其他值代表失败
  ///
  static void removeNotificationQuietHours(Function(int code) finished) async {
    int result =
        await _channel.invokeMethod(RCMethodKey.RemoveNotificationQuietHours);
    if (finished != null) {
      finished(result);
    }
  }

  /// 查询已设置的全局时间段消息提醒屏蔽
  ///
  /// [finished] 回调结果，code 为 0 代表操作成功，其他值代表失败；startTime 代表已设置的屏蔽开始时间，spansMin 代表已设置的屏蔽时间分钟数，0 < spansMin < 1440
  ///
  static void getNotificationQuietHours(
      Function(int code, String startTime, int spansMin) finished) async {
    Map result =
        await _channel.invokeMethod(RCMethodKey.GetNotificationQuietHours);
    int code = result["code"];
    String startTime = result["startTime"];
    int spansMin = result["spansMin"];
    if (finished != null) {
      finished(code, startTime, spansMin);
    }
  }

  /// 获取会话中@提醒自己的消息
  ///
  /// [conversationType] 会话类型，参见枚举 [RCConversationType]
  ///
  /// [targetId] 会话 id
  ///
  /// 此方法从本地获取被@提醒的消息(最多返回10条信息)
  /// clearMessagesUnreadStatus: targetId: 以及设置消息接收状态接口 setMessageReceivedStatus:receivedStatus:会同步清除被提示信息状态。
  static Future<List /*Message*/ > getUnreadMentionedMessages(
      int conversationType, String targetId) async {
    Map map = {"conversationType": conversationType, "targetId": targetId};
    List list = await _channel.invokeMethod(
        RCMethodKey.GetUnreadMentionedMessages, map);
    if (list == null) {
      return List();
    }
    List messageList = new List();
    for (String conStr in list) {
      Message msg = MessageFactory.instance.string2Message(conStr);
      messageList.add(msg);
    }
    return messageList;
  }

  /// 开始焚烧消息
  static void messageBeginDestruct(Message message) async {
    Map messageMap = MessageFactory.instance.message2Map(message);
    Map map = {"message": messageMap};
    await _channel.invokeMethod(RCMethodKey.MessageBeginDestruct, map);
  }

  /// 停止焚烧消息（目前仅支持单聊）
  static void messageStopDestruct(Message message) async {
    Map messageMap = MessageFactory.instance.message2Map(message);
    Map map = {"message": messageMap};
    await _channel.invokeMethod(RCMethodKey.MessageStopDestruct, map);
  }

  /// 设置聊天室自定义属性
  ///
  /// [chatroomId] 聊天室 Id
  ///
  /// [key] 聊天室属性名称，Key 支持大小写英文字母、数字、部分特殊符号 + = - _ 的组合方式，最大长度 128 个字符
  ///
  /// [value] 聊天室属性对应的值，最大长度 4096 个字符
  ///
  /// [sendNotification] 是否需要发送通知，如果发送通知，聊天室中的其他用户会接收到 RCChatroomKVNotificationMessage 通知消息，消息内容中包含操作类型(type)、属性名称(key)、属性名称对应的值(value)和自定义字段(extra)
  ///
  /// [autoDelete] 用户掉线或退出时，是否自动删除该 Key、Value 值；自动删除时不会发送通知
  ///
  /// [notificationExtra] 通知的自定义字段，RC:chrmKVNotiMsg 通知消息中会包含此字段，最大长度 2 kb
  ///
  /// [finished] 回调结果，code 为 0 代表操作成功，其他值代表失败
  /// 此接口只支持聊天室，必须先开通聊天室属性自定义功能
  static void setChatRoomEntry(
      String chatRoomId,
      String key,
      String value,
      bool sendNotification,
      bool autoDelete,
      String notificationExtra,
      Function(int code) finished) async {
    Map map = {
      "chatRoomId": chatRoomId,
      "key": key,
      "value": value,
      "sendNotification": sendNotification,
      "autoDelete": autoDelete,
      "notificationExtra": notificationExtra
    };
    int result = await _channel.invokeMethod(RCMethodKey.SetChatRoomEntry, map);
    if (finished != null) {
      finished(result);
    }
  }

  /// 强制设置聊天室自定义属性
  ///
  /// [chatroomId] 聊天室 Id
  ///
  /// [key] 聊天室属性名称，Key 支持大小写英文字母、数字、部分特殊符号 + = - _ 的组合方式，最大长度 128 个字符
  ///
  /// [value] 聊天室属性对应的值，最大长度 4096 个字符
  ///
  /// [sendNotification] 是否需要发送通知，如果发送通知，聊天室中的其他用户会接收到 RCChatroomKVNotificationMessage 通知消息，消息内容中包含操作类型(type)、属性名称(key)、属性名称对应的值(value)和自定义字段(extra)
  ///
  /// [autoDelete] 用户掉线或退出时，是否自动删除该 Key、Value 值；自动删除时不会发送通知
  ///
  /// [notificationExtra] 通知的自定义字段，RC:chrmKVNotiMsg 通知消息中会包含此字段，最大长度 2 kb
  ///
  /// [finished] 回调结果，code 为 0 代表操作成功，其他值代表失败
  /// 此接口只支持聊天室，必须先开通聊天室属性自定义功能
  static void forceSetChatRoomEntry(
      String chatRoomId,
      String key,
      String value,
      bool sendNotification,
      bool autoDelete,
      String notificationExtra,
      Function(int code) finished) async {
    Map map = {
      "chatRoomId": chatRoomId,
      "key": key,
      "value": value,
      "sendNotification": sendNotification,
      "autoDelete": autoDelete,
      "notificationExtra": notificationExtra
    };
    int result =
        await _channel.invokeMethod(RCMethodKey.ForceSetChatRoomEntry, map);
    if (finished != null) {
      finished(result);
    }
  }

  /// 获取聊天室单个属性
  ///
  /// [chatroomId] 聊天室 Id
  ///
  /// [key] 聊天室属性名称
  ///
  /// [finished] 回调结果，code 为 0 代表操作成功，其他值代表失败，entry 为返回的 map
  /// 此接口只支持聊天室，必须先开通聊天室属性自定义功能
  static void getChatRoomEntry(String chatRoomId, String key,
      Function(Map entry, int code) finished) async {
    Map map = {"chatRoomId": chatRoomId, "key": key};

    Map result = await _channel.invokeMethod(RCMethodKey.GetChatRoomEntry, map);
    int code = result["code"];
    Map entry = result["entry"];
    if (finished != null) {
      finished(entry, code);
    }
  }

  /// 获取聊天室所有自定义属性
  ///
  /// [chatroomId] 聊天室 Id
  ///
  /// [finished] 回调结果，code 为 0 代表操作成功，其他值代表失败，entry 为返回的 map
  /// 此接口只支持聊天室，必须先开通聊天室属性自定义功能
  static void getAllChatRoomEntries(
      String chatRoomId, Function(Map entry, int code) finished) async {
    Map map = {"chatRoomId": chatRoomId};

    Map result =
        await _channel.invokeMethod(RCMethodKey.GetAllChatRoomEntries, map);
    int code = result["code"];
    Map entry = result["entry"];
    if (finished != null) {
      finished(entry, code);
    }
  }

  /// 删除聊天室自定义属性
  ///
  /// [chatroomId] 聊天室 Id
  ///
  /// [key] 聊天室属性名称
  ///
  /// [sendNotification] 是否需要发送通知，如果发送通知，聊天室中的其他用户会接收到 RCChatroomKVNotificationMessage 通知消息，消息内容中包含操作类型(type)、属性名称(key)、属性名称对应的值(value)和自定义字段(extra)
  ///
  /// [notificationExtra] 通知的自定义字段，RC:chrmKVNotiMsg ������消息中会包含此字段，最大长度 2 kb
  ///
  /// [finished] 回调结果，code 为 0 代表操作成功，其他值代表失败
  /// 此接口只支持聊天室，必须先开通聊天室属性自定义功能
  static void removeChatRoomEntry(
      String chatRoomId,
      String key,
      bool sendNotification,
      String notificationExtra,
      Function(int code) finished) async {
    Map map = {
      "chatRoomId": chatRoomId,
      "key": key,
      "sendNotification": sendNotification,
      "notificationExtra": notificationExtra
    };
    int result =
        await _channel.invokeMethod(RCMethodKey.RemoveChatRoomEntry, map);
    if (finished != null) {
      finished(result);
    }
  }

  /// 强制删除聊天室自定义属性
  ///
  /// [chatroomId] 聊天室 Id
  ///
  /// [key] 聊天室属性名称
  ///
  /// [sendNotification] 是否需要发送通知，如果发送通知，聊天室中的其他用户会接收到 RCChatroomKVNotificationMessage 通知消息，消息内容中包含操作类型(type)、属性名称(key)、属性名称对应的值(value)和自定义字段(extra)
  ///
  /// [notificationExtra] 通知的自定义字段，RC:chrmKVNotiMsg 通知消息中会包含此字段，最大长度 2 kb
  ///
  /// [finished] 回调结果，code 为 0 代表操作成功，其他值代表失败
  /// 此接口只支持聊天室，必须先开通聊天室属性自定义功能
  static void forceRemoveChatRoomEntry(
      String chatRoomId,
      String key,
      bool sendNotification,
      String notificationExtra,
      Function(int code) finished) async {
    Map map = {
      "chatRoomId": chatRoomId,
      "key": key,
      "sendNotification": sendNotification,
      "notificationExtra": notificationExtra
    };
    int result =
        await _channel.invokeMethod(RCMethodKey.ForceRemoveChatRoomEntry, map);
    if (finished != null) {
      finished(result);
    }
  }

  ///撤回消息
  ///
  ///
  /// 当接收方离线并允许远程推送时，会收到远程推送。
  /// 远程推送中包含两部分内容，一是[pushContent]，用于显示；二是[pushData]，用于携带不显示的数据。
  ///
  /// SDK内置的消息类型，如果您将[pushContent]和[pushData]置为空或者为null，会使用默认的推送格式进行远程推送。
  /// 自定义类型的消息，需要您自己设置pushContent和pushData来定义推送内容，否则将不会进行远程推送。
  static Future<RecallNotificationMessage> recallMessage(
      Message message, String pushContent) async {
    if (message == null) {
      developer.log(
          "send message fail: conversationType or targetId or content is null",
          name: "RongIMClient");
      return null;
    }
    if (pushContent == null) {
      pushContent = "";
    }
    Map msgMap = MessageFactory.instance.message2Map(message);
    Map map = {"message": msgMap, "pushContent": pushContent};
    Map resultMap = await _channel.invokeMethod(RCMethodKey.RecallMessage, map);
    if (resultMap == null) {
      return null;
    }
    String messageString = resultMap["recallNotificationMessage"];
    if (messageString == null || messageString.isEmpty) {
      developer.log(
          "send message fail: conversationType or targetId or content is null",
          name: "RongIMClient");
      return null;
    }
    RecallNotificationMessage msg = MessageFactory.instance
        .string2MessageContent(
            messageString, RecallNotificationMessage.objectName);
    return msg;
  }

  ///根据消息类型，targetId 获取某一会话的文字消息草稿。用于获取用户输入但未发送的暂存消息。
  static Future<String> getTextMessageDraft(
      int conversationType, String targetId) async {
    if (conversationType == null || targetId == null) {
      developer.log(
          "saveTextMessageDraft fail: conversationType or targetId or content is null",
          name: "RongIMClient");
      return null;
    }
    Map paramMap = {
      "conversationType": conversationType,
      "targetId": targetId,
    };
    String result =
        await _channel.invokeMethod(RCMethodKey.GetTextMessageDraft, paramMap);
    return result;
  }

  ///根据消息类型，targetId 保存某一会话的文字消息草稿。用于暂存用户输入但未发送的消息
  static Future<bool> saveTextMessageDraft(
      int conversationType, String targetId, String textContent) async {
    if (conversationType == null || targetId == null || textContent == null) {
      developer.log(
          "saveTextMessageDraft fail: conversationType or targetId or content is null",
          name: "RongIMClient");
      return null;
    }
    Map paramMap = {
      "conversationType": conversationType,
      "targetId": targetId,
      "content": textContent
    };
    bool result =
        await _channel.invokeMethod(RCMethodKey.SaveTextMessageDraft, paramMap);
    return result;
  }

  ///搜索会话（根据关键词）
  /// keyword           搜索的关键字。
  /// conversationTypes 搜索的会话类型。
  /// objectNames       搜索的消息类型,例如:RC:TxtMsg。
  /// resultCallback    搜索结果回调。
  static void searchConversations(
      String keyword,
      List conversationTypes,
      List objectNames,
      Function(int code, List searchConversationResult) finished) async {
    Map paramMap = {
      "keyword": keyword,
      "conversationTypes": conversationTypes,
      "objectNames": objectNames
    };
    Map result =
        await _channel.invokeMethod(RCMethodKey.SearchConversations, paramMap);
    if (result != null) {
      int code = result['code'];
      List resultList = new List();
      if (code == 0) {
        List searchConversationResult = result['SearchConversationResult'];
        for (String resultStr in searchConversationResult) {
          SearchConversationResult searchConversationResult = MessageFactory
              .instance
              .string2SearchConversationResult(resultStr);
          resultList.add(searchConversationResult);
        }
      }
      if (finished != null) {
        finished(code, resultList);
      }
    }
  }

  /// 根据会话,搜索本地历史消息。
  /// 搜索结果可分页返回。
  /// conversationType 指定的会话类型。
  /// targetId         指定的会话 id。
  /// keyword          搜索的关键字。
  /// count            返回的搜索结果数量, count > 0。
  /// beginTime        查询记录的起始时间, 传0时从最新消息开始搜索。从该时间往前搜索。
  /// resultCallback   搜索结果回调。
  static void searchMessages(
      int conversationType,
      String targetId,
      String keyword,
      int count,
      int beginTime,
      Function(List/*<Message>*/ msgList, int code) finished) async {
    Map paramMap = {
      "conversationType": conversationType,
      "targetId": targetId,
      "keyword": keyword,
      "count": count,
      "beginTime": beginTime,
    };
    Map resultMap =
        await _channel.invokeMethod(RCMethodKey.SearchMessages, paramMap);
    int code = resultMap["code"];
    if (code == 0) {
      List msgStrList = resultMap["messages"];
      if (msgStrList == null) {
        if (finished != null) {
          finished(null, code);
        }
        return;
      }
      List l = new List();
      for (String msgStr in msgStrList) {
        Message m = MessageFactory.instance.string2Message(msgStr);
        l.add(m);
      }
      if (finished != null) {
        finished(l, code);
      }
    } else {
      if (finished != null) {
        finished(null, code);
      }
    }
  }

  /// 发送输入状态
  static void sendTypingStatus(
      int conversationType, String targetId, String typingContentType) async {
    Map paramMap = {
      "conversationType": conversationType,
      "targetId": targetId,
      "typingContentType": typingContentType,
    };
    await _channel.invokeMethod(RCMethodKey.SendTypingStatus, paramMap);
  }

  /// 下载媒体文件
  static void downloadMediaMessage(Message message) async {
    Map msgMap = MessageFactory.instance.message2Map(message);
    Map paramMap = {"message": msgMap};
    await _channel.invokeMethod(RCMethodKey.DownloadMediaMessage, paramMap);
  }

  static void saveMediaToPublicDir(String filePath, String type) async {
    Map paramMap = {"filePath": filePath, "type": type};
    await _channel.invokeMethod(RCMethodKey.SaveMediaToPublicDir, paramMap);
  }

  static void forwardMessageByStep(
      int conversationType, String targetId, Message message,
      {Function(int messageId, int status, int code) finished}) async {
    Map msgMap = MessageFactory.instance.message2Map(message);
    // 此处获取当前时间戳传给原生方法，并且当做 sendMessageCallbacks 的 key 记录 finished
    DateTime time = DateTime.now();
    int timestamp = time.millisecondsSinceEpoch;

    Map map = {
      "message": msgMap,
      "conversationType": conversationType,
      "targetId": targetId,
      "timestamp": timestamp
    };

    if (finished != null) {
      sendMessageCallbacks[timestamp] = finished;
    }
    await _channel.invokeMethod(RCMethodKey.ForwardMessageByStep, map);
  }

  ///删除指定的一条或者一组消息。会同时删除本地和远端消息
  /// 会话类型, 不支持聊天室
  static void deleteRemoteMessages(int conversationType, String targetId,
      List<Message> messages, Function(int code) finished) async {
    if (conversationType == null || targetId == null) {
      developer.log(
          "deleteRemoteMessages fail: conversationType or targetId or content is null",
          name: "RongIMClient");
      return null;
    }
    List<Map> msgMapList = List();
    for (Message message in messages) {
      msgMapList.add(MessageFactory.instance.message2Map(message));
    }
    Map paramMap = {
      "conversationType": conversationType,
      "targetId": targetId,
      "messages": msgMapList
    };
    int result =
        await _channel.invokeMethod(RCMethodKey.DeleteRemoteMessages, paramMap);
    if (finished != null) {
      finished(result);
    }
  }

  /// 清空指定类型，targetId 的某一会话所有聊天消息记录
  static void clearMessages(int conversationType, String targetId,
      Function(int code) finished) async {
    if (conversationType == null || targetId == null) {
      developer.log(
          "clearMessages fail: conversationType or targetId or content is null",
          name: "RongIMClient");
      return null;
    }
    Map paramMap = {
      "conversationType": conversationType,
      "targetId": targetId,
    };
    int result =
        await _channel.invokeMethod(RCMethodKey.ClearMessages, paramMap);
    if (finished != null) {
      finished(result);
    }
  }

  /// 设置本地消息的附加信息
  static void setMessageExtra(
      int messageId, String value, Function(int code) finished) async {
    Map paramMap = {
      "messageId": messageId,
      "value": value,
    };
    int result =
        await _channel.invokeMethod(RCMethodKey.SetMessageExtra, paramMap);
    if (finished != null) {
      finished(result);
    }
  }

  /// 根据 messageId 设置接收到的消息状态。用于UI标记消息为已读，已下载等状态。
  static void setMessageReceivedStatus(
      int messageId, int receivedStatus, Function(int code) finished) async {
    Map paramMap = {
      "messageId": messageId,
      "receivedStatus": receivedStatus,
    };
    int result = await _channel.invokeMethod(
        RCMethodKey.SetMessageReceivedStatus, paramMap);
    if (finished != null) {
      finished(result);
    }
  }

  /// 根据 messageId 设置消息的发送状态。用于UI标记消息为正在发送，对方已接收等状态。
  static void setMessageSentStatus(
      int messageId, int sentStatus, Function(int code) finished) async {
    Map paramMap = {
      "messageId": messageId,
      "sentStatus": sentStatus,
    };
    int result =
        await _channel.invokeMethod(RCMethodKey.SetMessageSentStatus, paramMap);
    if (finished != null) {
      finished(result);
    }
  }

  /// 清空会话类型列表中的所有会话及会话信息
  static void clearConversations(
      List<int> conversationTypes, Function(int code) finished) async {
    Map paramMap = {"conversationTypes": conversationTypes};
    int result =
        await _channel.invokeMethod(RCMethodKey.ClearConversations, paramMap);
    if (finished != null) {
      finished(result);
    }
  }

  /// 获取本地时间与服务器时间的差值。 消息发送成功后，sdk 会与服务器同步时间，消息所在数据库中存储的时间就是服务器时间。
  static Future<int> getDeltaTime() async {
    int result = await _channel.invokeMethod(RCMethodKey.GetDeltaTime);
    return result;
  }

  /// 设置当前用户离线消息补偿时间
  /// 离线消息补偿时间是指某用户离线后，在下次登录时，服务端下发的离线消息对应的时间段。比如某应用的离线消息补偿时间是 2 天，用户离线 3 天，在第 4 天登录的时候，
  /// 服务端只会主动下发该用户第 2 天和第 3 天对应的离线消息；第 1 天的离线消息不会下发。
  /// 该功能首先需要客户提工单，在服务端开通此功能后，客户端调用该方法才生效
  /// duration 离线消息补偿时间，参数取值范围为int值1~7天。
  static void setOfflineMessageDuration(
      int duration, Function(int code, int result) finished) async {
    Map paramMap = {"duration": duration};
    Map result = await _channel.invokeMethod(
        RCMethodKey.SetOfflineMessageDuration, paramMap);
    if (finished != null) {
      finished(result["code"], result["result"]);
    }
  }

  ///获取当前用户离线消息的存储时间，取值范围为int值1~7天
  static Future<int> getOfflineMessageDuration() async {
    int duration =
        await _channel.invokeMethod(RCMethodKey.GetOfflineMessageDuration);
    return duration;
  }

  ///设置断线重连时是否踢出当前正在重连的设备
  ///
  ///[targetId] 聊天室 id
  ///
  /// 用户没有开通多设备登录功能的前提下，同一个账号在一台新设备上登录的时候，会把这个账号在之前登录的设备上踢出。
  /// 由于 SDK 有断线重连功能，存在下面情况。
  /// 用户在 A 设备登录，A 设备网络不稳定，没有连接成功，SDK 启动重连机制。
  /// 用户此时又在 B 设备登录，B 设备连接成功。
  /// A 设备网络稳定之后，用户在 A 设备连接成功，B 设备被踢出。
  /// 这个接口就是为这种情况加的。
  /// 设置 enable 为 true 时，SDK 重连的时候发现此时已有别的设备连接成功，不再强行踢出已有设备，而是踢出重连设备。
  static void setReconnectKickEnable(bool enable) {
    _channel.invokeMethod(RCMethodKey.SetReconnectKickEnable, enable);
  }

  ///获取当前 SDK 的连接状态
  static Future<int /*RCConnectionStatus*/ > getConnectionStatus() async {
    int code = await _channel.invokeMethod(RCMethodKey.GetConnectionStatus);
    int status = ConnectionStatusConvert.convert(code);
    return status;
  }

  ///取消下载中的媒体文件
  static Future<bool> cancelDownloadMediaMessage(int messageId) async {
    bool success = await _channel.invokeMethod(
        RCMethodKey.CancelDownloadMediaMessage, messageId);
    return success;
  }

  // 从服务器端获取聊天室的历史消息。
  // targetId         指定的会话 id。
  // recordTime       起始的消息发送时间戳，毫秒
  // count            需要获取的消息数量， 0 < count <= 200
  // order            拉取顺序，RC_Timestamp_Desc:倒序，RC_Timestamp_ASC:正序
  // resultCallback   获取结果回调。
  static void getRemoteChatRoomHistoryMessages(
      String targetId,
      int recordTime,
      int count,
      int /*RCTimestampOrder*/ order,
      Function(List/*<Message>*/ msgList, int syncTime, int code)
          finished) async {
    Map map = {
      "targetId": targetId,
      "recordTime": recordTime,
      "count": count,
      "order": order,
    };
    Map resultMap = await _channel.invokeMethod(
        RCMethodKey.GetRemoteChatRoomHistoryMessages, map);
    int code = resultMap["code"];
    int syncTime = resultMap["syncTime"];
    if (code == 0) {
      List msgStrList = resultMap["messages"];
      if (msgStrList == null) {
        if (finished != null) {
          finished(null, syncTime, code);
        }
        return;
      }
      List list = new List();
      for (String msgStr in msgStrList) {
        Message m = MessageFactory.instance.string2Message(msgStr);
        list.add(m);
      }
      if (finished != null) {
        finished(list, syncTime, code);
      }
    } else {
      if (finished != null) {
        finished(null, syncTime, code);
      }
    }
  }

  ///通过全局唯一 ID 获取消息实体
  ///发送 message 成功后，服务器会给每个 message 分配一个唯一 ID(messageUId)
  static Future<Message> getMessageByUId(String messageUId) async {
    Map map = {"messageUId": messageUId};
    String msgStr =
        await _channel.invokeMethod(RCMethodKey.GetMessageByUId, map);
    if (msgStr == null) {
      return null;
    }
    Message msg = MessageFactory.instance.string2Message(msgStr);
    return msg;
  }

  ///更新消息扩展信息
  ///
  ///[expansionDic] 要更新的消息扩展信息键值对
  ///
  ///[messageUId] 消息 messageUId
  ///
  ///[finished] 回调结果，code 为 0 代表操作成功，其他值代表失败
  ///
  ///消息扩展信息是以字典形式存在。设置的时候从 expansionDic 中读取 key，如果原有的扩展信息中 key 不存在则添加新的 KV 对，如果 key 存在则替换成新的 value。
  ///
  ///扩展信息只支持单聊和群组，其它会话类型不能设置扩展信息
  ///
  ///扩展信息字典中的 Key 支持大小写英文字母、数字、部分特殊符号 + = - _ 的组合方式，最大长度 32；Value 最长长度，单次设置扩展数量最大为 20，消息的扩展总数不能超过 300
  static Future updateMessageExpansion(
      Map expansionDic, String messageUId, Function(int code) finished) async {
    // if (memeberCount > 20) {
    //   memeberCount = 20;
    // }
    Map map = {"expansionDic": expansionDic, "messageUId": messageUId};
    int resultMap =
        await _channel.invokeMethod(RCMethodKey.UpdateMessageExpansion, map);
    if (finished != null) {
      finished(resultMap);
    }
  }

  ///删除消息扩展信息中特定的键值对
  ///
  ///[keyArray] 消息扩展信息中待删除的 key 的列表
  ///
  ///[messageUId] 消息 messageUId
  ///
  ///[finished] 回调结果，code 为 0 代表操作成功，其他值代表失败
  ///
  ///扩展信息只支持单聊和群组，其它会话类型不能设置扩展信息
  static Future removeMessageExpansionForKey(
      List keyArray, String messageUId, Function(int code) finished) async {
    Map map = {"keyArray": keyArray, "messageUId": messageUId};
    int resultMap = await _channel.invokeMethod(
        RCMethodKey.RemoveMessageExpansionForKey, map);
    if (finished != null) {
      finished(resultMap);
    }
  }

  ///连接状态发生变更
  ///
  /// [connectionStatus] 连接状态，具体参见枚举 [RCConnectionStatus]
  static Function(int connectionStatus) onConnectionStatusChange;

  ///消息扩展信息更改的回调
  ///
  /// [expansionDic] 消息扩展信息中更新的键值对
  ///
  /// [message] 消息
  ///
  /// expansionDic 只包含更新的键值对，不是全部的数据。如果想获取全部的键值对，请使用 message 的 expansionDic 属性。
  static Function(Map expansionDic, Message message) messageExpansionDidUpdate;

  ///消息扩展信息删除的回调
  ///
  /// [keyArray] 消息扩展信息中删除的键值对 key 列表
  ///
  /// [message] 消息
  ///
  /// expansionDic 只包含更新的键值对，不是全部的数据。如果想获取全部的键值对，请使用 message 的 expansionDic 属性。
  static Function(List keyArray, Message message) messageExpansionDidRemove;

  ///调用发送消息接口 [sendMessage] 结果的回调
  ///
  /// [messageId]  消息 id
  ///
  /// [status] 消息发送状态，参见枚举 [RCSentStatus]
  ///
  /// [code] 具体的错误码，0 代表成功
  static Function(int messageId, int status, int code) onMessageSend;

  ///收到消息的回调，功能和 onMessageReceivedWrapper 一样，两个回调只能实现一个，否则会出现重复收到消息的情况
  ///
  ///[msg] 消息
  ///
  ///[left] 剩余未接收的消息个数 left>=0，建议在 left == 0 是刷新会话列表
  ///
  ///如果离线消息量不大，可以使用该回调；如果离线消息量巨大，那么使用下面 [onMessageReceivedWrapper] 回调
  static Function(Message msg, int left) onMessageReceived;

  ///收到消息的回调，功能和 onMessageReceived 一样，两个回调只能实现一个，否则会出现重复收到消息的情况
  ///
  ///[msg] 消息
  ///
  ///[left] 剩余未接收的消息个数 left>=0
  ///
  ///[hasPackage] 是否远端还有尚未被接收的消息，当为 false 是代表远端没有更多的离线消息了
  ///
  ///[offline] 消息是否是离线消息
  ///
  ///SDK 分批拉取离线消息，当离线消息量巨大的时候，建议当 left == 0 且 hasPackage == false 时刷新会话列表
  static Function(Message msg, int left, bool hasPackage, bool offline)
      onMessageReceivedWrapper;

  ///加入聊天的回调
  ///
  ///[targetId] 聊天室 id
  ///
  ///[status] 参见枚举 [RCOperationStatus]
  static Function(String targetId, int status) onJoinChatRoom;

  ///退出聊天的回调
  ///
  ///[targetId] 聊天室 id
  ///
  ///[status] 参见枚举 [RCOperationStatus]
  static Function(String targetId, int status) onQuitChatRoom;

  ///刚加入聊天室时 KV 同步完成的回调
  ///
  ///[roomId] 聊天室 id
  static Function(String roomId) chatRoomKVDidSync;

  ///聊天室 KV 变化的回调
  ///
  ///[roomId] 聊天室 id
  ///
  ///[entry] KV 字典，如果刚进入聊天室时存在  KV，会通过此回调将所有 KV 返回，再次回调时为其他人设置或者修改 KV
  static Function(String roomId, Map entry) chatRoomKVDidUpdate;

  ///聊天室 KV 被删除的回调
  ///
  ///[roomId] 聊天室 id
  ///
  ///[entry] KV 字典
  static Function(String roomId, Map entry) chatRoomKVDidRemove;

  ///发送媒体消息（图片/语音消息）的媒体上传进度
  ///
  ///[messageId] 消息 id
  ///
  ///[progress] 上传进度 0~100
  static Function(int messageId, int progress) onUploadMediaProgress;

  ///收到原生数据的回调
  ///
  ///[data] 传递的数据内容
  ///
  /// 如果传送的是push内容 建议在 main.dart 使用
  static Function(Map data) onDataReceived;

  ///收到已读消息回执
  ///
  ///[data] 回执的内容 {messageTime=已��读����最后一条消息的sendTime, tId=会话的targetId, ctype=会话类型}
  ///
  ///eg:{messageTime=1575530815100, tId='c1Its71dc', ctype=1}
  static Function(Map data) onReceiveReadReceipt;

  ///请求消息已读回执
  ///
  ///[data] 回执的内容 {messageUId=请求已读回执的消息ID, conversationType=会话类型, targetId=会话的targetId}
  ///
  static Function(Map data) onMessageReceiptRequest;

  ///消息已读回执响应（收到阅读回执响应，可以按照 messageUId 更新消息的阅读数）
  ///
  ///[data] 回执的内容 {messageUId=请求已读回执的消息ID, conversationType=会话类型, targetId=会话的targetId, userIdList=已读userId列表}
  ///
  static Function(Map data) onMessageReceiptResponse;

  // 下载媒体文件响应
  static Function(int code, int progress, int messageId, Message message)
      onDownloadMediaMessageResponse;

  //输入状态的监听
  static Function(int conversationType, String targetId, List typingStatus)
      onTypingStatusChanged;

  //撤回消息监听
  static Function(Message msg) onRecallMessageReceived;

  //消息正在焚烧
  static Function(Message msg, int remainDuration) onMessageDestructing;

  //数据库打开（调用 connect 之后回调）
  static Function(int status) onDatabaseOpened;

  ///响应原生的事件
  ///
  static void _addNativeMethodCallHandler() {
    _channel.setMethodCallHandler((MethodCall call) {
      switch (call.method) {
        case RCMethodCallBackKey.SendMessage:
          {
            Map argMap = call.arguments;
            int msgId = argMap["messageId"];
            int status = argMap["status"];
            int code = argMap["code"];
            int timestamp = argMap["timestamp"];
            if (timestamp != null && timestamp > 0) {
              Function(int messageId, int status, int code) finished =
                  sendMessageCallbacks[timestamp];
              if (finished != null) {
                finished(msgId, status, code);
                sendMessageCallbacks.remove(timestamp);
              } else {
                if (onMessageSend != null) {
                  onMessageSend(msgId, status, code);
                }
              }
            } else {
              if (onMessageSend != null) {
                onMessageSend(msgId, status, code);
              }
            }
          }
          break;

        case RCMethodCallBackKey.ReceiveMessage:
          {
            int count = 0;
            if (onMessageReceived != null) {
              count++;
              Map map = call.arguments;
              int left = map["left"];
              String messageString = map["message"];
              Message msg =
                  MessageFactory.instance.string2Message(messageString);
              onMessageReceived(msg, left);
            }
            if (onMessageReceivedWrapper != null) {
              count++;
              Map map = call.arguments;
              int left = map["left"];
              String messageString = map["message"];
              bool hasPackage = map["hasPackage"];
              bool offline = map["offline"];
              Message msg =
                  MessageFactory.instance.string2Message(messageString);
              onMessageReceivedWrapper(msg, left, hasPackage, offline);
            }
            if (count == 2) {
              developer.log(
                  "警告：同时实现了 onMessageReceived 和 onMessageReceivedWrapper 两个接收消息的回调，可能会出现重复接收消息或者重复刷新的问题，建议只实现其中一个！！！",
                  name: "RongIMClient");
            }
          }
          break;

        case RCMethodCallBackKey.JoinChatRoom:
          if (onJoinChatRoom != null) {
            Map map = call.arguments;
            String targetId = map["targetId"];
            int status = map["status"];
            onJoinChatRoom(targetId, status);
          }
          break;

        case RCMethodCallBackKey.QuitChatRoom:
          if (onQuitChatRoom != null) {
            Map map = call.arguments;
            String targetId = map["targetId"];
            int status = map["status"];
            onQuitChatRoom(targetId, status);
          }
          break;

        case RCMethodCallBackKey.ChatRoomKVDidSync:
          if (chatRoomKVDidSync != null) {
            Map map = call.arguments;
            String roomId = map["roomId"];
            chatRoomKVDidSync(roomId);
          }
          break;

        case RCMethodCallBackKey.ChatRoomKVDidUpdate:
          if (chatRoomKVDidUpdate != null) {
            Map map = call.arguments;
            String roomId = map["roomId"];
            Map entry = map["entry"];
            chatRoomKVDidUpdate(roomId, entry);
          }
          break;

        case RCMethodCallBackKey.ChatRoomKVDidRemove:
          if (chatRoomKVDidRemove != null) {
            Map map = call.arguments;
            String roomId = map["roomId"];
            Map entry = map["entry"];
            chatRoomKVDidRemove(roomId, entry);
          }
          break;

        case RCMethodCallBackKey.UploadMediaProgress:
          if (onUploadMediaProgress != null) {
            Map map = call.arguments;
            int messageId = map["messageId"];
            int progress = map["progress"];
            onUploadMediaProgress(messageId, progress);
          }
          break;

        case RCMethodCallBackKey.ConnectionStatusChange:
          if (onConnectionStatusChange != null) {
            Map map = call.arguments;
            int code = map["status"];
            int status = ConnectionStatusConvert.convert(code);
            onConnectionStatusChange(status);
          }
          break;

        case RCMethodCallBackKey.SendDataToFlutter:
          if (onDataReceived != null) {
            Map map = call.arguments;
            onDataReceived(map);
          }
          break;
        case RCMethodCallBackKey.ReceiveReadReceipt:
          if (onReceiveReadReceipt != null) {
            Map map = call.arguments;
            onReceiveReadReceipt(map);
          }
          break;

        case RCMethodCallBackKey.ReceiptRequest:
          if (onMessageReceiptRequest != null) {
            Map map = call.arguments;
            onMessageReceiptRequest(map);
          }
          break;
        case RCMethodCallBackKey.ReceiptResponse:
          if (onMessageReceiptResponse != null) {
            Map map = call.arguments;
            onMessageReceiptResponse(map);
          }
          break;
        case RCMethodCallBackKey.TypingStatusChanged:
          if (onTypingStatusChanged != null) {
            Map map = call.arguments;
            int conversationType = map["conversationType"];
            String targetId = map["targetId"];
            List list = map["typingStatus"];
            List statusList = new List();
            for (String statusStr in list) {
              TypingStatus status =
                  MessageFactory.instance.string2TypingStatus(statusStr);
              statusList.add(status);
            }
            onTypingStatusChanged(conversationType, targetId, statusList);
          }
          break;
        case RCMethodCallBackKey.DownloadMediaMessage:
          if (onDownloadMediaMessageResponse != null) {
            Map map = call.arguments;
            int code = map["code"];
            int progress = map["progress"];
            int messageId = map["messageId"];
            String messageString = map["message"];
            Message message =
                MessageFactory.instance.string2Message(messageString);
            onDownloadMediaMessageResponse(code, progress, messageId, message);
          }
          break;
        case RCMethodCallBackKey.RecallMessage:
          if (onRecallMessageReceived != null) {
            Map map = call.arguments;
            String messageString = map["message"];
            Message message =
                MessageFactory.instance.string2Message(messageString);
            onRecallMessageReceived(message);
          }
          break;
        case RCMethodCallBackKey.DestructMessage:
          if (onMessageDestructing != null) {
            Map map = call.arguments;
            String messageString = map["message"];
            int remainDuration = map["remainDuration"];
            Message message =
                MessageFactory.instance.string2Message(messageString);
            onMessageDestructing(message, remainDuration);
          }
          break;
        case RCMethodCallBackKey.MessageExpansionDidUpdate:
          if (messageExpansionDidUpdate != null) {
            Map map = call.arguments;
            Map expansionDic = map["expansionDic"];
            String messageString = map["message"];
            Message message =
                MessageFactory.instance.string2Message(messageString);
            messageExpansionDidUpdate(expansionDic, message);
          }
          break;
        case RCMethodCallBackKey.MessageExpansionDidRemove:
          if (messageExpansionDidRemove != null) {
            Map map = call.arguments;
            List keyArray = map["keyArray"];
            String messageString = map["message"];
            Message message =
                MessageFactory.instance.string2Message(messageString);
            messageExpansionDidRemove(keyArray, message);
          }
          break;
        case RCMethodCallBackKey.DatabaseOpened:
          if (onDatabaseOpened != null) {
            Map map = call.arguments;
            int status = map["status"];
            onDatabaseOpened(status);
          }
          break;
      }
      return;
    });
  }
}
