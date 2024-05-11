import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_weather/models/shared_depository.dart';
import 'package:flutter_weather/common/streams.dart';

class TestModel {
  // TODO: 使用单例模式管理
  static final TestModel _instance = TestModel._internal();

  factory TestModel() => _instance;

  Stream<String>? testString;
  final _testString = StreamController<String>();

  TestModel._internal() {
    testString = _testString.stream.asBroadcastStream();
    String? _testStringCache = SharedDepository().getTestString();
    debugPrint(_testStringCache);
    _testString.safeAdd(_testStringCache ?? "This is a default test string.");
  }

  void dispose() {
    _testString.close();
  }
}
