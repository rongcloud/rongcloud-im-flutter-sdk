import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';

enum HttpErrorCode {
  Ok,
  Error,
}

class HttpError {
  HttpErrorCode code;
  String message;

  HttpError(this.code, this.message);
}

class Http {
  static void registerCer(String cert) {
    _certs.add(cert);
  }

  static void init([
    bool enableCheckCert = false,
    String? proxy,
  ]) {
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      // ssl
      if (enableCheckCert)
        client.badCertificateCallback = (
          X509Certificate cert,
          String host,
          int port,
        ) {
          for (String _cert in _certs) if (cert.pem == _cert) return true;
          return false;
        };
      // proxy
      if (proxy?.isNotEmpty == true)
        client.findProxy = (uri) {
          return 'PROXY $proxy'; // localhost:8888
        };
    };
  }

  static Future<void> get(
    String url,
    Map<String, String>? params,
    void onSuccess(HttpError error, dynamic data),
    void onError(HttpError error),
    CancelToken tag,
  ) async {
    Options options = Options(
      contentType: Headers.jsonContentType,
    );
    try {
      Response response = await _dio.get(
        url,
        queryParameters: params,
        options: options,
        cancelToken: tag,
      );
      if (response.statusCode == 200) {
        onSuccess(HttpError(HttpErrorCode.Error, ""), response.data);
      } else {
        onError(HttpError(HttpErrorCode.Error, ""));
      }
    } on DioError catch (e) {
      print(e);
      onError(HttpError(HttpErrorCode.Error, ""));
    }
  }

  static Future<void> post(
    String url,
    Map<String, String>? params,
    void onSuccess(HttpError error, dynamic data),
    void onError(HttpError error),
    CancelToken tag,
  ) async {
    Options options = Options(
      contentType: Headers.jsonContentType,
    );
    try {
      Response response = await _dio.post(
        url,
        options: options,
        cancelToken: tag,
        data: params,
      );
      if (response.statusCode == 200) {
        onSuccess(HttpError(HttpErrorCode.Error, ""), response.data);
      } else {
        onError(HttpError(HttpErrorCode.Error, ""));
      }
    } on DioError catch (e) {
      print(e);
      onError(HttpError(HttpErrorCode.Error, ""));
    }
  }

  static Future<void> delete(
    String url,
    Map<String, String>? params,
    void onSuccess(HttpError error, dynamic data),
    void onError(HttpError error),
    CancelToken tag,
  ) async {
    Options options = Options(
      contentType: Headers.jsonContentType,
    );
    try {
      Response response = await _dio.delete(
        url,
        queryParameters: params,
        options: options,
        cancelToken: tag,
      );
      if (response.statusCode == 200) {
        onSuccess(HttpError(HttpErrorCode.Error, ""), response.data);
      } else {
        onError(HttpError(HttpErrorCode.Error, ""));
      }
    } on DioError catch (e) {
      print(e);
      onError(HttpError(HttpErrorCode.Error, ""));
    }
  }

  static Dio _dio = Dio();
  static List<String> _certs = [];
}
