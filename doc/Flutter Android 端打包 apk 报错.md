# Flutter Android 端打包 apk 报错
## 报错信息:

```
java.lang.UnsatisfiedLinkError: JNI_ERR returned from JNI_OnLoad in "/data/user/0/com.flipped.wx/app_lib/libRongIMLib.so"
at java.lang.Runtime.load0(Runtime.java:938)
at java.lang.System.load(System.java:1631)
at io.rong.imlib.y0.e.c(Unknown Source:0)
at io.rong.imlib.y0.d.c(Unknown Source:169)
at io.rong.imlib.y0.d.a(Unknown Source:21)
at io.rong.imlib.y0.c.a(Unknown Source:5)
at io.rong.imlib.y0.c.a(Unknown Source:1)
at io.rong.imlib.NativeObject.<init>(Unknown Source:5)
at io.rong.imlib.k0.a(Unknown Source:10)
at io.rong.imlib.g0.<init>(Unknown Source:15)
at io.rong.imlib.ipc.RongService.onBind(Unknown Source:40)
at android.app.ActivityThread.handleBindService(ActivityThread.java:4097)
at android.app.ActivityThread.access$1900(ActivityThread.java:231)
at android.app.ActivityThread$H.handleMessage(ActivityThread.java:1973)
at android.os.Handler.dispatchMessage(Handler.java:107)
at android.os.Looper.loop(Looper.java:214)
at android.app.ActivityThread.main(ActivityThread.java:7682)
```

## 引发原因：

### 1.缺少对应 so

检查方式是将 apk 解压，查看 `lib` 目录中对应的 so 文件是否完整，至少需要有一下四个 so 文件

```
libapp.so           //Flutter 项目被编译成的 so
libflutter.so       //Flutter SDK 被编译成的 so
libRongIMLib.so     //融云 IMLib 的 so
libsqlite.so        //融云 IMLib 依赖的 sqlite so
```


必须得保证四个 so 文件都有，才能正常运行

`解决方案如下`

如果出现 so 文件缺失的情况，那么请参照 `example/android/app/build.gradle` 中下面的配置

```
ndk {
    abiFilters "armeabi-v7a"
}
```

### 2.混淆打包

混淆打包也可能会发生类似的问题。 

Flutter 在执行 `flutter build apk` 时会自动对代码进行混淆编译。

[详细参见官网链接](https://flutter.dev/docs/deployment/android#r8)

`解决方案如下`

以下方案选择一种处理即可

#### 1.配置 build.gradle 手动关闭混淆开关

```
android {
        buildTypes {
            release {
                // Enables code shrinking, obfuscation, and optimization for only
                // your project's release build type.
                minifyEnabled false

                // Enables resource shrinking, which is performed by the
                // Android Gradle plugin.
                shrinkResources false
            }
        }
        ...
    }
```
#### 2.使用 Android Studio 进行 apk 打包

#### 3.使用下面命令进行打包

`flutter build apk --no-shrink`