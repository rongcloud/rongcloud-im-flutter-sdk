参考文档：https://docs.rongcloud.cn/v4/views/im/ui/guide/notify/push/android.html#

> 如上为融云 Android 推送接入文档，按照如上步骤针对 flutter 的 Android 端配置即可，原理类似,目前 Android 端支持 华为，小米，魅族，oppo，vivo，FCM 的推送

步骤：
1.初始化前进行 PushConfig 的配置
```dart
prefix.PushConfig pushConfig = prefix.PushConfig();
pushConfig.enableHWPush = true;
pushConfig.enableVivoPush = true;

小米推送，请填入自己申请的 appkey 和 id
pushConfig.miAppKey = "1111147338625";
pushConfig.miAppId = "2222203761517473625";

oppo 推送，请填入自己申请的 appkey 和 secret
pushConfig.oppoAppKey = "11111146d261446dbd3c94bb04d322de";
pushConfig.oppoAppSecret = "2222223d5ce1414ea4b6d75c880a3031";
    
魅族推送 请填入自己申请的 appkey 和 id
pushConfig.mzAppKey = "11111802ac4bd5843d694517307896";
pushConfig.mzAppId = "222288";
pushConfig.enableFCM = true;

prefix.RongIMClient.setAndroidPushConfig(pushConfig);
```
2.在 flutter 的 Android 端进行 jar 包和 aar 和 xml 文件中进行必要的配置
> 具体请参考最上层的 Android 端推送配置文档和 sdk 的 example 层的代码