import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';

class PrettyDioLogger extends Interceptor {
  final bool logRequestHeaders;
  final bool logRequestBody;
  final bool logResponseBody;
  final bool logResponseHeaders;

  PrettyDioLogger({
    this.logRequestHeaders = true,
    this.logRequestBody = true,
    this.logResponseBody = true,
    this.logResponseHeaders = false,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(
      "➡️ [REQUEST] ${options.method} ${options.uri}",
      name: "DioLogger",
    );

    if (logRequestHeaders && options.headers.isNotEmpty) {
      developer.log(
        "Headers:\n${_prettyPrint(options.headers)}",
        name: "DioLogger",
      );
    }

    if (logRequestBody && options.data != null) {
      developer.log("Body:\n${_prettyPrint(options.data)}", name: "DioLogger");
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log(
      "✅ [RESPONSE] ${response.statusCode} ${response.requestOptions.uri}",
      name: "DioLogger",
    );

    if (logResponseHeaders) {
      developer.log(
        "Headers:\n${_prettyPrint(response.headers.map)}",
        name: "DioLogger",
      );
    }

    if (logResponseBody) {
      developer.log("Body:\n${_prettyPrint(response.data)}", name: "DioLogger");
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      "❌ [ERROR] ${err.response?.statusCode} ${err.requestOptions.uri}",
      error: err,
      name: "DioLogger",
    );

    if (err.response?.data != null) {
      developer.log(
        "Error Body:\n${_prettyPrint(err.response?.data)}",
        name: "DioLogger",
      );
    }

    handler.next(err);
  }

  String _prettyPrint(dynamic data) {
    try {
      if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      } else if (data is String) {
        try {
          final jsonData = json.decode(data);
          return const JsonEncoder.withIndent('  ').convert(jsonData);
        } catch (_) {
          return data;
        }
      }
      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }
}
