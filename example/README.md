# 融云 IM Flutter Plugin Demo

![](https://raw.githubusercontent.com/rongcloud/imkit-flutter-quickstart/master/screenshot1.png)
![](https://raw.githubusercontent.com/rongcloud/imkit-flutter-quickstart/master/screenshot2.png)

## iOS 初次运行

初次安装需要从 pod 下载 IMLib 的 iOS SDK，要花费较长的时间，建议手动更新一下

1. Podfile 目录执行 `pod repo update` 命令
2. Podfile 目录执行 `pod update` 命令

### 常见问题

1. `audio_recorder` does not specify a Swift version and none of the targets (`Runner`) integrating it have the `SWIFT_VERSION` attribute set. Please contact the author or set the `SWIFT_VERSION` attribute in at least one of the targets that integrate this pod.

 Podfile 上添加 `use_frameworks!` 参数
 
 Xcode 打开，选择 TARGETS -> Runnder -> Build Settings -> Levels 右边加号 -> Add User-Defined Setting -> 添加字段 `SWIFT_VERSION`，写上 Swift 版本，如 4.0

## Android 初次运行

Android 依赖不同的 Flutter Plugin 可能会出现不同版本的 Gradle 导致编译不通过，可以按需做如下处理

1. `将所有的 build.gradle 的 gradle 版本统一`，例如统一改为 3.4.1
2. `将 gradle-wrapper.properties 的 distributionUrl `版本改为和上一步统一，如上一步是 3.4.1 ，那么此处应该改为 5.1.1
3. `编译后查看是否存在 AndroidX 的冲突`，如果存在 AndroidX 冲突，那么在 `gradle.properties` 增加如下配置

```
android.useAndroidX=true
android.enableJetifier=true
```

> demo 为了考虑 CPU 架构兼容性问题，在 demo 的 `build.gradle` 中配置的 ndk 仅支持 `armeabi-v7a`

```
ndk {
    abiFilters "armeabi-v7a"
}
```