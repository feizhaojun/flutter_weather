// Data
import 'package:flutter_weather/data/city_data.dart';
//
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_weather/common/colors.dart';
// import 'package:flutter_weather/model/data/city_data.dart';
import 'package:flutter_weather/model/data/mzi_data.dart';
import 'package:flutter_weather/model/data/page_module_data.dart';
import 'package:flutter_weather/model/data/gank_data.dart';
import 'package:flutter_weather/model/data/weather_air_data.dart';
import 'package:flutter_weather/model/data/weather_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SharedPreference的管理仓库
class SharedDepository {
  // 使用单例模式管理
  static final SharedDepository _depository = SharedDepository._internal();

  late SharedPreferences _prefs;

  factory SharedDepository() => _depository;

  SharedDepository._internal() {
    // debugLog("SharedDepository._internal");
  }

  Future<SharedDepository> initShared() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // 获取所有城市定位
  List<District> get districts {
    final list = _getStringList("districts");
    if (list.isEmpty) {
      // TODO:
      return [District(name: "北京", id: "110101", key: '')];
    }
    return list
        .map((v) => jsonDecode(v))
        .map((v) => District.fromJson(v))
        .toList();
  }

  Future<bool> setDistricts(List<District> value) async => await _prefs
      .setStringList("districts", value.map((v) => jsonEncode(v)).toList());

  // 所有城市天气情况
  List<Weather> get weathers {
    final list = _getStringList("weathersData");
    if (list.isEmpty) {
      return [];
    } else {
      return list
          .map((v) => jsonDecode(v))
          .map((v) => Weather.fromJson(v))
          .toList();
    }
  }

  Future<bool> setWeathers(List<Weather> value) async => await _prefs
      .setStringList("weathersData", value.map((v) => jsonEncode(v)).toList());

  // 所有城市空气质量
  List<WeatherAir> get airs {
    final list = _getStringList("airsData");
    if (list.isEmpty) {
      return [WeatherAir(status: '', airNowCity: AirNowCity())];
    } else {
      return list
          .map((v) => jsonDecode(v))
          .map((v) => WeatherAir.fromJson(v))
          .toList();
    }
  }

  Future<bool> setAirs(List<WeatherAir> value) async => await _prefs
      .setStringList("airsData", value.map((v) => jsonEncode(v)).toList());

  // 收藏的闲读文章
  List<GankItem> get favReadItems {
    final str = _getString("favReadItems");

    return (jsonDecode(str) as List).map((v) => GankItem.fromJson(v)).toList();
  }

  Future<bool> setFavReadItems(List<GankItem> value) async =>
      await _prefs.setString("favReadItems", jsonEncode(value));

  // 收藏的妹子图
  List<MziItem> get favMziItems {
    final str = _getString("favMziItems");

    return (jsonDecode(str) as List).map((v) => MziItem.fromJson(v)).toList();
  }

  Future<bool> setFavMziItems(List<MziItem> value) async =>
      await _prefs.setString("favMziItems", jsonEncode(value));

  // 当前主题色
  Color get themeColor =>
      Color(_getInt("themeColor", defaultValue: AppColor.greenery.value));

  Future<bool> setThemeColor(Color color) async =>
      await _prefs.setInt("themeColor", color.value);

  // 图片本地缓存目录
  String get imgCachePath => _getString("imgCachePath");

  Future<bool> setImgCachePath(String path) async =>
      await _prefs.setString("imgCachePath", path);

  // 页面模块
  List<PageModule> get pageModules {
    final str = _getString("pageModules4",
        defaultValue: '[{"page":"weather","open":true}]');
    return jsonDecode(str)
        .map<PageModule>((v) => PageModule.fromJson(v))
        .toList();
  }

  Future<bool> setPageModules(List<PageModule> modules) async =>
      await _prefs.setString("pageModules4", jsonEncode(modules));

  // 天气分享形式是否为锤子分享
  bool get hammerShare => _getBool("hammerShare", defaultValue: true);

  Future<bool> setHammerShare(bool value) async =>
      await _prefs.setBool("hammerShare", value);

  // 获取已保存的图片
  List<String> get savedImages =>
      _getStringList("savedImages", defaultValue: []);

  Future<bool> setSavedImages(List<String> images) async =>
      await _prefs.setString("savedImages", jsonEncode(images));

  // 自动清除图片缓存
  bool get shouldClean => _getBool("shouldClean2.2.0+1", defaultValue: true);

  Future<bool> setsShouldClean(bool value) async =>
      await _prefs.setBool("shouldClean2.2.0+1", value);

  // 用户手动设置的语言
  Locale? get appLocale {
    final code = _getString("appLocale");
    return code.isEmpty ? null : Locale(code);
  }

  Future<bool> setAppLocale(Locale value) =>
      _prefs.setString("appLocale", value.languageCode);

  // ==============================================
  //                     分界线
  // ==============================================
  // 用带有默认值的形式获取prefs的数据
  String _getString(String key, {String defaultValue = ''}) {
    final value = _prefs.getString(key);

    if (value == null) {
      return defaultValue;
    }

    return value;
  }

  List<String> _getStringList(String key, {List<String>? defaultValue}) {
    final list = _prefs.getStringList(key);

    if (list == null) {
      return defaultValue ?? [];
    }

    return list;
  }

  int _getInt(String key, {int defaultValue = 0}) {
    final value = _prefs.getInt(key);

    if (value == null) {
      return defaultValue;
    }

    return value;
  }

  bool _getBool(String key, {bool defaultValue = false}) {
    final value = _prefs.getBool(key);

    if (value == null) {
      return defaultValue;
    }

    return value;
  }

  //
  String getString(String key, {String defaultValue = ''}) {
    final value = _prefs.getString(key);

    if (value == null) {
      return defaultValue;
    }

    return value;
  }

  Future<bool> setString(String key, String value) async =>
      await _prefs.setString(key, jsonEncode(value));
}
