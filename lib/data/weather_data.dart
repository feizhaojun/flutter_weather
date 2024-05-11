import 'package:flutter/material.dart';
import 'package:flutter_weather/common/weather_codes.dart';
import 'package:intl/intl.dart';

class Aqi {
  String? aqi;
  String? suggest;

  Aqi({this.aqi, this.suggest});

  Aqi.fromJson(Map<String, dynamic> json) {
    aqi = json['aqi'];
    suggest = json['suggest'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['aqi'] = this.aqi;
    data['suggest'] = this.suggest;
    return data;
  }
}

// TODO:
class Weather {
  String? locationKey = '';
  DateTime? updatedTime;
  WeatherBasic? basic;
  WeatherUpdate? update;
  String? status;
  WeatherNow? now;
  List<WeatherDailyForecast>? dailyForecast = [];
  List<WeatherHourly>? hourly;
  List<WeatherLifestyle>? lifestyle;
  String? probability;
  String? precipitation;
  Aqi? aqi;

  Weather(
      {this.locationKey,
      this.updatedTime,
      this.basic,
      this.update,
      this.status,
      this.now,
      this.dailyForecast,
      this.hourly,
      this.lifestyle});

  Weather.fromJson(Map<String, dynamic> json) {
    locationKey = json['locationKey'] != null ? json['locationKey'] : '';
    updatedTime = json['updatedTime'] != null
        ? DateTime.parse(json['updatedTime'])
        : DateTime.now();
    if (json['forecastDaily'] != null) {
      dailyForecast = <WeatherDailyForecast>[];
      json['forecastDaily']['sunRiseSet']['value'].asMap().forEach((k, v) {
        dailyForecast!.add(WeatherDailyForecast.fromJson({
          'aqi': json['forecastDaily']['aqi']['value'][k],
          'precipitationProbability': json['forecastDaily']
              ['precipitationProbability']['value'][k],
          'temperature': json['forecastDaily']['temperature']['value'][k],
          'weather': json['forecastDaily']['weather']['value'][k],
          'wind': json['forecastDaily']['wind']['speed']['value'][k],
          'sunRiseSet': v
        }));
      });
    }
    if (json['forecastHourly'] != null) {
      hourly = <WeatherHourly>[];
      json['forecastHourly']['aqi']['value'].asMap().forEach((k, v) {
        hourly!.add(WeatherHourly.fromJson({
          'aqi': v,
          'temperature': json['forecastHourly']['temperature']['value'][k],
          'weather': json['forecastHourly']['weather']['value'][k],
          'wind': json['forecastHourly']['wind']['value'][k],
        }));
      });
    }
    now = json['current'] != null ? WeatherNow.fromJson(json['current']) : null;
    if (json['forecasts'] != null) {
      dailyForecast = <WeatherDailyForecast>[];
      json['forecasts'][0]['casts'].forEach((v) {
        dailyForecast?.add(WeatherDailyForecast.fromJson(v));
      });
    }
    probability =
        json['minutely']['probability']['probabilityDescV2'].toString();
    precipitation = json['minutely']['precipitation']['description'].toString();
    aqi = Aqi.fromJson(json['aqi']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['updatedTime'] = this.updatedTime.toString();
    data['locationKey'] = this.locationKey;
    if (this.basic != null) {
      data['basic'] = this.basic!.toJson();
    }
    if (this.update != null) {
      data['update'] = this.update!.toJson();
    }
    data['status'] = this.status;
    if (this.now != null) {
      data['now'] = this.now!.toJson();
    }
    if (this.dailyForecast != null) {
      data['daily_forecast'] =
          this.dailyForecast!.map((v) => v.toJson()).toList();
    }
    if (this.hourly != null) {
      data['hourly'] = this.hourly!.map((v) => v.toJson()).toList();
    }
    if (this.lifestyle != null) {
      data['lifestyle'] = this.lifestyle!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class WeatherBasic {
  String? cid;
  String? location;
  String? parentCity;
  String? adminArea;
  String? cnty;
  String? lat;
  String? lon;
  String? tz;

  WeatherBasic(
      {this.cid,
      this.location,
      this.parentCity,
      this.adminArea,
      this.cnty,
      this.lat,
      this.lon,
      this.tz});

  WeatherBasic.fromJson(Map<String, dynamic> json) {
    cid = json['cid'];
    location = json['location'];
    parentCity = json['parent_city'];
    adminArea = json['admin_area'];
    cnty = json['cnty'];
    lat = json['lat'];
    lon = json['lon'];
    tz = json['tz'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['cid'] = this.cid;
    data['location'] = this.location;
    data['parent_city'] = this.parentCity;
    data['admin_area'] = this.adminArea;
    data['cnty'] = this.cnty;
    data['lat'] = this.lat;
    data['lon'] = this.lon;
    data['tz'] = this.tz;
    return data;
  }
}

class WeatherUpdate {
  String? loc;
  String? utc;

  WeatherUpdate({this.loc, this.utc});

  WeatherUpdate.fromJson(Map<String, dynamic> json) {
    loc = json['loc'];
    utc = json['utc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['loc'] = this.loc;
    data['utc'] = this.utc;
    return data;
  }
}

class WeatherNow {
  String? cloud;
  String? condCode;
  String? condTxt;
  String? fl;
  String? hum;
  String? pcpn;
  String? pres;
  String? tmp;
  String? vis;
  String? windDeg;
  String? windDir;
  String? windSc;
  String? windSpd;

  WeatherNow(
      {this.cloud,
      this.condCode,
      this.condTxt,
      this.fl,
      this.hum,
      this.pcpn,
      this.pres,
      this.tmp,
      this.vis,
      this.windDeg,
      this.windDir,
      this.windSc,
      this.windSpd});

  WeatherNow.fromJson(Map<String, dynamic> json) {
    // cloud = json['cloud'];
    // condCode = json['cond_code'];
    // condTxt = json['cond_txt'];
    // fl = json['fl'];
    // hum = json['hum'];
    // pcpn = json['pcpn'];
    // pres = json['pres'];
    // tmp = json['tmp'];
    // vis = json['vis'];
    // windDeg = json['wind_deg'];
    // windDir = json['wind_dir'];
    // windSc = json['wind_sc'];
    // windSpd = json['wind_spd'];

    condCode = json['weather'] != null ? json['weather'].toString() : null;
    condTxt = json['weather'] != null
        ? weatherCodes[json['weather']].toString()
        : null;
    tmp = json['temperature'] != null
        ? json['temperature']['value'].toString()
        : null;
    hum =
        json['humidity'] != null ? json['humidity']['value'].toString() : null;
    pres =
        json['pressure'] != null ? json['pressure']['value'].toString() : null;
    windSc =
        json['wind'] != null ? json['wind']['speed']['value'].toString() : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['cloud'] = this.cloud;
    data['cond_code'] = this.condCode;
    data['cond_txt'] = this.condTxt;
    data['fl'] = this.fl;
    data['hum'] = this.hum;
    data['pcpn'] = this.pcpn;
    data['pres'] = this.pres;
    data['tmp'] = this.tmp;
    data['vis'] = this.vis;
    data['wind_deg'] = this.windDeg;
    data['wind_dir'] = this.windDir;
    data['wind_sc'] = this.windSc;
    data['wind_spd'] = this.windSpd;
    return data;
  }
}

class WeatherDailyForecast {
  String? condCodeD;
  String? condCodeN;
  String? condTxtD;
  String? condTxtN;
  String? date;
  String? hum;
  String? mr;
  String? ms;
  String? pcpn;
  String? pop;
  String? pres;
  String? sr;
  String? ss;
  String? tmpMax;
  String? tmpMin;
  String? uvIndex;
  String? vis;
  String? windDeg;
  String? windDir;
  String? windSc;
  String? windSpd;

  WeatherDailyForecast(
      {this.condCodeD,
      this.condCodeN,
      this.condTxtD,
      this.condTxtN,
      this.date,
      this.hum,
      this.mr,
      this.ms,
      this.pcpn,
      this.pop,
      this.pres,
      this.sr,
      this.ss,
      this.tmpMax,
      this.tmpMin,
      this.uvIndex,
      this.vis,
      this.windDeg,
      this.windDir,
      this.windSc,
      this.windSpd});

  WeatherDailyForecast.fromJson(Map<String, dynamic> json) {
    condCodeD =
        json['weather'] != null ? json['weather']['from'].toString() : null;
    condCodeN =
        json['weather'] != null ? json['weather']['from'].toString() : null;
    condTxtD = json['weather'] != null
        ? weatherCodes[json['weather']['from']].toString()
        : null;
    condTxtN = json['weather'] != null
        ? weatherCodes[json['weather']['to']].toString()
        : null;
    date = DateFormat('yyyy-MM-dd')
        .format(DateTime.parse(json['sunRiseSet']['from']));
    tmpMax = json['temperature'] != null
        ? json['temperature']['from'].toString()
        : null;
    tmpMin = json['temperature'] != null
        ? json['temperature']['to'].toString()
        : null;
    // hum = json['hum'];
    // mr = json['mr'];
    // ms = json['ms'];
    // pcpn = json['pcpn'];
    // pop = json['pop'];
    // pres = json['pres'];
    // sr = json['sr'];
    // ss = json['ss'];
    // uvIndex = json['uv_index'];
    // vis = json['vis'];
    // windDeg = json['wind_deg'];
    // windDir = json['wind_dir'];
    // windSc = json['wind_sc'];
    // windSpd = json['wind_spd'];
    // condCodeD = json['dayweather'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['cond_code_d'] = this.condCodeD;
    data['cond_code_n'] = this.condCodeN;
    data['cond_txt_d'] = this.condTxtD;
    data['cond_txt_n'] = this.condTxtN;
    data['date'] = this.date;
    data['hum'] = this.hum;
    data['mr'] = this.mr;
    data['ms'] = this.ms;
    data['pcpn'] = this.pcpn;
    data['pop'] = this.pop;
    data['pres'] = this.pres;
    data['sr'] = this.sr;
    data['ss'] = this.ss;
    data['tmp_max'] = this.tmpMax;
    data['tmp_min'] = this.tmpMin;
    data['uv_index'] = this.uvIndex;
    data['vis'] = this.vis;
    data['wind_deg'] = this.windDeg;
    data['wind_dir'] = this.windDir;
    data['wind_sc'] = this.windSc;
    data['wind_spd'] = this.windSpd;
    return data;
  }
}

class WeatherHourly {
  String? cloud;
  String? condCode;
  String? condTxt;
  String? dew;
  String? hum;
  String? pop;
  String? pres;
  String? time;
  String? tmp;
  String? windDeg;
  String? windDir;
  String? windSc;
  String? windSpd;

  WeatherHourly(
      {this.cloud,
      this.condCode,
      this.condTxt,
      this.dew,
      this.hum,
      this.pop,
      this.pres,
      this.time,
      this.tmp,
      this.windDeg,
      this.windDir,
      this.windSc,
      this.windSpd});

  WeatherHourly.fromJson(Map<String, dynamic> json) {
    // cloud = json['cloud'];
    condCode = json['weather'].toString();
    condTxt = weatherCodes[json['weather']] ?? '';
    // dew = json['dew'];
    // hum = json['hum'];
    // pop = json['pop'];
    // pres = json['pres'];
    // TODO: 处理时区
    time = DateFormat('HH').format(
        DateTime.parse(json['wind']['datetime']).add(new Duration(hours: 8)));
    tmp = json['temperature'].toString();
    // windDeg = json['wind_deg'];
    // windDir = json['wind_dir'];
    // windSc = json['wind_sc'];
    windSpd = json['wind']['speed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    // data['cloud'] = this.cloud;
    // data['cond_code'] = this.condCode;
    data['cond_txt'] = this.condTxt;
    // data['dew'] = this.dew;
    // data['hum'] = this.hum;
    // data['pop'] = this.pop;
    // data['pres'] = this.pres;
    // data['time'] = this.time;
    // data['tmp'] = this.tmp;
    // data['wind_deg'] = this.windDeg;
    // data['wind_dir'] = this.windDir;
    // data['wind_sc'] = this.windSc;
    // data['wind_spd'] = this.windSpd;
    return data;
  }
}

class WeatherLifestyle {
  String? type;
  String? brf;
  String? txt;

  WeatherLifestyle({this.type, this.brf, this.txt});

  WeatherLifestyle.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    brf = json['brf'];
    txt = json['txt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['type'] = this.type;
    data['brf'] = this.brf;
    data['txt'] = this.txt;
    return data;
  }
}
