import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'item/conversation_item.dart';
import 'item/bottom_inputBar.dart';

class ConversationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _ConversationPageState();
  }
}

class _ConversationPageState extends State<ConversationPage> {
  int conversationType;
  String targetId;
  List msgList = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('0000000');
    onGetHistoryMessages();
  }

  onGetHistoryMessages() async {
    // Map arg = ModalRoute.of(context).settings.arguments;
    // conversationType = arg["coversationType"];
    // targetId = arg["targetId"];
    List msgs = await RongcloudImPlugin.getHistoryMessage(
        RCConversationType.Private, '2002', 0, 10);
    print("get history message");

    setState(() {
      msgList = msgs;
    });
  }

  @override
  Widget build(BuildContext context) {
    Map arg = ModalRoute.of(context).settings.arguments;
    conversationType = arg["coversationType"];
    targetId = arg["targetId"];
    print("push to conversation page: conversationType " +
        conversationType.toString() +
        "  targetId " +
        targetId);

    // TODO: implement build
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
