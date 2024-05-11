import 'package:flutter/foundation.dart';
import 'package:flutter_weather/main.dart';
import 'package:flutter_weather/model/data/weather_air_data.dart';
import 'package:flutter_weather/model/data/weather_data.dart';
import 'package:flutter_weather/model/service/service.dart';

class WeatherService extends Service {
  WeatherService() {
    dio.options.baseUrl = "https://www.feizhaojun.com/api";
  }

  Future<WeatherData> getWeather({required String city}) async {
    final response = await get("/weather?city=$city",
        cancelToken: cancelToken);
    return await compute(_formatWeather, response.data);
  }

  static WeatherData _formatWeather(data) {
    return WeatherData.fromJson(data);
  }

  Future<WeatherAirData> getAir({required String city}) async {
    final response = await get("/weather?city=$city",
        cancelToken: cancelToken);

    return await compute(_formatAir, response.data);
  }

  static WeatherAirData _formatAir(data) {
    return WeatherAirData.fromJson(data);
  }
}
