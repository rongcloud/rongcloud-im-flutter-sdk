import 'bloc_provider.dart';
import 'package:rxdart/subjects.dart';

class MessageBloc extends BlocBase {
  MessageInfoWrapState warpInfo;
  // 列表数据
  BehaviorSubject<MessageInfoWrapState> _listDataController =
      BehaviorSubject<MessageInfoWrapState>(sync: true);
  Sink get inListData => _listDataController.sink;
  Stream get outListData => _listDataController.stream;

  @override
  void dispose() {
    _listDataController.close();
  }

  void updateMessageList(List messageList) {
    warpInfo = MessageInfoWrapState(messageList: messageList);
    inListData.add(warpInfo);
  }
}

class MessageInfoWrapState {
  MessageInfoWrapState({this.messageList});
  List messageList;
}
