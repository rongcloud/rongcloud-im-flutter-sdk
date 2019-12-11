## 1.0.3

* SDK:
* 1.新增单聊发送已读回执接口
* 2.新增单聊接收已读回执接口

## 1.0.2

* SDK:
* 1.增加会话列表分页获取的接口
* 2.修复 Flutter 时间戳在 Android 转换的问题

* Demo:
* 1.debug 增加会话列表分页获取接口的测试

## 1.0.1

* SDK:
* 1.修改 iOS 小视频超长返回的异常错误码
* 2.增加消息接收回调，通过回调告知远端是否还有数据包，消息是否离线

* Demo:
* 1.增加群组信息

## 1.0.0

* SDK:
* 1.解决 Android 时间戳转换错误的问题
* 2.解决 Flutter 中 getRemoteHistoryMessages 接口报错的问题


## 0.9.9

* SDK:
* 1.增加小视频消息

* Demo:
* 1.增加小视频消息录制，预览，发送，播放等功能

## 0.9.8

* SDK:
* 1.增加根据会话类型和 id 获取会话详情
* 2.增加获取前后历史消息接口

* Demo:
* 1.明确 iOS 自定义消息的流程
* 2.修复收到未识别的消息产生的崩溃
* 3.新增功能清单文档

## 0.9.7+2

* SDK:
* 1.修复设置会话免打扰状态接口的错误

## 0.9.7+1

* SDK:
* 1.修复获取会话免打扰状态的错误
* 2.增加消息免打扰的枚举值

## 0.9.7

* SDK:
* 1.增加自定义消息文档
* 2.修改代码错误：[Issue 27](https://github.com/rongcloud/rongcloud-im-flutter-sdk/issues/27) & [Issue 28](https://github.com/rongcloud/rongcloud-im-flutter-sdk/issues/28)

## 0.9.6

* SDK:
* 1.增加发送消息接口，消息可以发送 pushContent 和 pushData
* 2.iOS/Android 增加接口，可以向 Flutter 传递数据

## 0.9.5

* SDK:
* 1.增加错误码
* 2.解决发送图片，语音消息 extra 字段无效的问题
* 3.解决 Android 发送图片没有缩略图的问题
* 4.增加黑名单相关接口
* 5.更新文档

* Demo:
* 1.增加会话长按和消息长按功能
* 2.增加点击消息用户头像回调
* 3.实现本地通知功能
* 4.更新文档

## 0.9.4

* 解决 Android 时间戳 Long 强转为 Integer 报错 [详细参见](https://github.com/rongcloud/rongcloud-im-flutter-sdk/issues/13)


## 0.9.3

* 增加删除历史消息的接口：删除特定会话消息；批量删除消息
* 修复 Android getRemoteHistoryMessages 接口 recordTime 类型出错

## 0.9.2

* 解决 Android 非法 token 连接报非主线程执行的问题

## 0.9.1

* 获取会话列表接口改为按照回话类型获取
* 解决部分接口的 null exception

## 0.9.0

* 新增接口：`插入收到的消息`,`插入发出的消息`,`获取所有未读`,`获取单个会话未读`,`获取指定会话类型的未读`,`删除会话`,`连接状态回调`,`免打扰接口`,`置顶会话`

* 变更接口：将所有的 iOS、Android 的回调从 handler 中移除，改为通过 Function 返回 ，如接受消息的回调改为下面的方式，具体可以参见 `RongcloudImPlugin`

```
//消息接收回调
    RongcloudImPlugin.onMessageReceived = (Message msg,int left) {
      print("receive message messsageId:"+msg.messageId.toString()+" left:"+left.toString());
    };
```

## 0.0.22

* 解决 iOS 清空未读数失败的问题

## 0.0.21

* 解决 Android 接收消息在非 UI 线程通过 MethodChannel 返回数据导致的 `java.lang.RuntimeException: Methods marked with @UiThread must be executed on the main thread. Current thread: Binder:9497_1`

## 0.0.20

* 解决 iOS connect 成功返回 null 的问题

## 0.0.19

* 增加消息发送结果的错误码

## 0.0.18

* 新增语音消息

## 0.0.17

* 更新 readme 文档

## 0.0.16

* 更新 readme 文档；sendMessage 接口由返回 map，改为返回 Message

## 0.0.15

* 删除 style.xml 中问题注释，保证 android 编译

## 0.0.14

* 注掉 release 模式无法被找到的 theme

## 0.0.13

* 删除 android 配置文件依赖的错误 theme : release 模式找不到这个 theme

## 0.0.12

* dart 获取会话列表，消息列表的非法数据问题；增加 system 会话类型

## 0.0.11

* 增加清除特定回话未读数的接口；解决 android 获取空会话列表的空指针问题

## 0.0.10

* 图片消息解析；获取聊天室信息

## 0.0.9

* 更新 iOS 为 static framework

## 0.0.8

* 增加获取会话列表的接口；修复安卓获取消息的 conversationType 为 null 的问题

## 0.0.7

* demo 中增加自定义消息的处理；增加获取特定回话消息列表接口

## 0.0.6

* Android 临时去掉会话列表和聊天页面

## 0.0.5

* 增加图片消息，增加聊天室加入/退出接口

## 0.0.4

* 解决收 Android 消息异常的问题

## 0.0.3

* 增加消息收发接口

## 0.0.2

* 更新开发文档

## 0.0.1

* 实现 初始化、配置、连接 IM、进入会话列表、进入会话页面、刷新用户信息等功能

