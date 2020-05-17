import 'package:dio/dio.dart';

import 'interceptor_builder.dart';

class CacheInterceptor extends InterceptorsWrapper {
  CacheInterceptor.builder(CacheInterceptorBuilder builder)
      : super(
            onRequest: builder.onRequest,
            onResponse: builder.onResponse,
            onError: builder.onError);
}
