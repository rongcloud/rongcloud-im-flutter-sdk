import 'package:flutter/material.dart';

import 'im/pages/conversation_page.dart';
import 'im/pages/image_preview_page.dart';
import 'im/pages/sight/video_play_page.dart';
import 'im/pages/sight/video_record_page.dart';

import 'other/home_page.dart';
import 'other/debug_page.dart';

final routes = {
  '/': (context) => HomePage(),
  '/conversation': (context, {arguments}) =>
      ConversationPage(arguments: arguments),
  '/image_preview':(context, {arguments}) =>
      ImagePreviewPage(message: arguments),
  '/debug':(context) =>
      DebugPage(),
  '/video_record':(context, {arguments}) =>
        VideoRecordPage(arguments: arguments),
  '/video_play':(context, {arguments}) =>
      VideoPlayPage(message: arguments),
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
