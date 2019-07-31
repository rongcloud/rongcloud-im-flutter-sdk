import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'item/conversation_item.dart';
import 'item/bottom_inputBar.dart';

class ConversationPage extends StatefulWidget {
  final Map arguments;
  ConversationPage({Key key, this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _ConversationPageState(arguments: this.arguments);
}

class _ConversationPageState extends State<ConversationPage> {
  Map arguments;
  int conversationType;
  String targetId;
  List msgList = new List();
  _ConversationPageState({this.arguments});

  @override
  void initState() {
    super.initState();
    conversationType = arguments["coversationType"];
    targetId = arguments["targetId"];
    onGetHistoryMessages();
  }

  onGetHistoryMessages() async {
    List msgs = await RongcloudImPlugin.getHistoryMessage(
        conversationType, targetId, 0, 10);
    print("get history message");
    setState(() {
      msgList = msgs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('与${targetId}的会话'),
      ),
      body: SizedBox(
          height: 900,
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemCount: msgList.length != null ? msgList.length : 0,
                  itemBuilder: (BuildContext context, int index) {
                    if (msgList.length != null && msgList.length > 0) {
                      return ConversationItem(msgList[index]);
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              BottomInputBar(),
            ],
          )),
    );
  }
}
