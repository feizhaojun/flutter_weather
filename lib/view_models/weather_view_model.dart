import 'dart:async';
import 'dart:math';

import 'package:flutter_weather/services/shici_service.dart';
import 'package:flutter_weather/common/streams.dart';
import 'package:flutter_weather/data/sentence_data.dart';
import 'package:flutter_weather/model/data/mixing.dart';
import 'package:flutter_weather/model/data/weather_air_data.dart';
import 'package:flutter_weather/model/data/weather_data.dart';
import 'package:flutter_weather/model/holder/shared_depository.dart';
import 'package:flutter_weather/model/holder/weather_holder.dart';
import 'package:flutter_weather/model/service/weather_service.dart';
import 'package:flutter_weather/viewmodel/viewmodel.dart';

class WeatherViewModel extends ViewModel {
  final testString = StreamController<String>();
  final sentence = StreamController<Sentence>();
  final cities = StreamController<List<String?>>();
  // TODO:
  final weather = StreamController<Pair<Weather, AirNowCity?>>();
  // final weather = StreamController<Weather>();
  // final hideWeather = StreamController<bool>();

  final _service = WeatherService();
  final _shiciService = ShiciService();

  int _index = 0;
  late Pair<Weather, AirNowCity?> _catchWeather;

  WeatherViewModel() {
    // TEST
    Future.delayed(Duration(seconds: 2), () {
      testString.safeAdd('This is string');
    });
    print('WeatherViewModel init');

    WeatherHolder().cityStream!.listen((list) {
      // debugLog('Listen cityStream');
      cities.safeAdd(list.map((v) => v.name).toList());

      final index = min(_index, list.length - 1);
      _catchWeather = Pair(WeatherHolder().weathers![index],
          WeatherHolder().airs![index].airNowCity ?? AirNowCity());
      
      // weather.safeAdd(_catchWeather);
    }).bindLife(this as StreamSubController);
    final index = min(_index, WeatherHolder().cities!.length - 1);
    _catchWeather = Pair(WeatherHolder().weathers![index],
        WeatherHolder().airs![index].airNowCity ?? AirNowCity());
    // weather.safeAdd(_catchWeather);
    // cities.safeAdd(WeatherHolder().cities!.map((v) => v.name).toList());
  }

  Future<void> loadData({bool isRefresh = true}) async {
    // 获取诗词
    // 取 token
    String shiciToken = await SharedDepository().getString('token');
    if (shiciToken == '') {
      shiciToken = await _shiciService.getToken();
      SharedDepository().setString('token', shiciToken);
    }

    final sentenceRes = await _shiciService.getSentence(shiciToken);
    // sentence.safeAdd(sentenceRes);
  }

  // void indexChange(int index) {
  //   _index = index;
  //   _catchWeather = Pair(WeatherHolder().weathers![index],
  //       WeatherHolder().airs![index].airNowCity);

  //   weather.safeAdd(_catchWeather);
  // }

  // 预览其他天气
  void switchType(String type) {
    _catchWeather.a.now?.condTxt = type;
    weather.safeAdd(_catchWeather);
  }

  // void changeHideState(bool hide) {
  //   hideWeather.safeAdd(hide);
  // }

  // @override
  // void dispose() {
  //   _service.dispose();

  //   hideWeather.close();
  //   cities.close();
  //   weather.close();

  //   super.dispose();
  // }
}
