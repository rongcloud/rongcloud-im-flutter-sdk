import 'package:flutter/material.dart';
import 'im/pages/file_preview_page.dart';
import 'other/search_message_page.dart';

import 'im/pages/conversation_page.dart';
import 'im/pages/image_preview_page.dart';
import 'im/pages/sight/video_play_page.dart';
import 'im/pages/sight/video_record_page.dart';
import 'im/pages/webview_page.dart';

import 'other/home_page.dart';
import 'other/debug_page.dart';
import 'other/message_read_page.dart';
import 'other/chat_debug_page.dart';
import 'other/chatroom_debug_page.dart';
import 'other/select_conversation_page.dart';

final routes = {
  '/': (context) => HomePage(),
  '/conversation': (context, {arguments}) =>
      ConversationPage(arguments: arguments),
  '/image_preview': (context, {arguments}) =>
      ImagePreviewPage(message: arguments),
  '/debug': (context) => DebugPage(),
  '/video_record': (context, {arguments}) =>
      VideoRecordPage(arguments: arguments),
  '/video_play': (context, {arguments}) => VideoPlayPage(message: arguments),
  '/message_read_page': (context, {arguments}) =>
      MessageReadPage(message: arguments),
  '/file_preview': (context, {arguments}) =>
      FilePreviewPage(message: arguments),
  '/webview': (context, {arguments}) => WebViewPage(arguments: arguments),
  '/chat_debug': (context, {arguments}) => ChatDebugPage(arguments: arguments),
  '/chatroom_debug': (context, {arguments}) => ChatRoomDebugPage(),
  '/search_message': (context, {arguments}) =>
      SearchMessagePage(arguments: arguments),
  '/select_conversation_page': (context, {arguments}) =>
      SelectConversationPage(arguments: arguments),
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
