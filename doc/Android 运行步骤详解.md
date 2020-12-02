该项目本质上是一个 Flutter Plugin 项目

# 初次运行

## 下载 Flutter 依赖包

终端进入项目根目录，执行 `flutter packages get`，等待处理完毕即可

## 下载 Android 依赖包

使用 Android Studio 打开 `example/android` 目录，Android Studio 自动处理完毕即可


# 后续运行

终端进入 `example` 

## 当前只有一个设备连接

当前目录执行 `flutter run` 命令，等待一会儿，就会在该设备上运行 Android 项目


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
flutter run -d 4d006b083bc13049
`


# 常见问题
## 使用 IM 插件可能出现的编译不通过问题

Android 依赖不同的 Flutter Plugin 可能会出现不同版本的 Gradle 导致编译不通过，可以按需做如下处理

1. `将所有的 build.gradle 的 gradle 版本统一`，例如统一改为 3.4.1
2. `将 gradle-wrapper.properties 的 distributionUrl `版本改为和上一步统一，如上一步是 3.4.1 ，那么此处应该改为 5.1.1
3. `编译后查看是否存在 AndroidX 的冲突`，如果存在 AndroidX 冲突，那么在 `gradle.properties` 增加如下配置

```
android.useAndroidX=true
android.enableJetifier=true
```

详细可以参考 `example/android` 目录的工程配置