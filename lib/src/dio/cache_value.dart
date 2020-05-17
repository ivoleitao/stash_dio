import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cache_value.g.dart';

@JsonSerializable()

/// The cached response
class CacheValue extends Equatable {
  static DateTime _fromJsonStaleDate(int date) =>
      DateTime.fromMicrosecondsSinceEpoch(date);

  static int _toJsonStaleDate(DateTime date) => date.microsecondsSinceEpoch;

  /// Http status code.
  final int statusCode;

  /// Response headers.
  final List<int> headers;

  /// The date after which the value needs to refreshed
  @JsonKey(fromJson: _fromJsonStaleDate, toJson: _toJsonStaleDate)
  final DateTime staleDate;

  /// Response bytes
  final List<int> data;

  /// Builds a [CacheValue]
  ///
  /// * [statusCode]: The HTTP status code
  /// * [headers]: The response headers
  /// * [staleDate]: The date after which the value needs to refreshed
  /// * [data]: The response bytes
  CacheValue({this.statusCode, this.headers, this.staleDate, this.data});

  /// If the stale time was exceeded
  ///
  /// * [now]: An optional datetime with the current date
  bool staleDateExceeded([DateTime now]) {
    return staleDate != null && staleDate.isBefore(now ?? DateTime.now());
  }

  /// The [List] of `props` (properties) which will be used to determine whether
  /// two [Equatables] are equal.
  @override
  List<Object> get props => [statusCode, headers, staleDate, data];

  /// Creates a [CacheValue] from json map
  factory CacheValue.fromJson(Map<String, dynamic> json) =>
      _$CacheValueFromJson(json);

  /// Creates a json map from a [CacheValue]
  Map<String, dynamic> toJson() => _$CacheValueToJson(this);
}
