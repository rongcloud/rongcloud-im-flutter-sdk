import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class WebViewPage extends StatefulWidget {
  final Map? arguments;

  const WebViewPage({Key? key, this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WebViewPageState(arguments!["url"], arguments!["title"]);
}

class _WebViewPageState extends State<WebViewPage> {
  String pageName = "example.WebViewPage";
  final String? url;
  final String? title;

  _WebViewPageState(this.url, this.title);

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String correctUrl = _getCorrectLocalPath(this.url!);
    return Scaffold(
      appBar: AppBar(
        title: Text(title == null && title!.isEmpty ? this.url! : this.title!),
      ),
      body: Container(
        child: WebViewPlus(
          initialUrl: '',
          onWebViewCreated: (controller) {
            if (Platform.isIOS) {
              controller.loadUrl(this.url!);
            } else {
              controller.loadUrl(correctUrl);
            }
          },
          //JS执行模式 是否允许JS执行
          javascriptMode: JavascriptMode.unrestricted,
          javascriptChannels: <JavascriptChannel>[
            _getJavascriptChannel(context),
          ].toSet(),
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (url) {
            print('Page finished loading: $url');
          },
        ),
      ),
    );
    // return WebviewScaffold(
    //     url: correctUrl,
    //     appBar: AppBar(
    //       title: Text(title == null && title!.isEmpty ? this.url! : this.title!),
    //     ),
    //     withZoom: true,
    //     hidden: true,
    //     withLocalStorage: true,
    //     withJavascript: true,
    //     javascriptChannels: <JavascriptChannel>[
    //       _getJavascriptChannel(context),
    //     ].toSet(),
    //     initialChild: Center(
    //       child: CupertinoActivityIndicator(
    //         radius: 15.0,
    //         animating: true,
    //       ),
    //     ));
  }

  String _getCorrectLocalPath(String url) {
    // iOS Android  webView 加载本地路径的 html 文件需要在路径前面加 file://
    if (!url.toLowerCase().startsWith("http") && !url.startsWith("file://")) {
      return "file://$url";
    }
    return url;
  }

  JavascriptChannel _getJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'RCFlutterInterface',
        onMessageReceived: (JavascriptMessage message) {
          String jsonStr = message.message;
          handleInfo(jsonStr, context);
        });
  }

  void handleInfo(String jsonStr, BuildContext context) {
    if (jsonStr.isNotEmpty) {
      Map map = json.decode(jsonStr);
      String? type = map["type"];
      switch (type) {
        case FileMessage.objectName:
          developer.log("FileMessage click coming", name: pageName);
          String? fileName = map["fileName"];
          String? fileUrl = map["fileUrl"];
          String fileSize = map["fileSize"];
          FileMessage fileMessage = FileMessage.obtain("");
          fileMessage.mName = fileName;
          fileMessage.mMediaUrl = fileUrl;
          fileMessage.mSize = int.parse(fileSize);
          Message message = Message();
          message.content = fileMessage;
          _openFile(message, context);
          break;
        case CombineMessage.objectName:
          break;
        case "link":
          // String link = map["link"];
          // _openLink(link, context);
          break;
        case "phone":
          int? phoneNumber = map["phoneNum"];
          _openPhone(phoneNumber, context);
          break;
      }
    }
  }

  void _openFile(Message message, BuildContext context) {
    Navigator.pushNamed(context, "/file_preview", arguments: message);
  }

  void _openLink(String url, BuildContext context) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _openPhone(int? phone, BuildContext context) async {
    String url = 'tel:$phone';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
