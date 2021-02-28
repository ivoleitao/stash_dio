# stash_dio
A [Stash](https://github.com/ivoleitao/stash) Dio extension

[![Pub Package](https://img.shields.io/pub/v/stash_dio.svg?style=flat-square)](https://pub.dartlang.org/packages/stash_dio)
[![Build Status](https://github.com/ivoleitao/shadertoy_api/workflows/build/badge.svg)](https://github.com/ivoleitao/stash_dio/actions)
[![Coverage Status](https://codecov.io/gh/ivoleitao/stash_dio/graph/badge.svg)](https://codecov.io/gh/ivoleitao/stash_dio)
[![Package Documentation](https://img.shields.io/badge/doc-stash_dio-blue.svg)](https://www.dartdocs.org/documentation/stash_dio/latest)
[![GitHub License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Introduction

This integration of [stash](https://pub.dartlang.org/packages/stash) with [dio](https://pub.dev/packages/dio) provides a caching interceptor that is able to return the response from a Cache instead of hitting the backend system.

## Getting Started

Add this to your `pubspec.yaml` (or create it):

```dart
dependencies:
    stash_dio: ^1.0.4
```

Run the following command to install dependencies:

```dart
pub install
```

Optionally use the following command to run the tests:

```dart
pub run test
```

Finally, to start developing import the library:

```dart
import 'package:stash_dio/stash_dio.dart';
```

## Usage

```dart
import 'package:dio/dio.dart';
import 'package:stash_dio/dio_stash.dart';

class Task {
  final int id;
  final String title;
  final bool completed;

  Task({this.id, this.title, this.completed = false});

  /// Creates a [Task] from json map
  factory Task.fromJson(Map<String, dynamic> json) => Task(
      id: json['id'] as int,
      title: json['title'] as String,
      completed: json['completed'] as bool);

  /// Creates a json map from a [Task]
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'id': id, 'title': title, 'completed': completed};

  @override
  String toString() {
    return 'Task ${id}: "${title}" is ${completed ? "completed" : "not completed"}';
  }
}

void main() async {
  // Configures a a dio client
  final dio = Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'))
    ..interceptors.addAll([
      newMemoryCacheInterceptor('/todos/1', 'task'),
      LogInterceptor(
          requestHeader: false,
          requestBody: false,
          responseHeader: false,
          responseBody: false)
    ]);

  // First call, executes the request and response is received
  final task1 = await dio
      .get('/todos/1')
      .then((Response<dynamic> response) => Task.fromJson(response.data));
  print(task1);

  // Second call, executes the request and the response is received from the
  // cache
  final task2 = await dio
      .get('/todos/1')
      .then((Response<dynamic> response) => Task.fromJson(response.data));
  print(task2);
}

```

## Contributing

It is developed by best effort, in the motto of "Scratch your own itch!", meaning APIs that are meaningful for the author use cases.

If you would like to contribute with other parts of the API, feel free to make a [Github pull request](https://github.com/ivoleitao/stash_dio/pulls) as I'm always looking for contributions for:
* Tests
* Documentation
* New APIs

## Features and Bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/ivoleitao/stash_dio/issues/new

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details