import 'dart:async';
import 'package:flutter_weather/common/streams.dart';
// Data
import 'package:flutter_weather/model/data/page_module_data.dart';

class PageModulesModel {
  static final PageModulesModel _instance = PageModulesModel._internal();

  factory PageModulesModel() => _instance;

  Stream<PageType>? currentPage;
  final _currentPage = StreamController<PageType>();

  PageModulesModel._internal() {
    currentPage = _currentPage.stream.asBroadcastStream();
  }

  void setPage(PageType page) {
    _currentPage.safeAdd(page);
  }

  void dispose() {
    _currentPage.close();
  }
}
