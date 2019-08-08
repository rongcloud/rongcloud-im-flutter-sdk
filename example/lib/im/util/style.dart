
class RCColor {
  static const GeneralBgColor = 0xffEFEFEF;//通用背景色

  //会话列表相关颜色
  static const ConListTitleColor = 0xff000000;
  static const ConListDigestColor = 0xff6C7B8B;
  static const ConListUnreadColor = 0xffCD3333;
  static const ConListUnreadTextColor = 0xffffffff;
  static const ConListTimeColor = 0xff6C7B8B;
  static const ConListItemBgColor = 0xffffffff;
  static const ConListBorderColor = 0xff6C7B8B;

  //会话页面，消息相关颜色
  static const MessageSendBgColor = 0xffC8E9FD;
  static const MessageReceiveBgColor = 0xffffffff;
  static const MessageTimeBgColor = 0xffC8C8C8;
  static const MessageNameBgColor = 0xff9B9B9B;
}

class RCFont {
  //会话列表相关字体大小
  static const double ConListTitleFont = 16;
  static const double ConListTimeFont = 12;
  static const double ConListUnreadFont = 8;
  static const double ConListDigestFont = 12;

  //会话页面，消息相关字体大小
  static const double MessageTextFont = 18;
  static const double MessageTimeFont = 12;
  static const double MessageNameFont = 14;

  //加号扩展栏
  static const double ExtIconSize = 40;
  static const double ExtTextFont = 13;
}

class RCLayout {
  //会话列表页面布局
  static const double ConListPortraitSize = 45;//会话列表头像大小
  static const double ConListItemHeight = 70;//会话列表 item 高度
  static const double ConListUnreadSize = 15;//会话列表未读数大小

  //消息页面布局
  static const double MessageTimeItemWidth = 80;
  static const double MessageTimeItemHeight = 22;

  //加号扩展栏
  static const double ExtIconLayoutSize = 50;
}

//长按 menu 的 Action
class RCLongPressAction {
  //如果用户点击了空白，会触发 UndefinedKey
  static const String UndefinedKey = "UndefinedKey";

  static const String DeleteConversationKey = "DeleteConversationKey";
  static const String DeleteConversationValue = "删除会话";

  static const String ClearUnreadKey = "ClearUnreadKey";
  static const String ClearUnreadValue = "清除未读";

  static const String CopyKey = "CopyKey";
  static const String CopyValue = "复制";

  static const String DeleteKey = "DeleteKey";
  static const String DeleteValue = "删除";
}