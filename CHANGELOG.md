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

