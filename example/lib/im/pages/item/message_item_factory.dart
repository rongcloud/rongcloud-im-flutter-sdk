import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import '../../util/combine_message_util.dart';
import '../../widget/cachImage/cached_image_widget.dart';
import '../../util/file.dart';
import '../../util/media_util.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../util/style.dart';
import 'dart:developer' as developer;

class MessageItemFactory extends StatelessWidget {
  final String pageName = "example.MessageItemFactory";
  final Message message;
  final bool needShow;
  const MessageItemFactory({Key key, this.message, this.needShow = true})
      : super(key: key);

  ///文本消息 item
  Widget textMessageItem(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    TextMessage msg = message.content;
    return Container(
      constraints: BoxConstraints(
        // 屏幕宽度减去头像宽度加上间距
        maxWidth: screenWidth - 150,
      ),
      padding: EdgeInsets.all(8),
      child: Text(
        needShow ? msg.content : "点击查看",
        style: TextStyle(fontSize: RCFont.MessageTextFont),
      ),
    );
  }

  ///图片消息 item
  ///优先读缩略图，否则读本地路径图，否则读网络图
  Widget imageMessageItem(BuildContext context) {
    ImageMessage msg = message.content;

    Widget widget;
    if (needShow) {
      if (msg.content != null && msg.content.length > 0) {
        Uint8List bytes = base64.decode(msg.content);
        widget = Image.memory(bytes);
        if (msg.localPath == null) {
          RongIMClient.downloadMediaMessage(message);
        }
      } else {
        if (msg.localPath != null) {
          String path = MediaUtil.instance.getCorrectedLocalPath(msg.localPath);
          File file = File(path);
          if (file != null && file.existsSync()) {
            widget = Image.file(file);
          } else {
            RongIMClient.downloadMediaMessage(message);
            // widget = Image.network(msg.imageUri);
            widget = CachedNetworkImage(
              progressIndicatorBuilder: (context, url, progress) =>
                  CircularProgressIndicator(
                value: progress.progress,
              ),
              imageUrl: msg.imageUri,
            );
          }
        } else {
          RongIMClient.downloadMediaMessage(message);
          // widget = Image.network(msg.imageUri);
          widget = CachedNetworkImage(
            progressIndicatorBuilder: (context, url, progress) =>
                CircularProgressIndicator(
              value: progress.progress,
            ),
            imageUrl: msg.imageUri,
          );
        }
      }
    } else {
      widget = Stack(
        children: <Widget>[
          Image.asset(
            message.messageDirection == RCMessageDirection.Send
                ? "assets/images/burnPicture.png"
                : "assets/images/burnPictureForm.png",
            width: 120,
            height: 126,
          ),
          Container(
            child: Text(
              "点击查看",
            ),
            height: 126,
            width: 120,
            alignment: Alignment.bottomCenter,
          )
        ],
      );
    }

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width - 150,
      ),
      child: widget,
    );
  }

  ///动图消息 item
  Widget gifMessageItem(BuildContext context) {
    GifMessage msg = message.content;
    Widget widget;
    if (needShow) {
      if (msg.localPath != null) {
        String path = MediaUtil.instance.getCorrectedLocalPath(msg.localPath);
        File file = File(path);
        if (file != null && file.existsSync()) {
          widget = Image.file(file);
        } else {
          // 没有 localPath 时下载该媒体消息，更新 localPath
          RongIMClient.downloadMediaMessage(message);
          widget = Image.network(
            msg.remoteUrl,
            fit: BoxFit.cover,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes
                      : null,
                ),
              );
            },
          );
        }
      } else if (msg.remoteUrl != null) {
        RongIMClient.downloadMediaMessage(message);
        widget = Image.network(
          msg.remoteUrl,
          fit: BoxFit.cover,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes
                    : null,
              ),
            );
          },
        );
      } else {
        developer.log("GifMessage localPath && remoteUrl is null",
            name: pageName);
      }

      double screenWidth = MediaQuery.of(context).size.width;
      if (msg.width != null &&
          msg.height != null &&
          msg.width > 0 &&
          msg.height > 0 &&
          msg.width > screenWidth / 3) {
        return Container(
          width: msg.width.toDouble() / 3,
          height: msg.height.toDouble() / 3,
          child: widget,
        );
      }
    } else {
      widget = Stack(
        children: <Widget>[
          Image.asset(
            message.messageDirection == RCMessageDirection.Send
                ? "assets/images/burnPicture.png"
                : "assets/images/burnPictureForm.png",
            width: 120,
            height: 126,
          ),
          Container(
            child: Text(
              "点击查看",
            ),
            height: 126,
            width: 120,
            alignment: Alignment.bottomCenter,
          )
        ],
      );
    }
    return widget;
  }

  ///语音消息 item
  Widget voiceMessageItem() {
    VoiceMessage msg = message.content;
    List<Widget> list = [];
    if (message.messageDirection == RCMessageDirection.Send) {
      list.add(SizedBox(
        width: 6,
      ));
      list.add(Text(
        msg.duration.toString() + "''",
        style: TextStyle(fontSize: RCFont.MessageTextFont),
      ));
      list.add(SizedBox(
        width: 20,
      ));
      list.add(Container(
        width: 20,
        height: 20,
        child: Image.asset("assets/images/voice_icon.png"),
      ));
    } else {
      list.add(SizedBox(
        width: 6,
      ));
      list.add(Container(
        width: 20,
        height: 20,
        child: Image.asset("assets/images/voice_icon_reverse.png"),
      ));
      list.add(SizedBox(
        width: 20,
      ));
      list.add(Text(msg.duration.toString() + "''"));
    }

    return Container(
      width: 80,
      height: 44,
      child: Row(children: list),
    );
  }

  //小视频消息 item
  Widget sightMessageItem() {
    SightMessage msg = message.content;

    if (needShow) {
      Widget previewW = Container(); //缩略图
      if (msg.content != null && msg.content.length > 0) {
        Uint8List bytes = base64.decode(msg.content);
        previewW = Image.memory(
          bytes,
          fit: BoxFit.fill,
        );
      }
      Widget bgWidget = Container(
        width: 100,
        height: 150,
        child: previewW,
      );
      Widget continerW = Container(
          width: 100,
          height: 150,
          child: Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            child: Image.asset(
              "assets/images/sight_message_icon.png",
              width: 50,
              height: 50,
            ),
          ));
      Widget timeW = Container(
        width: 100,
        height: 150,
        child: Container(
          width: 50,
          height: 20,
          alignment: Alignment.bottomLeft,
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 5,
              ),
              Text(
                "${msg.duration}'s",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
      return Stack(
        children: <Widget>[
          bgWidget,
          continerW,
          timeW,
        ],
      );
    } else {
      return Stack(
        children: <Widget>[
          Image.asset(
            message.messageDirection == RCMessageDirection.Send
                ? "assets/images/burnPicture.png"
                : "assets/images/burnPictureForm.png",
            width: 120,
            height: 126,
          ),
          Container(
            child: Text(
              "点击播放",
            ),
            height: 126,
            width: 120,
            alignment: Alignment.bottomCenter,
          )
        ],
      );
    }
  }

  Widget fileMessageItem(BuildContext context) {
    FileMessage fileMessage = message.content;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
        height: (screenWidth - 140) / 3,
        width: screenWidth - 140,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Image.asset(FileUtil.fileTypeImagePath(fileMessage.mName),
                width: 50, height: 50),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                width: screenWidth - 220,
                child: Text(
                  fileMessage.mName,
                  textWidthBasis: TextWidthBasis.parent,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style:
                      TextStyle(fontSize: 16, color: const Color(0xff000000)),
                ),
              ),
              Container(
                  margin: EdgeInsets.only(top: 8),
                  width: screenWidth - 220,
                  child: Text(
                    FileUtil.formatFileSize(fileMessage.mSize),
                    style:
                        TextStyle(fontSize: 12, color: const Color(0xff888888)),
                  ))
            ],
          )
        ]));
  }

  ///图文消息 item
  Widget richContentMessageItem(BuildContext context) {
    RichContentMessage msg = message.content;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth - 140,
      child: Column(children: <Widget>[
        Container(
          padding: EdgeInsets.all(10),
          child: Text(
            msg.title,
            style: new TextStyle(color: Colors.black, fontSize: 15),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                width: screenWidth - 200,
                child: Text(
                  msg.digest,
                  style: new TextStyle(color: Colors.black, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ),
              Container(
                width: RCLayout.RichMessageImageSize,
                height: RCLayout.RichMessageImageSize,
                child: msg.imageURL == null || msg.imageURL.isEmpty
                    ? Image.asset("assets/images/rich_content_msg_default.png")
                    : Image.network(msg.imageURL),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  // 合并消息 item
  Widget combineMessageItem(BuildContext context) {
    CombineMessage msg = message.content;
    if (msg.localPath != null && msg.localPath.isNotEmpty) {
      String path = MediaUtil.instance.getCorrectedLocalPath(msg.localPath);
      File file = File(path);
      if (file != null && file.existsSync()) {
      } else {
        // HttpUtil.download(url, savePath, progressCallback)
        CombineMessageUtils().downLoadHtml(msg.mMediaUrl);
      }
    } else {
      CombineMessageUtils().downLoadHtml(msg.mMediaUrl);
    }
    double screenWidth = MediaQuery.of(context).size.width;
    List<String> summaryList = msg.summaryList;
    String title = CombineMessageUtils().getTitle(msg);
    String summaryStr = "";
    if (summaryList != null) {
      for (int i = 0; i < summaryList.length && i < 4; i++) {
        if (i == 0) {
          summaryStr = summaryList[i];
        } else {
          summaryStr += "\n" + summaryList[i];
        }
      }
    }
    return Container(
        width: screenWidth - 200,
        child: Column(children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(10, 4, 10, 0),
            alignment: Alignment.centerLeft,
            child: Text(title,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: RCFont.MessageCombineTitleFont,
                    color: Colors.black)),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
            alignment: Alignment.centerLeft,
            child: Text(summaryStr,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: RCFont.MessageCombineContentFont,
                    color: Color(RCColor.ConCombineMsgContentColor))),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
            width: double.infinity,
            height: 1.0,
            color: Color(0xFFF3F3F3),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 6, 0, 10),
            alignment: Alignment.centerLeft,
            child: Text(RCString.ChatRecord,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: RCFont.MessageCombineContentFont,
                    color: Color(RCColor.ConCombineMsgContentColor))),
          ),
        ]));
  }

  // 引用消息 item
  Widget referenceMessageItem(BuildContext context) {
    ReferenceMessage msg = message.content;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
        width: screenWidth - 140,
        child: Column(children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
            alignment: Alignment.centerLeft,
            child: referenceWidget(msg),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 4, 10, 0),
            width: double.infinity,
            height: 1.0,
            color: Color(0xFFF3F3F3),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 4, 10, 10),
            alignment: Alignment.centerLeft,
            child: Text(msg.content,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: RCFont.MessageReferenceTitleFont,
                    color: Colors.black)),
          ),
        ]));
  }

  // 被引用的消息 UI
  Widget referenceWidget(ReferenceMessage msg) {
    if (msg.referMsg is TextMessage) {
      TextMessage textMessage = msg.referMsg;
      return Text("${msg.referMsgUserId}:\n\n${textMessage.content}",
          textAlign: TextAlign.left,
          style: TextStyle(
              fontSize: RCFont.MessageReferenceContentFont,
              color: Color(RCColor.ConReferenceMsgContentColor)));
    } else if (msg.referMsg is ImageMessage) {
      ImageMessage imageMessage = msg.referMsg;
      Widget widget;
      if (imageMessage.content != null && imageMessage.content.length > 0) {
        Uint8List bytes = base64.decode(imageMessage.content);
        widget = Image.memory(bytes);
      } else {
        if (imageMessage.localPath != null) {
          String path =
              MediaUtil.instance.getCorrectedLocalPath(imageMessage.localPath);
          File file = File(path);
          if (file != null && file.existsSync()) {
            widget = Image.file(file);
          } else {
            // widget = Image.network(msg.imageUri);
            widget = CachedNetworkImage(
              progressIndicatorBuilder: (context, url, progress) =>
                  CircularProgressIndicator(
                value: progress.progress,
              ),
              imageUrl: imageMessage.imageUri,
            );
          }
        } else {
          // widget = Image.network(msg.imageUri);
          widget = CachedNetworkImage(
            progressIndicatorBuilder: (context, url, progress) =>
                CircularProgressIndicator(
              value: progress.progress,
            ),
            imageUrl: imageMessage.imageUri,
          );
        }
      }
      return widget;
    } else if (msg.referMsg is FileMessage) {
      FileMessage fileMessage = msg.referMsg;
      return Text("${msg.referMsgUserId}:\n\n[文件] ${fileMessage.mName}",
          textAlign: TextAlign.left,
          style: TextStyle(
              fontSize: RCFont.MessageReferenceContentFont,
              color: Color(RCColor.ConReferenceMsgContentColor)));
    } else if (msg.referMsg is RichContentMessage) {
      RichContentMessage richContentMessage = msg.referMsg;
      return Text("${msg.referMsgUserId}:\n\n[图文] ${richContentMessage.title}",
          textAlign: TextAlign.left,
          style: TextStyle(
              fontSize: RCFont.MessageReferenceContentFont,
              color: Color(RCColor.ConReferenceMsgContentColor)));
    }
  }

  Widget messageItem(BuildContext context) {
    if (message.content is TextMessage) {
      return textMessageItem(context);
    } else if (message.content is ImageMessage) {
      return imageMessageItem(context);
    } else if (message.content is VoiceMessage) {
      return voiceMessageItem();
    } else if (message.content is SightMessage) {
      return sightMessageItem();
    } else if (message.content is FileMessage) {
      return fileMessageItem(context);
    } else if (message.content is RichContentMessage) {
      return richContentMessageItem(context);
    } else if (message.content is GifMessage) {
      return gifMessageItem(context);
    } else if (message.content is CombineMessage) {
      return combineMessageItem(context);
    } else if (message.content is ReferenceMessage) {
      return referenceMessageItem(context);
    } else if (message.content is LocationMessage) {
      return Text("位置消息 " + message.objectName);
    } else if (message.content is GroupNotificationMessage) {
      GroupNotificationMessage groupNotificationMessage = message.content;
      return Text(
          "群通知消息 ${groupNotificationMessage.operatorUserId} ${groupNotificationMessage.operation} ${groupNotificationMessage.data}");
    } else {
      return Text("无法识别消息 " + message.objectName);
    }
  }

  Color _getMessageWidgetBGColor(int messageDirection) {
    Color color = Color(RCColor.MessageSendBgColor);
    if (message.messageDirection == RCMessageDirection.Receive) {
      color = Color(RCColor.MessageReceiveBgColor);
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      color: _getMessageWidgetBGColor(message.messageDirection),
      child: messageItem(context),
    );
  }
}
