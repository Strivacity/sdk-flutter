import 'dart:developer';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

class HttpClient {
  final Dio dio = Dio();
  late PersistCookieJar cookieJar;
  bool initialized = false;

  Future<void> _init() async {
    if (initialized) return;

    cookieJar = PersistCookieJar(ignoreExpires: false, storage: FileStorage((await getApplicationCacheDirectory()).path));
    dio.options.headers = {'Content-Type': 'application/json'};
    dio.interceptors.add(CookieManager(cookieJar));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        log('##### REQUEST #####');
        log('URL: [${options.method}] ${options.uri}');
        log('HEADERS: [${options.headers}]');
        log('DATA: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        log('##### RESPONSE #####');
        log('URL: [${response.requestOptions.method}] ${response.requestOptions.uri}');
        log('HEADERS: [${response.headers}]');
        log('DATA: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        log('##### RESPONSE WITH ERROR [${e.response?.statusCode}] #####');
        log('URL: [${e.requestOptions.method}] ${e.requestOptions.uri}');
        log('HEADERS: [${e.response?.headers}]');
        log('DATA: ${e.response?.data}');
        return handler.next(e);
      },
    ));
    initialized = true;
  }

  /// Sends a GET request to the specified [path].
  ///
  /// Optionally takes an [httpCustomizer] function to customize the request options.
  /// Returns an [HttpResponse] containing the response data, status code, and headers.
  Future<HttpResponse> get(String path, [Function(RequestOptions)? httpCustomizer]) async {
    await _init();

    final options = RequestOptions(path: path, method: 'GET', validateStatus: (status) => true);

    if (httpCustomizer != null) {
      httpCustomizer(options);
    }

    final response = await dio.fetch(options);

    return HttpResponse(response.data, response.statusCode, response.headers.map);
  }

  /// Sends a POST request to the specified [path].
  ///
  /// Optionally takes an [httpCustomizer] function to customize the request options.
  /// Returns an [HttpResponse] containing the response data, status code, and headers.
  Future<HttpResponse> post(String path, [Function(RequestOptions)? httpCustomizer]) async {
    await _init();

    final options = RequestOptions(path: path, method: 'POST');

    if (httpCustomizer != null) {
      httpCustomizer(options);
    }

    final response = await dio.fetch(options);

    return HttpResponse(response.data, response.statusCode, response.headers.map);
  }

  /// Sends a token request to the specified [path].
  ///
  /// Optionally takes an [httpCustomizer] function to customize the request options.
  /// Returns an [HttpResponse] containing the response data, status code, and headers.
  Future<HttpResponse> sendTokenRequest(String path, [Function(RequestOptions)? httpCustomizer]) async {
    await _init();

    final options = RequestOptions(path: path, method: 'POST', headers: {'Content-Type': 'application/x-www-form-urlencoded'}, followRedirects: false);

    if (httpCustomizer != null) {
      httpCustomizer(options);
    }

    final response = await dio.fetch(options);

    return HttpResponse(response.data, response.statusCode, response.headers.map);
  }

  /// Follows redirects until the specified [predicate] is satisfied.
  ///
  /// Takes a [path] and a [predicate] function that checks the [HttpResponse].
  /// Returns the [HttpResponse] if the predicate is satisfied within 10 redirects.
  /// Throws an exception if the predicate is not satisfied within 10 redirects.
  Future<HttpResponse> followUntil(String path, bool Function(HttpResponse) predicate) async {
    int redirectionCounter = 0;
    HttpResponse response;

    do {
      response = await get(path, (RequestOptions options) {
        options.followRedirects = false;
      });

      if (predicate(response)) {
        return response;
      }

      if (response.responseCode != 301 && response.responseCode != 302 && response.responseCode != 303) {
        throw Exception('No such element');
      }

      path = Uri.parse(response.headers['location']!.first).toString();
    } while (redirectionCounter++ < 10);

    throw Exception('No such element');
  }
}

class HttpResponse {
  final dynamic body;
  final int? responseCode;
  final Map<String, List<String>> headers;

  HttpResponse(this.body, this.responseCode, this.headers);

  /// Creates an [HttpResponse] from a [Response] stream.
  ///
  /// Takes a [Response] object and extracts the body, headers, and status code.
  /// Returns an [HttpResponse] containing the extracted data.
  static Future<HttpResponse> fromStream(Response response) async {
    final body = response.data;
    final headers = response.headers.map;
    final responseCode = response.statusCode!;

    return HttpResponse(body, responseCode, headers);
  }
}
