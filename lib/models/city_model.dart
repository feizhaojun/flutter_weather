import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
// Data
import 'package:flutter_weather/data/city_data.dart';
import 'package:flutter_weather/model/data/page_module_data.dart';
import 'package:flutter_weather/models/page_modules_model.dart';
// Service
import 'package:flutter_weather/services/weather_service.dart';
// Utils
import 'package:geolocator/geolocator.dart';
import 'package:flutter_weather/models/shared_depository.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
//
import 'package:flutter_weather/common/streams.dart';

class CityModel {
  // TODO: 使用单例模式管理
  static final CityModel _instance = CityModel._internal();

  factory CityModel() => _instance;

  Stream<List<City>>? cityList;
  final _cityList = StreamController<List<City>>();

  final _service = WeatherService();

  CityModel._internal() {
    debugPrint('CityModel._internal');
    cityList = _cityList.stream.asBroadcastStream();

    // TODO:
    // Connectivity()
    //     .onConnectivityChanged
    //     .listen((List<ConnectivityResult> result) {
    //   debugPrint("Connectivity: ${result}");
    //   if (result[0] != ConnectivityResult.none) {
    //     init();
    //   }
    // });
  }

  void getCityByLocation(bool hasPermission) async {
    List<City>? _cityListCache = SharedDepository().cityList;
    debugPrint(_cityListCache.toString());
    double longitude = 0;
    double latitude = 0;
    late City city;
    // TODO: 随机城市库
    List<City> cityListPool = [
      City.fromJson({
        "affiliation": "北京市, 中国",
        "key": "weathercn:101010300",
        "latitude": "39.921",
        "locationKey": "weathercn:101010300",
        "longitude": "116.486",
        "name": "朝阳区"
      }),
      City.fromJson({
        "affiliation": "日照市, 山东, 中国",
        "key": "weathercn:101121504",
        "latitude": "35.469",
        "locationKey": "weathercn:101121504",
        "longitude": "119.378",
        "name": "东港区"
      }),
      City.fromJson({
        "affiliation": "上海市, 中国",
        "key": "weathercn:101021200",
        "latitude": "31.213",
        "locationKey": "weathercn:101021200",
        "longitude": "121.445",
        "name": "徐汇区"
      }),
      City.fromJson({
        "affiliation": "广州市, 广东, 中国",
        "key": "weathercn:101280107",
        "latitude": "23.139",
        "locationKey": "weathercn:101280107",
        "longitude": "113.288",
        "name": "越秀区"
      }),
      City.fromJson({
        "affiliation": "深圳市, 广东, 中国",
        "key": "weathercn:101280602",
        "latitude": "22.582",
        "locationKey": "weathercn:101280602",
        "longitude": "114.156",
        "name": "罗湖区"
      }),
      City.fromJson({
        "affiliation": "西安市, 陕西, 中国",
        "key": "weathercn:101110108",
        "latitude": "34.266",
        "locationKey": "weathercn:101110108",
        "longitude": "108.961",
        "name": "新城区"
      }),
    ];

    if (hasPermission) {
      // 允许访问地理位置，获取地理位置
      Position position = await Geolocator.getCurrentPosition();
      longitude = position.longitude;
      latitude = position.latitude;

      city = await _service.getCity(
          longitude: longitude.toString(), latitude: latitude.toString());
    } else {
      // TODO: 随机一个城市
      city = cityListPool[Random().nextInt(cityListPool.length)];
    }

    if (_cityListCache == null) {
      _cityListCache = [city];
    } else {
      _cityListCache =
          _cityListCache.where((el) => el.name != city.name).toList();
      _cityListCache.insert(0, city);
      _cityListCache = _cityListCache.sublist(0, min(5, _cityListCache.length));
    }
    SharedDepository().setCityList(_cityListCache);
    _cityList.safeAdd(_cityListCache);
  }

  void dispose() {
    // subscription.cancel();
    _cityList.close();
    _service.dispose();
  }
}
