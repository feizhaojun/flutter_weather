import 'dart:async';
import 'package:flutter/material.dart';
// Data
import 'package:flutter_weather/data/sentence_data.dart';
// 
// import 'package:flutter_weather/models/shared_depository.dart';
import 'package:flutter_weather/common/streams.dart';

class ShiciModel {
  // TODO: 使用单例模式管理
  static final ShiciModel _instance = ShiciModel._internal();

  factory ShiciModel() => _instance;

  Stream<Sentence>? sentence;
  final _sentence = StreamController<Sentence>();

  ShiciModel._internal() {
    sentence = _sentence.stream.asBroadcastStream();
    // Sentence? _sentenceCache = SharedDepository().getTestString();
    // debugPrint(_sentenceCache);
    // _sentence.safeAdd(_sentenceCache ?? "This is a default test string.");
  }

  void dispose() {
    _sentence.close();
  }
}
