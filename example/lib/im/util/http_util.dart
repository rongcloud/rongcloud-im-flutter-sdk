import 'package:dio/dio.dart';
import 'package:connectivity/connectivity.dart';

class HttpUtil {
  static Dio dio = Dio();
  static void get(String url, Function callback,
      {Map params, Function errorCallback}) async {
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

  static void post(String url, Function callback,
      {Map params, Function errorCallback}) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      Map body = {"code": -1};
      callback(body);
    } else {
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

  // 下载
  static Future<Response> download(String url, String savePath,
      Function(int count, int total) progressCallback) async {
    return Dio().download(url, savePath, onReceiveProgress: progressCallback);
  }
}
