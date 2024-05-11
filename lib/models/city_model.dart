import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
// Data
import 'package:flutter_weather/data/city_data.dart';
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

    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      debugPrint("Connectivity: ${result}");
      if (result[0] != ConnectivityResult.none) {
        init();
      }
    });

    cityList = _cityList.stream.asBroadcastStream();
  }

  void init() {
    List<City>? _cityListCache = SharedDepository().cityList;
    debugPrint(_cityListCache.toString());
    getCityByLocation().then((city) {
      debugPrint("Location: ${city?.toJson()}");
      if (city == null) {
        // TODO: 返回一个随机城市
        city = City(
            affiliation: '北京, 中国',
            key: 'weathercn:101010200',
            name: '海淀',
            longitude: '116.298',
            latitude: '39.959');
      }
      if (_cityListCache == null) {
        _cityListCache = [city];
      } else {
        _cityListCache =
            _cityListCache?.where((el) => el.name != city?.name).toList();
        _cityListCache?.insert(0, city);
        _cityListCache =
            _cityListCache?.sublist(0, min(5, _cityListCache!.length));
      }
      SharedDepository().setCityList(_cityListCache!);
      // SharedDepository().setCityList([_cityListCache![0]]);
      _cityList.safeAdd(_cityListCache!);
    });
  }

  // 获取城市定位
  Future<City?> getCityByLocation() async {
    // 获取经纬度
    bool serviceEnabled;
    LocationPermission permission;
    double longitude = 0;
    double latitude = 0;
    try {
      // 手机 GPS 服务是否已启用
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // 定位服务未启用，要求用户启用定位服务
        var res = await Geolocator.openLocationSettings();
        if (!res) {
          // 被拒绝
          return null;
        }
      }
      // 是否允许app访问地理位置
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // 之前访问设备位置的权限被拒绝，重新申请权限
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          // 再次被拒绝。根据Android指南，你的应用现在应该显示一个解释性 UI。
          return null;
        }
      } else if (permission == LocationPermission.deniedForever) {
        // 之前权限被永久拒绝，打开 app 权限设置页面
        await Geolocator.openAppSettings();
        return null;
      }
      // 允许访问地理位置，获取地理位置
      Position position = await Geolocator.getCurrentPosition();
      longitude = position.longitude;
      latitude = position.latitude;
    } catch (e) {
      // print(e);
    }

    final _city = await _service.getCity(
        longitude: longitude.toString(), latitude: latitude.toString());
    return _city;
  }

  void dispose() {
    // subscription.cancel();
    _cityList.close();
    _service.dispose();
  }
}
