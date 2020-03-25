import 'package:dio/dio.dart';

class HttpUtil {
  static Dio dio = Dio();
  static void get(String url, Function callback, {Map params, Function errorCallback}) async {
    if (params != null && params.isNotEmpty) {
      StringBuffer buffer = new StringBuffer("?");
      params.forEach((key, value) {
        buffer.write("$key" + "=" + "$value" + "&");
      });
      String paramStr = buffer.toString();
      paramStr = paramStr.substring(0, paramStr.length - 1);
      url += paramStr;
    }
    Response response;
    try {
      response = await dio.get(url);
      print(response);
      if (callback != null) {
        callback(response.data);
        }
    } catch (e) {
      print(e.toString());
      if (errorCallback != null) {
        errorCallback(e);
      }
    }
  }

  static void post(String url, Function callback, {Map params, Function errorCallback}) async {
    // try {
      Response response;
      response = await Dio().post(url, data: params);
      print(response);
      if (callback != null) {
        callback(response.data);
      }
    // } catch (e) {
    //   print(e);
    //   if (errorCallback != null) {
    //     errorCallback(e);
    //   }
    // }
  }
}