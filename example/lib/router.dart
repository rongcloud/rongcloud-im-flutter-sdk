import 'package:flutter/material.dart';
import 'pages/conversation_page.dart';

class Routers {
  static Map<String, WidgetBuilder> routerMap(context) {
    print("所有的路由在 router.dart 中处理");
    return {
      '/conversation': (context) => ConversationPage()
    };
  }
}