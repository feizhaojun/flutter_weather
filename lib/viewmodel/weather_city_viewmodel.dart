// Utils
import 'package:flutter_weather/data/sentence_data.dart';
import 'package:flutter_weather/model/holder/shared_depository.dart';
// Data
import 'package:flutter_weather/data/city_data.dart';
// Service
import 'package:flutter_weather/services/weather_service.dart';
import 'package:flutter_weather/services/shici_service.dart';

import 'dart:async';

import 'package:csv/csv.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_weather/model/data/city_data.dart';
import 'package:flutter_weather/model/data/weather_air_data.dart';
import 'package:flutter_weather/model/data/weather_data.dart';
import 'package:flutter_weather/model/holder/weather_holder.dart';
// import 'package:flutter_weather/model/service/weather_service.dart';
import 'package:flutter_weather/utils/channel_util.dart';
import 'package:flutter_weather/viewmodel/viewmodel.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class WeatherCityViewModel extends ViewModel {
  final int index;
  final sentence = StreamController<Sentence>();
  final weather = StreamController<Weather>();
  final air = StreamController<WeatherAir>();
  // final perStatus = StreamController<PermissionStatus>();

  final _service = WeatherService();
  final _shiciService = ShiciService();

  WeatherCityViewModel({required this.index}) {
    // 首先将缓存的数据作为第一数据显示，再判断请求逻辑
    final mWeather = WeatherHolder().weathers![index];
    final mAir = WeatherHolder().airs![index];
    weather.safeAdd(mWeather);
    air.safeAdd(mAir);

    loadData(isRefresh: false);
  }

  Future<void> loadData({bool isRefresh = true}) async {
    if (selfLoading) return;
    selfLoading = true;

    if (!isRefresh) {
      isLoading.safeAdd(true);
    }

    District mCity;
    City city;
    if (index == 0) {
      /// 位置服务
      bool serviceEnabled;
      LocationPermission permission;
      double longitude = 0;
      double latitude = 0;
      try {
        /// 手机GPS服务是否已启用。
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          //定位服务未启用，要求用户启用定位服务
          var res = await Geolocator.openLocationSettings();
          if (!res) {
            /// 被拒绝
            return;
          }
        }

        /// 是否允许app访问地理位置
        permission = await Geolocator.checkPermission();

        if (permission == LocationPermission.denied) {
          /// 之前访问设备位置的权限被拒绝，重新申请权限
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied ||
              permission == LocationPermission.deniedForever) {
            /// 再次被拒绝。根据Android指南，你的应用现在应该显示一个解释性UI。
            return;
          }
        } else if (permission == LocationPermission.deniedForever) {
          /// 之前权限被永久拒绝，打开app权限设置页面
          // await Geolocator.openAppSettings();
          return;
        }

        /// 允许访问地理位置，获取地理位置
        Position position = await Geolocator.getCurrentPosition();
        longitude = position.longitude;
        latitude = position.latitude;
      } catch (e) {
        // print(e);
      }

      final _city = await _service.getCity(
          longitude: longitude.toString(), latitude: latitude.toString());
      city = _city;
      // TODO: 兼容之前的数据格式
      mCity = District(
        name: _city.name,
        id: _city.key,
        key: _city.key ?? '',
        longitude: _city.longitude,
        latitude: _city.latitude,
      );

      // 根据经纬度获取城市

      // 请求定位权限
      // final status = (await PermissionHandler().requestPermissions([
      //   PermissionGroup.locationWhenInUse
      // ]))[PermissionGroup.locationWhenInUse];
      // final status = await Permission.location.request();
      // perStatus.safeAdd(status);

      // if (status != PermissionStatus.denied) {
      // mCity = District(
      //   name: "北京",
      //   id: '110101',
      // );
      // final result = await ChannelUtil.getLocation();
      // if (result != null) {
      //   final csv = await rootBundle.loadString("assets/china-city-list.csv");
      //   final csvList = const CsvToListConverter().convert(csv);
      //   for (int i = 2; i < csvList.length; i++) {
      //     final list = csvList[i];
      //     if (list[2] == result.district && list[7] == result.province) {
      //       mCity = District(name: result.district, id: list[0]);
      //       break;
      //     }
      //   }

      //   if (mCity == null) {
      //     mCity = WeatherHolder().cities![index];
      //   }
      // } else {
      //   mCity = WeatherHolder().cities![index];
      // }
      //   } else {
      //     mCity = WeatherHolder().cities![index];
      //   }
    } else {
      mCity = WeatherHolder().cities![index];
      city = City(
        name: mCity.name,
        key: mCity.key,
        longitude: mCity.longitude,
        latitude: mCity.latitude,
      );
    }

    // 纠正缓存
    // if (mCity.id == 'CN101010100') {
    //   mCity = District(
    //       name: "成都",
    //       id: '510104',
    //     );
    // }

    try {
      final weatherData = await _service.getWeather(city: city);
      // 储存本次天气结果
      // if (weatherData.weathers?.isNotEmpty ?? false) {
      //   final mWeather = weatherData.weathers!.first;
      //   weather.safeAdd(mWeather);

      //   // TODO:
      //   // final airData = await _service.getAir(city: mWeather.basic!.parentCity!);
      //   // if (airData.weatherAir?.isNotEmpty ?? false) {
      //   //   final mAir = airData.weatherAir!.first;
      //   //   air.safeAdd(mAir);

      //     WeatherHolder().addCity(mCity, updateIndex: index);
      //     WeatherHolder().addWeather(mWeather, updateIndex: index);
      //   //   WeatherHolder().addAir(mAir, updateIndex: index);
      //   // }
      // }
    } on DioError catch (e) {
      doError(e);
    } finally {
      selfLoading = false;

      if (!isRefresh) {
        isLoading.safeAdd(false);
      }
    }

    // // 获取诗词
    // // 取 token
    // String shiciToken = await SharedDepository().getString('token');
    // if (shiciToken == '') {
    //   shiciToken = await _shiciService.getToken();
    //   SharedDepository().setString('token', shiciToken);
    // }

    // final sentenceRes = await _shiciService.getSentence(shiciToken);
    // sentence.safeAdd(sentenceRes);
  }

  @override
  void reload() {
    super.reload();

    loadData(isRefresh: false);
  }

  @override
  void dispose() {
    _service.dispose();

    weather.close();
    air.close();
    // perStatus.close();

    super.dispose();
  }
}
