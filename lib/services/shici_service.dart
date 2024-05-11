// Data
import 'package:dio/dio.dart';
import 'package:flutter_weather/data/sentence_data.dart';
// 
import 'package:flutter/foundation.dart';
import 'package:flutter_weather/model/service/service.dart';

class ShiciService extends Service {
  ShiciService() {
    dio.options.baseUrl = "https://v2.jinrishici.com";
  }

  Future<String> getToken() async {
    final response = await get("/token",
        cancelToken: cancelToken);
    return await compute(_formatToken, response.data);
  }

  static String _formatToken(data) {
    return data['data'];
  }
  Future<Sentence> getSentence(String token) async {
    final response = await get("/sentence",
        cancelToken: cancelToken,
        options: Options(headers: {
          'X-User-Token': token
        }));
    return await compute(_formatSentence, response.data);
  }

  static Sentence _formatSentence(data) {
    return Sentence.fromJson(data['data']);
  }
}
