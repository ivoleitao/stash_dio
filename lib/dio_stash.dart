/// A cache extension for Dio using the stash caching library
library dio_stash;

import 'package:dio/dio.dart';
import 'package:stash/stash_api.dart';
import 'package:stash/stash_memory.dart';
import 'package:stash_dio/src/dio/interceptor_builder.dart';

export 'src/dio/cache_interceptor.dart';

Interceptor newCacheInterceptor(String pattern, Cache cache) {
  return (CacheInterceptorBuilder()..cache(pattern, cache)).build();
}

Interceptor newMemoryCacheInterceptor(String pattern, String cacheName,
    {KeySampler sampler,
    EvictionPolicy evictionPolicy,
    int maxEntries,
    ExpiryPolicy expiryPolicy,
    CacheLoader cacheLoader}) {
  return newCacheInterceptor(
      pattern,
      newMemoryCache(
          cacheName: cacheName,
          sampler: sampler,
          evictionPolicy: evictionPolicy,
          maxEntries: maxEntries,
          expiryPolicy: expiryPolicy,
          cacheLoader: cacheLoader));
}

Interceptor newTieredCacheInterceptor(
    String pattern, Cache primary, Cache secondary) {
  return newCacheInterceptor(pattern, newTieredCache(primary, secondary));
}
