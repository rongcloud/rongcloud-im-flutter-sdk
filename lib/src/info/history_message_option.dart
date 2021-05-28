import 'package:rongcloud_im_plugin/src/common_define.dart';

class HistoryMessageOption {
  int count;
  int recordTime;
  int order; //0 降序， 1 升序
  HistoryMessageOption(this.count, this.recordTime, this.order);
}
