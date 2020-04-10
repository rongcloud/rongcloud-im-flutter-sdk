class RCColor {
  static const GeneralBgColor = 0xffEFEFEF; //通用背景色

  //会话列表相关颜色
  static const ConListTitleColor = 0xff000000;
  static const ConListDigestColor = 0xff6C7B8B;
  static const ConListUnreadColor = 0xffCD3333;
  static const ConListUnreadTextColor = 0xffffffff;
  static const ConListTimeColor = 0xff6C7B8B;
  static const ConListItemBgColor = 0xffffffff;
  static const ConListBorderColor = 0xff6C7B8B;
  static const ConListTopBgColor = 0xFFBBDEFB;
  static const ConCombineMsgContentColor = 0xFF9E9E9E;
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
  static const double MessageNotifiFont = 15;
  static const double MessageCombineTitleFont = 12;
  static const double MessageCombineContentFont = 10;

  //加号扩展栏
  static const double ExtIconSize = 40;
  static const double ExtTextFont = 13;
  static const double CommonPhrasesSize = 14;
}

class RCLayout {
  //会话列表页面布局
  static const double ConListPortraitSize = 45; //会话列表头像大小
  static const double ConListItemHeight = 70; //会话列表 item 高度
  static const double ConListUnreadSize = 15; //会话列表未读数大小

  //消息页面布局
  static const double MessageTimeItemWidth = 80;
  static const double MessageTimeItemHeight = 22;
  static const double MessageErrorHeight = 20;
  static const double RichMessageImageSize = 45;

  //小灰条消息宽高
  static const double MessageNotifiItemWidth = 140;
  static const double MessageNotifiItemHeight = 30;

  //加号扩展栏
  static const double ExtIconLayoutSize = 50;
  static const double ExtentionLayoutWidth = 180;
  static const double CommonPhrasesHeight = 36;

  //底部输入框
  static const double BottomIconLayoutSize = 32;
}

//长按 menu 的 Action
class RCLongPressAction {
  //如果用户点击了空白，会触发 UndefinedKey
  static const String UndefinedKey = "UndefinedKey";

  static const String DeleteConversationKey = "DeleteConversationKey";
  static const String DeleteConversationValue = "删除会话";

  static const String ClearUnreadKey = "ClearUnreadKey";
  static const String ClearUnreadValue = "清除未读";

  static const String SetConversationToTopKey = "SetConversationToTopKey";
  static const String SetConversationToTopValue = "设置置顶";
  static const String CancelConversationToTopValue = "取消置顶";

  static const String CopyKey = "CopyKey";
  static const String CopyValue = "复制";

  static const String DeleteKey = "DeleteKey";
  static const String DeleteValue = "删除";

  static const String RecallKey = "RecallMessage";
  static const String RecallValue = "撤回消息";

  static const String MutiSelectKey = "MutiSelectMessage";
  static const String MutiSelectValue = "多选";
}

class RCString {
  static const String BottomInputTextHint = "随便说点什么吧";
  static const String BottomTapSpeak = "按住 说话";
  static const String BottomCommonPhrases = "快捷回复";
  static const String ConRecallMessageSuccess = "成功撤回一条消息";
  static const String ConHaveMentioned = "[有人@我] ";
  static const String ConDraft = "[草稿] ";
  static const String ConNoIdentify = "";
  static const String ConTyping = "对方正在输入...";
  static const String ConSpeaking = "对方正在讲话...";
  static const String ExtPhoto = "相册";
  static const String ExtCamera = "相机";
  static const String ExtVideo = "视频";
  static const String ExtFolder = "文件";
  static const String ConCancel = "取消";
  static const String SelectConTitle = "选择会话";
  static const String ChatRecord = "聊天记录";
  static const String GroupChatRecord = "群聊的聊天记录";
}
