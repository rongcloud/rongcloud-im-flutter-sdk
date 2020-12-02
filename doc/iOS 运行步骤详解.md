该项目本质上是一个 Flutter Plugin 项目

# 初次运行

## 下载 Flutter 依赖包

终端进入项目根目录，执行 `flutter packages get`，等待处理完毕即可

## 下载 iOS 依赖包

终端进入 `example/ios` 目录，该目录下存在 `Podfile` 文件

依次执行下面的命令，更新 pod 本地仓库，并从 pod 下载最新版 IMLib SDK

```
$ pod repo update
$ pod update
```

执行完毕之后，在 `example/ios` 目录生成 `Runner.xcworkspace` ，Xcode 打开该文件即可运行完整的 iOS 项目


# 后续运行

终端进入 `example` 

## 当前只有一个设备连接

当前目录执行 `flutter run` 命令，等待一会儿，就会在该设备上运行 iOS 项目


## 当前有多个设备连接

当前目录执行 `flutter devices` 命令查看已连接的设备信息，如下，第一列为设备名称，第二列为设备 id

```
➜  example git:(dev) ✗ flutter devices
2 connected devices:

GT I9500  • 4d006b083bc13049                     • android-arm • Android 4.4.2 (API 19)
iPhone Xʀ • 8088549C-F46A-4BA5-81C8-A33EDB680EBE • ios         • com.apple.CoreSimulator.SimRuntime.iOS-12-4 (simulator)
```

然后运行使用 `-d` 参数指定设备 id，运行特定的设备，如

`
flutter run -d 8088549C-F46A-4BA5-81C8-A33EDB680EBE
`

# 常见问题
## 使用 audio_recorder 等 Swift 插件出现编译不通过问题

`audio_recorder` does not specify a Swift version and none of the targets (`Runner`) integrating it have the `SWIFT_VERSION` attribute set. Please contact the author or set the `SWIFT_VERSION` attribute in at least one of the targets that integrate this pod.

1 Podfile 上添加 `use_frameworks!` 参数

2 Xcode 打开，选择 TARGETS -> Runnder -> Build Settings -> Levels 右边加号 -> Add User-Defined Setting -> 添加字段 `SWIFT_VERSION`，写上 Swift 版本，如 4.0

详细可以参考 `example/ios` 目录的工程配置和 Podfile 文件

## 使用 flutter_sound 报 Audio Player, player is not set, null

原因是语音资源没有被下载成功，查看一下播放的语音资源路径是否是 http 开头，iOS 自 9.0 开始默认只支持 https 请求，所以导致了 http 的语音资源无法被下载，也就无法正常播放，可以通过下面的设置，关闭 ATS ，要求 APP 处理 http 请求(或者可以自行百度 `iOS ATS` 寻找解决方案)

```
使用源码方法打开 Info.plist 文件中添加

<key>NSAppTransportSecurity</key>

<dict>

	<key>NSAllowsArbitraryLoads</key>
	
	<true/>

</dict>
```