import 'dart:async';
import 'package:flutter/material.dart';
// Data
import 'package:flutter_weather/data/city_data.dart';
import 'package:flutter_weather/data/weather_data.dart';
// Services
import 'package:flutter_weather/services/weather_service.dart';
// Utils
import 'package:flutter_weather/models/shared_depository.dart';
import 'package:flutter_weather/common/streams.dart';
import 'package:flutter_weather/utils/view_util.dart';

class WeatherModel {
  // TODO: 使用单例模式管理
  static final WeatherModel _instance = WeatherModel._internal();

  factory WeatherModel() => _instance;

  Stream<Weather>? weather;
  final _weather = StreamController<Weather>();

  final _service = WeatherService();

  WeatherModel._internal() {
    weather =
        _weather.stream.asBroadcastStream(onCancel: (sub) => sub.cancel());
    // TODO: 接口请求缓存机制，在页面上还要分数据做渲染缓存，防止重复渲染，但是用户进页面基本就一次，如果没有定时刷新的话。
    // String? _weatherCache = SharedDepository().getTestString();
    // debugPrint(_weatherCache);
    // _weather.safeAdd(_weatherCache ?? "This is a default test string.");
    // 先 不用缓存，从接口取数据。
  }

  Future<Weather> getWeather(City city) async {
    debugPrint("WeatherModel:getWeather: >");
    final weatherRes = await _service.getWeather(city: city);
    _weather.safeAdd(weatherRes); // 添加到 Model:Stream
    return weatherRes;
  }

  Future<Weather> refreshWeather(int index, {BuildContext? context}) async {
    debugPrint("refreshPage: ${index}");
    // 刷新时，城市数据肯定已经缓存
    List<City>? _cityListCache = SharedDepository().cityList;
    debugPrint(
        "WeatherModel:refreshWeather:_cityListCache: ${_cityListCache.toString()}");
    if (_cityListCache == null) {
      return Future(() => Weather());
    }
    final weatherRes = await _service.getWeather(city: _cityListCache[index]);
    // debugPrint("refreshWeather:test: ${weatherRes.toJson()}");
    _weather.safeAdd(weatherRes); // 添加到 Model:Stream
    Future.delayed(Duration(seconds: 3), () => _weather.safeAdd(weatherRes));
    // Toast 已更新
    if (context != null) {
      ToastUtil.showToast(context, '已更新');
    }
    return weatherRes;
  }

  void dispose() {
    _weather.close();
    _service.dispose();
  }
}
