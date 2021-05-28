import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'http_util.dart';
import '../../main.dart';

import 'file.dart';
import 'style.dart';
import 'user_info_datesource.dart';
import 'dart:developer' as developer;

class CombineMessageUtils {
  String pageName = "example.CombineMessageUtils";
  String style = "";
  String uri;
  bool isSameDay;
  bool isSameYear;
  String portraitUri = "";

  static const String BASE64_PRE = "data:image/png;base64,";
  static const String NO_USER = "rong-none-user"; // 不显示用户头像标识
  static const String COMBINE_FILE_PATH = "combine";
  static const String COMBINE_IMAGE_BASE64 = "image64";
  static const String COMBINE_IMAGE_BASE64_IMAGE = ".png";
  static const String COMBINE_FILE_SUFFIX = ".html";
  static const String JSON_FILE_NAME = "combine.json"; // 模板文件
  Map<String, String> DATA = Map();
  //合并消息最多存储四条消息的文本信息
  static const int SUMMARY_MAX_SIZE = 4;

  // 消息类型
  static const String TAG_BASE_HEAD = "baseHead"; // html头
  static const String TAG_TIME = "time"; // 时间
  static const String TAG_TXT = "RC:TxtMsg"; // 文本
  static const String TAG_GIF = "RC:GIFMsg"; // 动图
  static const String TAG_VC = "RC:VcMsg"; // 语音
  static const String TAG_HQVC = "RC:HQVCMsg"; // 语音
  static const String TAG_CARD = "RC:CardMsg"; // 名片
  static const String TAG_STK = "RC:StkMsg"; // 动态表情
  static const String TAG_IMG_TEXT = "RC:ImgTextMsg"; // 图文
  static const String TAG_SIGHT = "RC:SightMsg"; // 小视频
  static const String TAG_IMG = "RC:ImgMsg"; // 图片
  static const String TAG_COMBINE = "RC:CombineMsg"; // 合并
  static const String TAG_MSG_COMBINE_BODY = "CombineMsgBody"; // 合并消息简略信息
  static const String TAG_FILE = "RC:FileMsg"; // 文件
  static const String TAG_LBS = "RC:LBSMsg"; // 位置
  static const String TAG_VCSUMMARY = "RC:VCSummary"; // 音视频通话
  static const String TAG_VST = "RC:VSTMsg"; // 音视频通话
  static const String TAG_RP = "RCJrmf:RpMsg"; // 红包
  static const String TAG_BASE_BOTTOM = "baseBottom"; // html底

  // 消息参数
  static const String MSG_BASE_HEAD_STYLE = "{%style%}"; // 用户自定义样式
  static const String MSG_TIME = "{%time%}"; // 时间
  static const String MSG_SHOW_USER =
      "{%showUser%}"; // 是否显示用户信息,不显示传rong-none-user.显示传'';
  static const String MSG_PORTRAIT = "{%portrait%}"; // 头像(url或base64)
  static const String MSG_USER_NAMEM = "{%userName%}"; // 用户名称
  static const String MSG_SEND_TIME = "{%sendTime%}"; // 发送时间
  static const String MSG_TEXT = "{%text%}"; // 各个消息的文本
  static const String MSG_IMAG_URL = "{%imgUrl%}"; // 图片链接(url或base64)
  static const String MSG_FILE_NAME = "{%fileName%}"; // 文件名称
  static const String MSG_SIZE = "{%size%}"; // 文件大小(xxxk/m/g)
  static const String MSG_FILE_SIZE = "{%fileSize%}"; // 文件大小(具体数值)
  static const String MSG_FILE_URL = "{%fileUrl%}"; // 文件链接
  static const String MSG_FILE_TYPE = "{%fileType%}"; // 文件类型
  static const String MSG_FILE_ICON = "{%fileIcon%}"; // 文件图标
  static const String MSG_TITLE = "{%title%}"; // 标题
  static const String MSG_COMBINE_BODY = "{%combineBody%}"; // 合并消息简略信息
  static const String MSG_FOOT = "{%foot%}"; // 合并消息底部显示文本
  static const String MSG_LOCATION_NAME = "{%locationName%}"; // 位置信息
  static const String MSG_LATITUDE = "{%latitude%}"; // 纬度
  static const String MSG_LONGITTUDE = "{%longitude%}"; // 经度

  Future<CombineMessage> combineMessage(List<Message> messageList) async {
    if (messageList == null || messageList.length == 0) {
      developer.log("sendMessageByCombine param is null", name: pageName);
      return null;
    }
    String uri = await CombineMessageUtils().getUrlFromMessageList(messageList);
    int conversationType = messageList[0].conversationType;
    CombineMessage combine = CombineMessage.obtain(uri);
    combine.conversationType = conversationType;
    if (RCConversationType.Group != conversationType) {
      combine.nameList = await getNameList(messageList);
    }
    combine.title = getTitle(combine);
    combine.summaryList = await getSummaryList(messageList);
    return combine;
  }

  // 是否为合并支持的消息类型
  static bool allowForward(String objectName) {
    List writeList = [
      TextMessage.objectName,
      VoiceMessage.objectName,
      ImageMessage.objectName,
      GifMessage.objectName,
      SightMessage.objectName,
      FileMessage.objectName,
      RichContentMessage.objectName,
      CombineMessage.objectName,
      RichContentMessage.objectName
    ];
    if (writeList.contains(objectName)) {
      return true;
    }
    return false;
  }

  // 为合并消息拼接网页文本,并生成文件.
  Future<String> getUrlFromMessageList(List<Message> messagesList) async {
    style = "";
    uri = null;
    isSameDay = isSameYear = false;
    Directory tempDir = await getTemporaryDirectory();
    String filePath = tempDir.path + "/" + COMBINE_FILE_PATH;
    String fileName =
        DateTime.now().millisecondsSinceEpoch.toString() + COMBINE_FILE_SUFFIX;
    String fileStr = await getHtmlFromMessageList(messagesList);
    File file = await FileUtil.writeStringToFile(filePath, fileName, fileStr);
    if (file.existsSync()) {
      return file.path;
    }
    return "";
  }

  // 拼接html文本
  Future<String> getHtmlFromMessageList(List<Message> messagesList) async {
    StringBuffer stringBuilder = new StringBuffer();
    String baseHead = await getHtmlBaseHead();
    stringBuilder.write(baseHead); // 加载html头部

    String htmlTime = await getHtmlTime(messagesList);
    stringBuilder.write(htmlTime); // 加载html头部时间
    for (Message msg in messagesList) {
      String htmlMessageContent =
          await getHtmlFromMessageContent(msg, msg.content);
      stringBuilder.write(htmlMessageContent);
    }
    String htmlBaseBottom = await getHtmlBaseBottom();
    stringBuilder.write(htmlBaseBottom); // 加载html底部
    return stringBuilder.toString();
  }

  Future<String> getHtmlBaseHead() async {
    String html = await getHtmlFromType(TAG_BASE_HEAD);
    return html.replaceAll(MSG_BASE_HEAD_STYLE, style);
  }

  Future<String> getHtmlFromType(String type) async {
    if (DATA == null || DATA.length == 0) {
      DATA = await getDATA();
    }

    if (DATA == null || DATA.length == 0) {
      return "";
    }

    if (TAG_HQVC == type) {
      type = TAG_VC;
    }

    if (TAG_VST == type) {
      type = TAG_VCSUMMARY;
    }

    String html = DATA[type];
    if (html == null || html.isEmpty) {
      developer.log("getHtmlFromType html is null, type: $type",
          name: pageName);
      return "";
    }
    return html;
  }

  Future<Map<String, String>> getDATA() async {
    String jsonStr = await getJson();
    DATA = setData(jsonStr);
    return DATA;
  }

  Future<String> getJson() async {
    String jsonStr = await DefaultAssetBundle.of(MyApp.getContext())
        .loadString("assets/combine.json");
    return jsonStr;
  }

  Map<String, String> setData(String str) {
    Map<String, String> jsonMap =
        Map<String, String>.from(json.decode(str.trim()));
    DATA = jsonMap;
    return DATA;
  }

  Future<String> getHtmlTime(List<Message> messagesList) async {
    int first = messagesList[0].sentTime;
    DateTime firstTime = DateTime.fromMillisecondsSinceEpoch(first);

    int last = messagesList[messagesList.length - 1].sentTime;
    DateTime lastTime = DateTime.fromMillisecondsSinceEpoch(last);

    isSameYear = firstTime.year == lastTime.year;
    isSameDay = isSameYear &&
        firstTime.month == lastTime.month &&
        firstTime.day == lastTime.day;

    String time;
    if (isSameDay) {
      time = "${firstTime.year}-${firstTime.month}-${firstTime.day}";
    } else {
      time =
          "${firstTime.year}-${firstTime.month}-${firstTime.day} - ${lastTime.year}-${lastTime.month}-${lastTime.day}";
    }
    String html = await getHtmlFromType(TAG_TIME);
    return html.replaceAll(MSG_TIME, time);
  }

  Future<String> getHtmlFromMessageContent(
      Message message, MessageContent content) async {
    String objectName = content.getObjectName();
    if (objectName == null || !objectName.startsWith("RC:")) {
      developer.log(
          "getHtmlFromMessageContent tag is UnKnown, content: $content",
          name: pageName);
      return "";
    }
    String type = objectName;
    String htmlFromType = await getHtmlFromType(type);
    String html = await setUserInfo(htmlFromType, message);
    switch (type) {
      case TAG_TXT: // 文本
        TextMessage text = content;
        html = html.replaceAll(MSG_TEXT, text.content);
        break;
      case TAG_IMG_TEXT: // 图文
      case TAG_VC: // 语音
      case TAG_HQVC: // 语音
        html = html.replaceAll(MSG_TEXT, getSpannable(content));
        break;
      case TAG_STK: // 表情
        html = html.replaceAll(MSG_TEXT, RCString.RCMessageContentSticker);
        break;
      case TAG_CARD: // 名片
        html = html.replaceAll(MSG_TEXT, RCString.RCMessageContentCard);
        break;
      case TAG_VST: // 音视频通话
      case TAG_VCSUMMARY: // 音视频通话
        html = html.replaceAll(MSG_TEXT, RCString.RCMessageContentVst);
        break;
      case TAG_RP: // 红包
        html = html.replaceAll(MSG_TEXT, RCString.RCMessageContentRp);
        break;
      case TAG_SIGHT: // 小视频
        SightMessage sight = content;
        html = html
            .replaceAll(MSG_FILE_NAME, sight.mName)
            .replaceAll(MSG_SIZE, FileUtil.formatFileSize(sight.mSize))
            .replaceAll(
                MSG_FILE_URL, sight.remoteUrl == null ? "" : sight.remoteUrl);
        break;
      case TAG_IMG: // 图片
        ImageMessage image = content;
        String base64 =
            await getBase64FromUrl(image.imageUri, message.messageId);
        html = html
            .replaceAll(
                MSG_FILE_URL, image.imageUri == null ? "" : image.imageUri)
            .replaceAll(MSG_IMAG_URL, base64);
        break;
      case TAG_GIF: // gif图片
        GifMessage gif = content;
        String gifBase64 =
            await getBase64FromUrl(gif.remoteUrl, message.messageId);
        html = html
            .replaceAll(
                MSG_FILE_URL, gif.remoteUrl == null ? "" : gif.remoteUrl)
            .replaceAll(MSG_IMAG_URL, gifBase64);
        break;
      case TAG_FILE: // 文件
        FileMessage file = content;
        html = html
            .replaceAll(MSG_FILE_NAME, file.mName)
            .replaceAll(MSG_SIZE, FileUtil.formatFileSize(file.mSize))
            .replaceAll(MSG_FILE_SIZE, "${file.mSize}")
            .replaceAll(
                MSG_FILE_URL, file.mMediaUrl == null ? "" : file.mMediaUrl)
            .replaceAll(
                MSG_FILE_TYPE,
                file.mType == null || file.mType.isEmpty
                    ? getFileType(file.mName)
                    : file.mType)
            .replaceAll(
                MSG_FILE_ICON, await getBase64FromLocalPath(file.mName));
        break;
      // case TAG_LBS: // 位置
      // LocationMessage location = (LocationMessage) content;
      // html = html.replace(MSG_LOCATION_NAME, location.getPoi())
      //         .replace(MSG_LATITUDE, String.valueOf(location.getLat()))
      //         .replace(MSG_LONGITTUDE, String.valueOf(location.getLng()));
      // break;
      case TAG_COMBINE: // 合并
        CombineMessage combine = content;
        StringBuffer summary = new StringBuffer();
        String combineBody = await getHtmlFromType(TAG_MSG_COMBINE_BODY);
        List<String> summarys = combine.summaryList;
        for (String sum in summarys) {
          summary.write(combineBody.replaceAll(MSG_TEXT, sum));
        }
        html = html
            .replaceAll(MSG_FILE_URL,
                combine.mMediaUrl == null ? "" : combine.mMediaUrl)
            .replaceAll(MSG_TITLE, getTitle(combine))
            .replaceAll(MSG_COMBINE_BODY, summary.toString())
            .replaceAll(MSG_FOOT, RCString.RCCombineChatHistory);
        break;
      default:
        developer.log("getHtmlFromMessageContent UnKnown type:$type",
            name: pageName);
    }
    return html;
  }

  String getFileType(String fileName) {
    int lastDotIndex = fileName.lastIndexOf(".");
    return fileName.substring(lastDotIndex + 1);
  }

  Future<String> setUserInfo(String str, Message msg) async {
    String portrait =
        (await UserInfoDataSource.getUserInfo(msg.senderUserId)).portraitUrl;
    if (portrait == null || portrait == portraitUri) {
      developer.log("getUserPortrait is same uri:$uri", name: pageName);
      portrait = "";
    } else {
      portraitUri = portrait;
    }
    portrait = await getBase64FromUrl(portrait, msg.messageId);
    String showUser = (portrait == null || portrait.isEmpty ? NO_USER : "");
    return str
        .replaceAll(MSG_PORTRAIT, portrait)
        .replaceAll(MSG_SHOW_USER, showUser)
        .replaceAll(MSG_USER_NAMEM,
            (await UserInfoDataSource.getUserInfo(msg.senderUserId)).name)
        .replaceAll(MSG_SEND_TIME, getSendTime(msg));
  }

  String getSendTime(Message msg) {
    int dateMillis = msg.sentTime;
    if (dateMillis <= 0) {
      return "";
    }
    String timeFromat;
    DateTime dateTime = DateTime.fromMicrosecondsSinceEpoch(dateMillis);
    if (isSameDay) {
      timeFromat = "";
    } else if (isSameYear) {
      timeFromat = "${dateTime.month}-${dateTime.day} ";
    } else {
      timeFromat = "${dateTime.year}-${dateTime.month}-${dateTime.day} ";
    }
    return timeFromat + "${dateTime.hour}:${dateTime.minute}";
  }

  String getSpannable(MessageContent content) {
    String spannable = content.conversationDigest();
    if (spannable == null) return "";
    return spannable;
  }

  Future<String> getBase64FromUrl(String uri, int messageId) async {
    if (uri == null || uri.isEmpty) return "";
    if (!uri.startsWith("http")) {
      File localFile = new File(uri);
      if (localFile.existsSync()) {
        return getBase64FromLocalPath(localFile.path);
      }
      return uri.toString();
    }
    Directory tempDir = await getTemporaryDirectory();
    String savePath = tempDir.path +
        "/" +
        COMBINE_FILE_PATH +
        "/" +
        COMBINE_IMAGE_BASE64 +
        "/${generateMd5(uri)}" +
        COMBINE_IMAGE_BASE64_IMAGE;
    File saveFile = File(savePath);
    String image64 = "";
    if (!saveFile.existsSync()) {
      image64 = uri;
      HttpUtil.download(uri, savePath, (int count, int total) async {
        // 下载完成
        if (count == total) {
          final bytes = await File(savePath).readAsBytes();
          image64 = BASE64_PRE + base64Encode(bytes);
        }
      });
    } else {
      final bytes = await File(savePath).readAsBytes();
      image64 = BASE64_PRE + base64Encode(bytes);
    }
    return image64;
  }

  //
  String generateMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }

  Future<String> getBase64FromLocalPath(String fileName) async {
    String filePath = FileUtil.fileTypeImagePath(fileName);
    var bytes;
    if (filePath.startsWith("assets")) {
      ByteData byteData = await rootBundle.load(filePath);
      bytes = Uint8List.view(byteData.buffer);
    } else {
      bytes = await File(filePath).readAsBytes();
    }
    String image64 = BASE64_PRE + base64Encode(bytes);
    return image64;
  }

  Future<String> getHtmlBaseBottom() {
    return getHtmlFromType(TAG_BASE_BOTTOM);
  }

  Future<List<String>> getNameList(List<Message> messages) async {
    List<String> names = [];
    for (Message msg in messages) {
      if (names.length == 2) return names;
      String name =
          (await UserInfoDataSource.getUserInfo(msg.senderUserId)).name;
      if (name != null && !names.contains(name)) {
        names.add(name);
      }
    }
    return names;
  }

  String getTitle(CombineMessage content) {
    String title = RCString.RCCombineChatHistory;

    if (RCConversationType.Group == content.conversationType) {
      title = RCString.RCCombineGroupChatHistory;
    } else if (RCConversationType.Private == content.conversationType) {
      List<String> nameList = content.nameList;
      if (nameList == null) return title;

      if (nameList.length == 1) {
        title = "${nameList[0]}的${RCString.RCCombineChatHistory}";
      } else if (nameList.length == 2) {
        title =
            "${nameList[0]}的${RCString.RCCombineChatHistory} 和 ${nameList[1]}的${RCString.RCCombineChatHistory}";
      }
    }

    return title;
  }

  Future<List<String>> getSummaryList(List<Message> messages) async {
    List<String> summaryList = [];
    int conversationType = messages[0].conversationType;
    for (int i = 0; i < messages.length && i < SUMMARY_MAX_SIZE; i++) {
      Message message = messages[i];
      MessageContent content = message.content;
      // UserInfo userInfo = RongUserInfoManager.getInstance().getUserInfo(message.getSenderUserId());
      String userName = "";
      if (RCConversationType.Group == conversationType) {
        userName =
            (await UserInfoDataSource.getUserInfo(message.senderUserId)).name;
      }

      String text;
      String objectName = content.getObjectName();
      if ("RC:CardMsg" == objectName) {
        text = RCString.RCMessageContentCard;
      } else if ("RC:StkMsg" == objectName) {
        text = RCString.RCMessageContentSticker;
      } else if ("RC:VCSummary" == objectName || "RC:VSTMsg" == objectName) {
        text = RCString.RCMessageContentVst;
      } else if ("RCJrmf:RpMsg" == objectName) {
        text = RCString.RCMessageContentRp;
      } else {
        text = content.conversationDigest();
      }

      summaryList.add(userName + " : " + text);
    }
    return summaryList;
  }

  void downLoadHtml(String url) async {
    if (url == null && url.isEmpty) {
      developer.log("downLoadHtml url is null", name: pageName);
      return;
    }
    Directory tempDir = await getTemporaryDirectory();
    String filePath = tempDir.path + "/" + COMBINE_FILE_PATH;
    Directory temp = Directory(filePath);
    if (!temp.existsSync()) {
      temp.createSync();
    }
    String fileName = generateMd5(url) + COMBINE_FILE_SUFFIX;
    HttpUtil.download(url, "$filePath/$fileName", (int count, int total) {});
  }

  Future<String> getLocalPathFormUrl(String url) async {
    Directory tempDir = await getTemporaryDirectory();
    String filePath = tempDir.path + "/" + COMBINE_FILE_PATH;
    String fileName = generateMd5(url) + COMBINE_FILE_SUFFIX;
    return "$filePath/$fileName";
  }
}
