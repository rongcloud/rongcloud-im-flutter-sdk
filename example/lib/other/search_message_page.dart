import 'package:flutter/material.dart';
import '../im/pages/item/widget_util.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class SearchMessagePage extends StatefulWidget {
  final Map arguments;
  SearchMessagePage({Key key, this.arguments}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _SearchMessagePageState(arguments: arguments);
  }
}

class _SearchMessagePageState extends State<SearchMessagePage> {
  Map arguments;
  int conversationType;
  String targetId;
  List messageList;

  _SearchMessagePageState({this.arguments});

  @override
  void initState() {
    super.initState();
    conversationType = arguments["coversationType"];
    targetId = arguments["targetId"];
    messageList = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("搜索会话历史消息"),
      ),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 12, right: 12, top: 20),
              height: 45,
              decoration: BoxDecoration(
                  border: new Border.all(color: Colors.black54, width: 0.5),
                  borderRadius: BorderRadius.circular(8)),
              child: TextField(
                  textAlign: TextAlign.center,
                  onSubmitted: _searchMessage,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: '请输入关键词'),
                  autofocus: true),
            ),
            messageList.length > 0
                ? Expanded(
                    flex: 1,
                    child: Container(
                        margin: EdgeInsets.only(top: 14),
                        child: ListView.separated(
                            controller: ScrollController(),
                            itemCount: messageList.length,
                            itemBuilder: (BuildContext context, int index) {
                              if (messageList.length != null &&
                                  messageList.length > 0) {
                                Message message = messageList[index];
                                return GestureDetector(
                                    child: Container(
                                  alignment: Alignment.center,
                                  child: Container(
                                      padding: EdgeInsets.all(6),
                                      child: Text(message.toString(),
                                          style: new TextStyle(
                                            fontSize: 15, //字体大���
                                          ))),
                                ));
                              } else {
                                return WidgetUtil.buildEmptyWidget();
                              }
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return Container(
                                color: Color(0xffC8C8C8),
                                height: 0.5,
                              );
                            })))
                : Text(
                    "无记录",
                    style: new TextStyle(
                        fontSize: 14, color: const Color(0xffff0000)),
                    textAlign: TextAlign.center,
                  )
          ],
        ),
      ),
    );
  }

  void _searchMessage(String keyWord) {
    if (keyWord == null || keyWord.isEmpty) {
      messageList.clear();
      _refreshUI();
    }
    RongIMClient.searchMessages(conversationType, targetId, keyWord, 50, 0,
        (List/*<Message>*/ msgList, int code) {
      if (code == 0 && msgList != null) {
        messageList = msgList;
        _refreshUI();
      }
    });
  }

  void _refreshUI() {
    setState(() {});
  }
}
