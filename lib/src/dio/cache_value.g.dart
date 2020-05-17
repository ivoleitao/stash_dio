// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_value.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CacheValue _$CacheValueFromJson(Map<String, dynamic> json) {
  return CacheValue(
    statusCode: json['statusCode'] as int,
    headers: (json['headers'] as List)?.map((e) => e as int)?.toList(),
    staleDate: CacheValue._fromJsonStaleDate(json['staleDate'] as int),
    data: (json['data'] as List)?.map((e) => e as int)?.toList(),
  );
}

Map<String, dynamic> _$CacheValueToJson(CacheValue instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'headers': instance.headers,
      'staleDate': CacheValue._toJsonStaleDate(instance.staleDate),
      'data': instance.data,
    };
