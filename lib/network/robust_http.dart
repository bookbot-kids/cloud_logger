import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:logging_service/network/exceptions.dart';

class HTTP {
  int httpRetries = 3;
  Dio dio;

  /// Configure HTTP with defaults from a Map
  HTTP(String baseUrl, [Map<String, dynamic> options = const {}]) {
    httpRetries = options["httpRetries"] ?? httpRetries;

    final baseOptions = BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: options["connectTimeout"] ?? 60000,
        receiveTimeout: options["receiveTimeout"] ?? 60000,
        headers: options["headers"] ?? {});

    dio = new Dio(baseOptions);
  }

  /// Does a http GET (with optional overrides).
  /// You can pass the full url, or the path after the baseUrl.
  /// Will timeout, check connectivity and retry until there is a response.
  /// Will handle most success or failure cases and will respond with either data or exception.
  Future<dynamic> get(String url,
      {Map<String, dynamic> parameters, bool fullResponse = false}) async {
    return request("GET", url,
        parameters: parameters, fullResponse: fullResponse);
  }

  /// Does a http POST (with optional overrides).
  /// You can pass the full url, or the path after the baseUrl.
  /// Will timeout, check connectivity and retry until there is a response.
  /// Will handle most success or failure cases and will respond with either data or exception.
  Future<dynamic> post(String url,
      {Map<String, dynamic> parameters,
      dynamic data,
      bool fullResponse = false}) async {
    return request("POST", url,
        parameters: parameters, data: data, fullResponse: fullResponse);
  }

  /// Does a http PUT (with optional overrides).
  /// You can pass the full url, or the path after the baseUrl.
  /// Will timeout, check connectivity and retry until there is a response.
  /// Will handle most success or failure cases and will respond with either data or exception.
  Future<dynamic> put(String url,
      {Map<String, dynamic> parameters,
      dynamic data,
      bool fullResponse = false}) async {
    return request("PUT", url,
        parameters: parameters, data: data, fullResponse: fullResponse);
  }

  /// Make call, and manage the many network problems that can happen.
  /// Will only throw an exception when it's sure that there is no internet connection,
  /// exhausts its retries or gets an unexpected server response
  Future<dynamic> request(String method, String url,
      {Map<String, dynamic> parameters,
      dynamic data,
      bool fullResponse = false}) async {
    dio.options.method = method;

    for (var i = 1; i <= (httpRetries ?? this.httpRetries); i++) {
      try {
        var response =
            (await dio.request(url, queryParameters: parameters, data: data));
        return fullResponse == true ? response : response.data;
      } catch (error) {
        await _handleException(error);
      }
    }
    // Exhausted retries, so send back exception
    throw RetryFailureException();
  }

  /// Change headers
  void set headers(Map<String, dynamic> map) {
    dio.options.headers = map;
  }

  /// Handle exceptions that come from various failures
  void _handleException(dynamic error) async {
    print(error.toString());
    if (error is DioError) {
      if (error.type == DioErrorType.CONNECT_TIMEOUT ||
          error.type == DioErrorType.RECEIVE_TIMEOUT) {
        if (await Connectivity().checkConnectivity() ==
            ConnectivityResult.none) {
          throw ConnectivityException();
        }
      } else if (error.type == DioErrorType.RESPONSE) {
        throw UnexpectedResponseException(error.response);
      } else {
        print(error.toString());
        throw UnknownException(error.message);
      }
    } else {
      print(error.toString());
      throw UnknownException(error.message);
    }
  }
}
