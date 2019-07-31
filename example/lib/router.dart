import 'package:flutter/material.dart';
import 'pages/conversation_page.dart';
import 'pages/home_page.dart';

final routes = {
  '/': (context) => HomePage(),
  '/conversation': (context, {arguments}) =>
      ConversationPage(arguments: arguments)
};

var onGenerateRoute = (RouteSettings settings) {
  // 统一处理
  final String name = settings.name;
  final Function pageContentBuilder = routes[name];
  if (pageContentBuilder != null) {
    if (settings.arguments != null) {
      final Route route = MaterialPageRoute(
          builder: (context) =>
              pageContentBuilder(context, arguments: settings.arguments));
      return route;
    } else {
      final Route route =
          MaterialPageRoute(builder: (context) => pageContentBuilder(context));
      return route;
    }
  }
};
