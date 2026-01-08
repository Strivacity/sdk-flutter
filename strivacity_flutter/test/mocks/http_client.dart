import 'package:dio/src/dio.dart';
import 'package:dio/src/options.dart';
import 'package:strivacity_flutter/src/logging.dart';
import 'package:strivacity_flutter/src/utils/http_client.dart';

class MockHttpClient implements HttpClient {
  @override
  bool initialized = true;

  @override
  Dio get dio => throw UnimplementedError();

  @override
  Future<HttpResponse> followUntil(String path, bool Function(HttpResponse p1) predicate) {
    throw UnimplementedError();
  }

  @override
  Future<HttpResponse> get(String path, [Function(RequestOptions p1)? httpCustomizer]) {
    throw UnimplementedError();
  }

  @override
  Future<HttpResponse> post(String path, [Function(RequestOptions p1)? httpCustomizer]) {
    throw UnimplementedError();
  }

  @override
  Future<HttpResponse> sendTokenRequest(String path, [Function(RequestOptions p1)? httpCustomizer]) {
    throw UnimplementedError();
  }

  @override
  Logging get logging => throw UnimplementedError();

}
