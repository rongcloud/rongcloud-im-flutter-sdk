import 'package:rongcloud_im_plugin/src/common_define.dart';

class HistoryMessageOption {
  int count;
  int recordTime;
  int order; //0 升序， 1 降序。
  HistoryMessageOption(this.count, this.recordTime, this.order);
}
