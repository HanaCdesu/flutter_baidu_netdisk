import 'dart:async';
import 'package:dio/dio.dart';

import '../main.dart';

//网络请求
//此处非常粗糙，如需使用请另行写
class IroApi {
  static final IroApi _singleton = IroApi._init();
  late Dio _dio;

  BaseOptions baseOptions = new BaseOptions(
    connectTimeout: 1000 * 1000 * 1000,
    receiveTimeout: 1000 * 1000 * 1000,
    responseType: ResponseType.json,
  );

  IroApi._init() {
    _dio = Dio(baseOptions);
  }

  factory IroApi() {
    return _singleton;
  }

  Options? _options(method, Options? options) {
    if (options == null) return Options(headers: Iro.header);
    if (options.headers == null) options.headers = Iro.header;
    options.method = method;
    return options;
  }

  Future request<T>(
    String path, {
    String method = Method.get,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool debug = false,
    bool fullMode = false,
    Function(int, int)? progress,
  }) async {
    // print(path);
    Response response;
    if (method == Method.get) {
      response = await _dio.request(
        path,
        options: _options(method, options),
      );
    } else {
      var requestData;
      if (method == Method.post) {
        requestData = queryParameters;
      } else {
        requestData = FormData.fromMap(queryParameters!);
        print('POST - FORM$queryParameters');
      }
      response = await _dio.post(
        path,
        data: requestData,
        options: _options(method, options),
        onSendProgress: progress,
      );
    }
    if (response.statusCode == 200) {
      if (debug) print(response.data);
      try {
        if (response.data is Map) {
          // if (response.data['help'] != null) irotoast(response.data['help']);//用于提示用户一些信息
          // if (response.data['info'] != null) irotoast(response.data['info']);
          return response.data;
        }
        if (fullMode) return response;
        return response.data;
      } catch (e) {
        print('response error for: $e');
        return new Future.error(
          new DioError(
            response: response,
            type: DioErrorType.response,
            requestOptions: response.requestOptions,
          ),
        );
      }
    } else {
      print('网络错误？');
      new Future.error(
        new DioError(
          response: response,
          type: DioErrorType.response,
          requestOptions: response.requestOptions,
        ),
      );
    }
    return response.data;
  }
}

class Method {
  static const String get = "GET";
  static final String post = "POST";
  static final String form = 'FORMDATA';
}
