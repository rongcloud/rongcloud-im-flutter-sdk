import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';


class WebViewPage extends StatefulWidget {
  final String url;
  const WebViewPage({Key key, this.url}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
    _WebViewPageState(url);
}

class _WebViewPageState extends State<WebViewPage> {
  final String url;
  _WebViewPageState(this.url);

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: this.url,
      appBar: AppBar(
        title: Text(this.url),
      ),
      withZoom: true,
      withLocalStorage: true,
    );
  }
}