// Data
import 'dart:convert';

import 'package:flutter_weather/data/city_data.dart';
import 'package:flutter_weather/data/weather_data.dart';
// Service
import 'package:flutter_weather/model/service/service.dart';
// Utils
import 'package:flutter/foundation.dart';
import 'package:flutter_weather/models/shared_depository.dart';

class WeatherService extends Service {
  WeatherService() {
    dio.options.baseUrl = "https://www.feizhaojun.com/api";
  }

  Future<City> getCity(
      {required String longitude, required String latitude}) async {
    final response = await get(
        "https://weatherapi.market.xiaomi.com/wtr-v3/location/city/geo?locale=zh&longitude=$longitude&latitude=$latitude",
        cancelToken: cancelToken);
    return await compute(_formatCity, response.data);
  }

  static City _formatCity(data) {
    // TODO: CityList
    return City.fromJson(data[0]);
  }

  Future<Weather> getWeather({required City city}) async {
    final response = await get(
        "https://weatherapi.market.xiaomi.com/wtr-v3/weather/all?locale=zh&isLocated=false&days=15&appKey=weather20151024&sign=zUFJoAR2ZVrDy1vF3D07&isGlobal=false&latitude=${city.latitude}&longitude=${city.longitude}&locationKey=${city.key}",
        cancelToken: cancelToken);
    response.data["locationKey"] = city.key;
    response.data["updatedTime"] = DateTime.now().toString();
    SharedDepository().setString(city.key!, jsonEncode(response.data));
    debugPrint("WeatherService:getWeather: ${response.data}");
    return await compute(_formatWeather, response.data);
  }

  static Weather _formatWeather(data) {
    return Weather.fromJson(data);
  }

  Future<City> queryCity({required String city}) async {
    final response = await get(
        "https://weatherapi.market.xiaomi.com/wtr-v3/location/city/search?locale=zh&name${city}",
        cancelToken: cancelToken);
    return await compute(_formatQueryCity, response.data);
  }

  static City _formatQueryCity(data) {
    // TODO: CityList
    return City.fromJson(data[0]);
  }
}
