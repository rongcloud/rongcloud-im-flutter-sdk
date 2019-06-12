# 融云 IMKit flutter plugin

本文档讲解了如何使用 IMKit 的 flutter plugin

[flutter 官网](https://flutter.dev/)

[融云 iOS 文档集成](https://www.rongcloud.cn/docs/ios.html)

[融云 Android 文档集成](https://www.rongcloud.cn/docs/android.html)


# 前期准备

[融云官网](https://www.rongcloud.cn) 申请开发者账号

通过管理后台的 "基本信息"->"App Key" 获取 appkey

通过管理后台的 "IM 服务"—>"API 调用"->"用户服务"->"获取 Token"，通过用户 id 获取 IMToken

# 集成步骤

将 `main.dart` 中的 `RongAppKey`、`userId`、`RongIMToken` 分别替换成上一步申请的


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

## 进入会话列表

参数为会话列表需要展示的回话类型，默认为单/群聊

```
List conTypes = [RCConversationTypePrivate,RCConversationTypeGroup];
RongcloudImPlugin.pushToConversationList(conTypes);
```

##  进入会话页面

第一个参数为会话类型，支持单/群聊，第二个参数为会话 id

```
RongcloudImPlugin.pushToConversation(RCConversationTypePrivate,"asdf");
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
    if (MethodCallBackKeyFetchUserInfo == methodCall.method) {
      //开发者需要将用户信息传递给 SDK
      //如果本地没有该用户的信息，从 APP 服务获取后传递给 SDK
      //如果本地有该用户的信息，那么直接传递给 SDK
      String userId = methodCall.arguments;
      String name = "张三";
      String portraitUrl = "https://www.rongcloud.cn/pc/images/lizhi-icon.png";
      RongcloudImPlugin.refreshUserInfo(userId, name, portraitUrl);
    } 
  }
```