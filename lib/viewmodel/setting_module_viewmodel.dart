import 'dart:async';
import 'dart:convert';

import 'package:flutter_weather/model/data/page_module_data.dart';
import 'package:flutter_weather/model/holder/shared_depository.dart';
import 'package:flutter_weather/viewmodel/viewmodel.dart';

class SettingModuleViewModel extends ViewModel {
  final pageModules = StreamController<List<dynamic>>();

  final List<dynamic> _cacheModules = [];

  SettingModuleViewModel() {
    _cacheModules.addAll(SharedDepository().pageModules);
    pageModules.safeAdd(_cacheModules);
  }

  // 拖动后改变列表中元素位置
  void indexChange(int before, int after) {
    final beforeModule = _cacheModules[before];
    _cacheModules.removeAt(before);
    _cacheModules.insert(after, beforeModule);

// TODO:
    // SharedDepository().setPageModules(_cacheModules);
    pageModules.safeAdd(_cacheModules);
  }

  // 每个module是否开启
  void valueChange(bool open, {required PageType page}) {
    _cacheModules.firstWhere((v) => v.page == page).open = open;
    // debugLog(jsonEncode(_cacheModules));
    // TODO:
    // SharedDepository().setPageModules(_cacheModules);
    pageModules.safeAdd(_cacheModules);
  }

  @override
  void dispose() {
    _cacheModules.clear();

    pageModules.close();

    super.dispose();
  }
}
