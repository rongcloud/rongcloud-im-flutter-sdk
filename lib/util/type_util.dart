class TypeUtil {
  /// 检测是否是空字符串
  static bool isEmptyString(String s) {
    if (s == null || s.length <= 0) {
      return true;
    }
    return false;
  }

  /// 返回非法的 int 值，将负数转为正数
  static int getProperInt(int value) {
    if (value <= 0) {
      value = 0;
    }
    return value;
  }
}
