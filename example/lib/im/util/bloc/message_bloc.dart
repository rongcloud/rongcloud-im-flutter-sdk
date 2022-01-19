import 'package:rxdart/subjects.dart';

import 'bloc_provider.dart';

class MessageBloc extends BlocBase {
  MessageInfoWrapState? warpInfo;


  // 列表数据
  BehaviorSubject<MessageInfoWrapState?> _listDataController = BehaviorSubject<MessageInfoWrapState?>(sync: true);
  bool isDispose = false;
  Sink get inListData => _listDataController.sink;

  Stream get outListData => _listDataController.stream;

  @override
  void dispose() {
    print("MessageBloc 销毁了");
    _listDataController.close();
    isDispose = true;
  }

  void updateMessageList(List messageList) {
    if (isDispose) return;
    warpInfo = MessageInfoWrapState(messageList: messageList);
    inListData.add(warpInfo);
  }
}

class MessageInfoWrapState {
  MessageInfoWrapState({this.messageList});

  List? messageList;
}
