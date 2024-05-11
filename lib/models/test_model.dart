import 'dart:async';
import 'package:flutter/material.dart';
// Utils
import 'package:flutter_weather/models/shared_depository.dart';
// Data
//
import 'package:flutter_weather/common/streams.dart';
// import 'package:flutter_weather/data/city_data.dart';
//
// import 'package:flutter_weather/common/streams.dart';
// import 'package:flutter_weather/model/data/city_data.dart';
// import 'package:flutter_weather/model/data/weather_air_data.dart';
// import 'package:flutter_weather/model/data/weather_data.dart';

class TestModel {
  // TODO: 使用单例模式管理
  static final TestModel _instance = TestModel._internal();

  factory TestModel() => _instance;

  Stream<String>? testString;
  final _testString = StreamController<String>();

  // final _citiesBroadcast = StreamController<List<District>>();

  // Stream<List<District>>? cityStream;
  // List<District> _cacheCities = [];

  // List<District>? get cities => _cacheCities;

  TestModel._internal() {
    testString = _testString.stream.asBroadcastStream();
    String? _testStringCache = SharedDepository().getTestString();
    debugPrint(_testStringCache);
    _testString.safeAdd(_testStringCache ?? "This is a default test string.");

    // Future.delayed(
    //     Duration(seconds: 10), () => _testString.safeAdd("TestString2"));
    // Future.delayed(
    //     Duration(seconds: 20), () => _testString.safeAdd("TestString3"));
    // _testString.safeAdd(SharedDepository().getTestString());
    // cityStream = _citiesBroadcast.stream.asBroadcastStream();

    // _cacheCities = SharedDepository().districts;

    // _citiesBroadcast.safeAdd(_cacheCities);
  }

  // Future<void> addCity(District city, {int? updateIndex}) async {
  //   if (updateIndex == null) {
  //     _cacheCities.add(city);
  //   } else {
  //     _cacheCities.removeAt(updateIndex);
  //     _cacheCities.insert(updateIndex, city);
  //   }
  //   await SharedDepository().setDistricts(_cacheCities);
  //   _citiesBroadcast.safeAdd(_cacheCities);
  // }

  // Future<void> updateCity(int before, int after) async {
  //   final mCity = _cacheCities?[before];
  //   _cacheCities!.removeAt(before);
  //   _cacheCities!.insert(after, mCity!);
  //   await SharedDepository().setDistricts(_cacheCities);
  //   _citiesBroadcast.safeAdd(_cacheCities);
  // }

  // Future<void> removeCity(int index) async {
  //   _cacheCities.removeAt(index);
  //   await SharedDepository().setDistricts(_cacheCities);
  //   _citiesBroadcast.safeAdd(_cacheCities);
  // }

  // Future<void> addWeather(Weather weather, {int? updateIndex}) async {
  //   if (updateIndex == null) {
  //     _cacheWeathers!.add(weather);
  //   } else {
  //     _cacheWeathers!.removeAt(updateIndex);
  //     _cacheWeathers!.insert(updateIndex, weather);
  //   }
  //   await SharedDepository().setWeathers(_cacheWeathers!);
  //   _weathersBroadcast.safeAdd(_cacheWeathers!);
  // }

  // Future<void> updateWeather(int before, int after) async {
  //   final mWeather = _cacheWeathers![before];
  //   _cacheWeathers!.removeAt(before);
  //   _cacheWeathers!.insert(after, mWeather);
  //   await SharedDepository().setWeathers(_cacheWeathers!);
  //   _weathersBroadcast.safeAdd(_cacheWeathers!);
  // }

  // Future<void> removeWeather(int index) async {
  //   _cacheWeathers!.removeAt(index);
  //   await SharedDepository().setWeathers(_cacheWeathers!);
  //   _weathersBroadcast.safeAdd(_cacheWeathers!);
  // }

  // Future<void> addAir(WeatherAir air, {int? updateIndex}) async {
  //   if (updateIndex == null) {
  //     _cacheAirs!.add(air);
  //   } else {
  //     _cacheAirs!.removeAt(updateIndex);
  //     _cacheAirs!.insert(updateIndex, air);
  //   }
  //   await SharedDepository().setAirs(_cacheAirs!);
  //   _airsBroadcast.safeAdd(_cacheAirs!);
  // }

  // Future<void> updateAir(int before, int after) async {
  //   final mAir = _cacheAirs![before];
  //   _cacheAirs!.removeAt(before);
  //   _cacheAirs!.insert(after, mAir);
  //   await SharedDepository().setAirs(_cacheAirs!);
  //   _airsBroadcast.safeAdd(_cacheAirs!);
  // }

  // Future<void> removeAir(int index) async {
  //   _cacheAirs!.removeAt(index);
  //   await SharedDepository().setAirs(_cacheAirs!);
  //   _airsBroadcast.safeAdd(_cacheAirs!);
  // }

  void dispose() {
    _testString.close();
    // _citiesBroadcast.close();
    // _weathersBroadcast.close();
    // _airsBroadcast.close();

    // _cacheCities?.clear();
    // _cacheAirs?.clear();
    // _cacheWeathers?.clear();
  }
}
