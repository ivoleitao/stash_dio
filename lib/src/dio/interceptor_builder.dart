import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:stash/stash_api.dart';

import 'cache_interceptor.dart';
import 'cache_value.dart';
import 'header_value.dart';

typedef _ParseHeadCallback = void Function(Duration maxAge, Duration maxStale);

class CacheInterceptorBuilder {
  final Map<RegExp, Cache> _cacheMap = {};

  InterceptorSendCallback get onRequest => _onRequest;

  InterceptorSuccessCallback get onResponse => _onResponse;

  InterceptorErrorCallback get onError => _onError;

  void cache(String pattern, Cache cache) {
    _cacheMap[RegExp(pattern)] = cache;
  }

  Cache _getCache(Uri uri) {
    var input = '${uri?.host}${uri?.path}?${uri.query}';
    for (var entry in _cacheMap.entries) {
      if (entry.key.hasMatch(input)) {
        return entry.value;
      }
    }

    return null;
  }

  String hex(List<int> bytes) {
    final buffer = StringBuffer();
    for (var part in bytes) {
      if (part & 0xff != part) {
        throw FormatException('$part is not a byte integer');
      }
      buffer.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
    }
    return buffer.toString().toUpperCase();
  }

  String _toMd5(String input) {
    return hex(md5.convert(utf8.encode(input)).bytes);
  }

  String _getKey(RequestOptions options) => _toMd5(
      '${options.uri?.host}${options.uri?.path}?${options.uri?.query}_${options.data?.toString()}');

  Response _responseFromCacheValue(CacheValue value, RequestOptions options) {
    Headers headers;
    if (value.headers != null) {
      headers = Headers.fromMap((Map<String, List<dynamic>>.from(
              jsonDecode(utf8.decode(value.headers))))
          .map((k, v) => MapEntry(k, List<String>.from(v))));
    }

    if (headers == null) {
      headers = Headers();
      options.headers.forEach((k, v) => headers.add(k, v ?? ''));
    }

    dynamic data = value.data;

    if (options.responseType != ResponseType.bytes) {
      data = jsonDecode(utf8.decode(data));
    }

    return Response(
        data: data, headers: headers, statusCode: value.statusCode ?? 200);
  }

  dynamic _onRequest(RequestOptions options) async {
    var cache = _getCache(options.uri);
    if (cache != null) {
      var value = await cache.get(_getKey(options));
      if (value != null) {
        return _responseFromCacheValue(value as CacheValue, options);
      }
    }

    return options;
  }

  Duration _tryGetDurationFromMap(Map<String, String> parameters, String key) {
    if (null != parameters && parameters.containsKey(key)) {
      var value = int.tryParse(parameters[key]);
      if (value != null && value >= 0) {
        return Duration(seconds: value);
      }
    }
    return null;
  }

  void _tryParseHead(Response response, _ParseHeadCallback callback) {
    Duration maxAge;
    Duration maxStale;
    var cacheControl = response.headers.value('cache-control');
    if (cacheControl != null) {
      // try to get maxAge and maxStale from cacheControl
      var parameters = HeaderValue.parse('cache-control: $cacheControl',
              parameterSeparator: '', valueSeparator: '=')
          .parameters;
      maxAge = _tryGetDurationFromMap(parameters, 's-maxage');
      maxAge ??= _tryGetDurationFromMap(parameters, 'max-age');
      // if staleTime has value, don't get max-stale anymore.
      maxStale ??= _tryGetDurationFromMap(parameters, 'max-stale');
    } else {
      // try to get expiryTime from expires
      var expires = response.headers.value('expires');
      if (expires != null && expires.length > 4) {
        var endTime = parseHttpDate(expires).toLocal();
        if (null != endTime && endTime.compareTo(DateTime.now()) >= 0) {
          maxAge = endTime.difference(DateTime.now());
        }
      }
    }

    callback(maxAge, maxStale);
  }

  dynamic _onResponse(Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var cache = _getCache(response.request.uri);
      if (cache != null) {
        var options = response.request;
        Duration maxAge;
        DateTime staleDate;
        if (maxAge == null) {
          _tryParseHead(response, (_maxAge, _staleTime) {
            maxAge = _maxAge;
            staleDate =
                _staleTime != null ? DateTime.now().add(_staleTime) : null;
          });
        }

        List<int> data;
        if (options.responseType == ResponseType.bytes) {
          data = response.data;
        } else {
          data = utf8.encode(jsonEncode(response.data));
        }

        await cache.put(
            _getKey(response.request),
            CacheValue(
                statusCode: response.statusCode,
                headers: utf8.encode(jsonEncode(response.headers.map)),
                staleDate: staleDate,
                data: data),
            expiryDuration: maxAge);
      }
    }

    return response;
  }

  dynamic _onError(DioError e) async {
    var cache = _getCache(e.request.uri);
    if (cache != null) {
      CacheValue value = await cache.get(_getKey(e.request));
      if (value != null && !value.staleDateExceeded()) {
        return _responseFromCacheValue(value, e.request);
      }
    }

    return e;
  }

  Interceptor build() {
    return CacheInterceptor.builder(this);
  }
}
