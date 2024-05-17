import 'dart:async';
// import 'dart:math';
import 'package:flutter/material.dart';
// Data
import 'package:flutter_weather/data/city_data.dart';
import 'package:flutter_weather/data/weather_data.dart';
import 'package:flutter_weather/model/data/page_module_data.dart';
import 'package:flutter_weather/models/page_modules_model.dart';
import 'package:flutter_weather/models/shared_depository.dart';
// Model
import 'package:flutter_weather/models/test_model.dart';
import 'package:flutter_weather/models/city_model.dart';
import 'package:flutter_weather/models/weather_model.dart';
import 'package:flutter_weather/utils/view_util.dart';
import 'package:flutter_weather/view/widget/custom_app_bar.dart';
import 'package:flutter_weather/views/screens/weather_city_page.dart';
// Widget
import 'package:flutter_weather/views/widgets/city_switcher.dart';
// Utils
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
// TODO:
import 'package:flutter_weather/view/page/page_state.dart';
import 'package:flutter_weather/view/weather/weather_view.dart';
import 'package:flutter_weather/generated/i18n.dart';
// import 'package:flutter_weather/model/data/mixing.dart';
// import 'package:flutter_weather/model/data/weather_air_data.dart';
// import 'package:flutter_weather/model/data/weather_data.dart';
// import 'package:flutter_weather/model/holder/event_send_holder.dart';
import 'package:flutter_weather/utils/system_util.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:flutter_weather/view/page/city_control_page.dart';
// import 'package:flutter_weather/view/page/weather_city_page.dart';
// import 'package:flutter_weather/view/weather/weather_view.dart';
// import 'package:flutter_weather/view/widget/custom_app_bar.dart';
// import 'package:flutter_weather/view/widget/weather_title_view.dart';

class WeatherPage extends StatefulWidget {
  WeatherPage({required Key? key}) : super(key: key);

  @override
  State createState() => WeatherState();
}

class WeatherState extends PageState<WeatherPage>
    with SingleTickerProviderStateMixin {
  String testString = ''; // TEST
  double pageValue = 0; // 当前城市索引页的值
  // double pageAlpha = 0; // 页面透明度
  List<City>? cityList;
  Weather? weather;
  Map<int, bool> fetchingCurrentPageWeather = {};

  // 高度动画
  late AnimationController _animationController;
  Animation<double>? _animation;

  // final _testModel = TestModel();

  // final _viewModel = WeatherViewModel();

  final _pageController = PageController(); // TODO:

  // final _pageStream = StreamController<double>();
  // final _titleAlpha = StreamController<double>();

  // @override
  // bool get bindLife => true;

  @override
  void initState() {
    debugPrint("weatherPage:initState");
    super.initState();

    // _viewModel.testString.stream
    //     .listen((data) => setState(() => testString = data));
    TestModel().testString?.listen((data) => setState(() => testString = data));

    // 翻页时，cityList 不会更新，所以这里不能触发 weather 变化
    CityModel().cityList?.listen((data) {
      debugPrint("WeatherPage:CityModel:cityList:listen: ${data.length}");
      setState(() => cityList = data);
      // debugPrint(
      //     "weatherPage:CityModel:cityList:listen:cityList: ${cityList?[pageValue.toInt()].toJson()}");
      // 城市列表发生变化时（包括第一次初始化），获取当前城市天气（CityModel 里在变化时未请求天气）
      if (cityList?[pageValue.toInt()] != null) {
        // 这里可以不用回调，而使用监听的方式，因为在 getWeather 方法里面有添加到 stream。
        WeatherModel().getWeather(cityList![pageValue.toInt()]).then((data) {
          // debugPrint("WeatherPage:CityModel:getWeather:then:${data.toJson()}");
          setState(() => weather = data);
        });
      }
    });

    WeatherModel().weather?.listen((data) {
      debugPrint("WeatherPage:WeatherModel:weather:listen: >");
      if (cityList?[pageValue.toInt()].key == data.locationKey) {
        setState(() => weather = data);
      }
    });

    // 翻页
    _pageController.addListener(() {
      setState(() {
        pageValue = _pageController.page ?? 0;
        // pageAlpha = pageValue;
      });
      debugPrint(
          "_pageController.addListener:pageValue: ${pageValue} ${pageValue.floor().abs()} ${fetchingCurrentPageWeather} ${!fetchingCurrentPageWeather.containsKey(pageValue.toInt()) || !fetchingCurrentPageWeather[pageValue.toInt()]!}");
      if (pageValue == pageValue.floor().abs()) {
        // if (!fetchingCurrentPageWeather.containsKey(pageValue.toInt()) ||
        //     !fetchingCurrentPageWeather[pageValue.toInt()]!) {
        //   debugPrint(
        //       "_pageController.addListener:getNewPageWeather: ${pageValue}");
        //   fetchingCurrentPageWeather[pageValue.toInt()] = true;
        // 翻页时获取天气
        // 先取缓存
        final currentCity = cityList?[pageValue.toInt()];
        if (currentCity != null) {
          // 这里按说不会是 null
          Weather? _weather =
              SharedDepository().getWeather(currentCity.key ?? '');
          if (_weather != null) {
            setState(() {
              weather = _weather;
            });
          }
        }
        // WeatherModel().refreshWeather(pageValue.toInt());
        // 翻页防抖截流
        // Future.delayed(Duration(seconds: 3),
        //     () => fetchingCurrentPageWeather[pageValue.toInt()] = false);
        // }
      }
    });

    // 高度动画
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animation = Tween<double>(
        begin: 0, // 初始高度
        end: 200, // 目标高度
      ).animate(_animationController);
    });

    _checkLocationPermision();

    // _viewModel.loadData(isRefresh: false);
  }

  // @override
  // void onPause() {
  //   super.onPause();

  //   _viewModel.changeHideState(true);
  // }

  // @override
  // void onResume() {
  //   super.onResume();

  //   _viewModel.changeHideState(false);
  // }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    // _viewModel.dispose();
    // _pageStream.close();
    // _controller.dispose();
    //   _titleController.dispose();
    // _titleAlpha.close();
    // subDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("weather_page:build: > ${weather?.now?.condTxt}");
    return Scaffold(
        key: scafKey,
        backgroundColor:
            _getAppBarColor(type: weather?.now?.condTxt ?? ''), // 计算底部颜色
        // TODO:
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(getAppBarHeight()),
          // TODO:
          child: AnimatedContainer(
            // color: _getAppBarColor(type: weather?.now?.condTxt ?? ''),
            color: Colors.transparent,
            duration: const Duration(seconds: 2),
            child: Stack(
              children: <Widget>[
                // 顶部城市切换指示条
                Opacity(
                  opacity: 1,
                  // TODO:
                  child: CitySwitcher(
                    cityList: cityList,
                    pageValue: pageValue,
                  ),
                ),
                // 标题栏
                CustomAppBar(
                  title: Text(""),
                  color: Colors.transparent, // TODO:
                  showShadow: false,
                  // TODO: 标题栏左侧按钮
                  // leftBtn: IconButton(
                  //   icon: Icon(
                  //     Icons.menu,
                  //     color: Colors.white,
                  //   ),
                  //   // 打开抽屉菜单
                  //   onPressed: () => EventSendHolder()
                  //       .sendEvent(tag: "homeDrawerOpen", event: true),
                  // ),
                  // TODO: 标题栏右侧按钮
                  rightBtns: [
                    IconButton(
                      icon: Icon(
                        Icons.my_location,
                        color: Colors.white,
                      ),
                      // 打开抽屉菜单
                      onPressed: () => _checkLocationPermision(),
                    ),
                    // PopupMenuButton(
                    //   icon: Icon(
                    //     Icons.more_vert,
                    //     color: Colors.white,
                    //   ),
                    //   itemBuilder: (context) => [
                    //     // PopupMenuItem(
                    //     //   value: "share",
                    //     //   child: Text(S.of(context)?.share ?? ''),
                    //     // ),
                    //     PopupMenuItem(
                    //       value: "cities",
                    //       child: Text(S.of(context)?.cityControl ?? ''),
                    //     ),
                    //     PopupMenuItem(
                    //       value: "weathers",
                    //       child: Text(S.of(context)?.weathersView ?? ''),
                    //     ),
                    //   ],
                    //   onSelected: (value) {
                    //     switch (value) {
                    //       // case "share":
                    //       //   if (pair.b == null) return;
                    //       //   WeatherSharePicker.share(context,
                    //       //       weather: pair.a,
                    //       //       air: pair.b!,
                    //       //       city: location);
                    //       //   break;
                    //       case "cities":
                    //         // push(context, page: CityControlPage());
                    //         break;
                    //       case "weathers":
                    //         _showWeathersDialog();
                    //         break;
                    //     }
                    //   },
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // TODO:
        body: AnimatedContainer(
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          padding: EdgeInsets.only(top: _animation?.value ?? 200), // 设置动画高度
          child: WeatherView(
              type: weather?.now?.condTxt ?? '', // TODO:
              color: _getAppBarColor(
                  type: weather?.now?.condTxt ?? ''), // TODO: 天气动画的背景颜色
              // hide: hideWeather!, // TODO: 关闭天气动画
              hide: false,
              // TODO:
              child: PageView.builder(
                  itemCount: cityList?.length,
                  controller: _pageController, // TODO:
                  physics: const ClampingScrollPhysics(), // TODO:
                  // TODO:
                  // onPageChanged: (index) =>
                  //     _viewModel.indexChange(index),
                  itemBuilder: (context, index) {
                    // final value = 1 - (pageValue - index).abs();
                    // return Opacity(
                    //   opacity: value >= 0 && value <= 1 ? value : 0,
                    // TODO: weather 为 null 时无需构建
                    return weather != null
                        ? WeatherCityPage(
                            key: Key("weatherCityPage${index}"),
                            index: index,
                            onScroll: (offset) {
                              // double _titleAlphaValue = 0;
                              // final height = getStatusHeight(context) +
                              //     getAppBarHeight();
                              // if (offset <= height) {
                              //   _titleAlphaValue = offset / height;
                              //   _titleAlpha.safeAdd(_titleAlphaValue);
                              // } else {
                              //   if (_titleAlphaValue == 1) return;
                              //   _titleAlphaValue = 1;
                              //   _titleAlpha.safeAdd(_titleAlphaValue);
                              // }
                            })
                        : Container();
                  })),
        ));
  }

  // 根据天气类型获取 AppBar 的颜色
  Color _getAppBarColor({required String type}) {
    final isDay = DateTime.now().hour >= 6 && DateTime.now().hour < 18;

    if (type.contains("晴") || type.contains("多云")) {
      return isDay ? const Color(0xFF51C0F8) : const Color(0xFF7F9EE9);
    } else if (type.contains("雨")) {
      if (type.contains("雪")) {
        return const Color(0XFF5697D8);
      } else {
        return const Color(0xFF7187DB);
      }
    } else if (type.contains("雪")) {
      return const Color(0xFF62B1FF);
    } else if (type.contains("冰雹")) {
      return const Color(0xFF0CB399);
    } else if (type.contains("霾")) {
      return const Color(0xFF7F8195);
    } else if (type.contains("沙") || type.contains("尘")) {
      return const Color(0xFFE99E3C);
    } else if (type.contains("雾")) {
      return const Color(0xFF8CADD3);
    } else if (type.contains("阴")) {
      return const Color(0xFF6D8DB1);
    } else {
      return isDay ? const Color(0xFF51C0F8) : const Color(0xFF7F9EE9);
    }
  }

  // TODO: 定位
  void _checkLocationPermision() async {
    // 获取经纬度
    bool serviceEnabled;
    LocationPermission permission;
    // 手机定位服务是否已启用
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 定位服务未启用
      _showBottomSheet('定位服务未开启', '请到设置中打开定位服务，以显示当前位置天气。');
      // TODO:
      // var res = await Geolocator.openLocationSettings();
      // if (!res) {
      //   // 被拒绝
      //   return null;
      // }
      CityModel().getCityByLocation(false);
    }
    // App 访问位置权限
    // LocationPermission[deniedForever|denied|whileInUse|always]
    permission = await Geolocator.checkPermission();
    debugPrint(
        "WeatherPage:_checkLocationPermision:checkPermission: ${permission}");

    if (permission == LocationPermission.deniedForever) {
      // 不允许
      _showBottomSheet('允许小鸭天气访问您的位置', '小鸭天气 App 需要访问您的地理位置，以根据您的位置显示当前的天气信息。');
      CityModel().getCityByLocation(false);
      return;
    }
    if (permission == LocationPermission.denied) {
      // 询问
      permission = await Geolocator.requestPermission();
      debugPrint(
          "WeatherPage:_checkLocationPermision:requestPermission: ${permission}");
      if (permission == LocationPermission.deniedForever) {
        _showBottomSheet(
            '允许小鸭天气访问您的位置', '小鸭天气 App 需要访问您的地理位置，以根据您的位置显示当前的天气信息。');
        CityModel().getCityByLocation(false);
        return;
      }
    }

    ToastUtil.showToast(context, '已获取新定位');
    CityModel().getCityByLocation(true);
  }

  void _showBottomSheet(String title, String content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
            ),
            margin: EdgeInsets.only(left: 12, right: 12),
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                title != ''
                    ? Text(title, style: TextStyle(fontSize: 20.0))
                    : Container(),
                Container(height: title != '' ? 16 : 0),
                Text(content, style: TextStyle(fontSize: 16.0, height: 2)),
                Container(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Colors.black26,
                        ),
                        padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 24.0),
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "取消",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(width: 16),
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          const Color(0XFF5697D8),
                        ),
                        padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 24.0),
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                      ),
                      onPressed: () {
                        // Geolocator.openLocationSettings();
                        AppSettings.openAppSettings(
                            type: AppSettingsType.location);
                        // openAppSettings();
                        // await Geolocator.openAppSettings();
                      },
                      child: Text(
                        "去设置",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // // 动态天气预览弹窗
  // void _showWeathersDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text(
  //         S.of(context)?.weathersView ?? '',
  //         style: TextStyle(
  //           fontSize: 20,
  //           color: Colors.black,
  //         ),
  //       ),
  //       contentPadding: const EdgeInsets.only(),
  //       titlePadding: const EdgeInsets.fromLTRB(20, 18, 0, 10),
  //       content: SingleChildScrollView(
  //         physics: const ClampingScrollPhysics(),
  //         padding: const EdgeInsets.only(),
  //         child: Column(
  //           children: <Widget>[
  //             _buildDialogItem(title: S.of(context)?.sunny ?? ''),
  //             _buildDialogItem(title: S.of(context)?.cloudy ?? ''),
  //             _buildDialogItem(title: S.of(context)?.overcast ?? ''),
  //             _buildDialogItem(title: S.of(context)?.rain ?? ''),
  //             _buildDialogItem(title: S.of(context)?.flashRain ?? ''),
  //             _buildDialogItem(title: S.of(context)?.snowRain ?? ''),
  //             _buildDialogItem(title: S.of(context)?.snow ?? ''),
  //             _buildDialogItem(title: S.of(context)?.hail ?? ''),
  //             _buildDialogItem(title: S.of(context)?.fog ?? ''),
  //             _buildDialogItem(title: S.of(context)?.smog ?? ''),
  //             _buildDialogItem(title: S.of(context)?.sandstorm ?? ''),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // // 动态天气预览的选项
  // Widget _buildDialogItem({required String title}) {
  //   return Material(
  //     color: Colors.white,
  //     child: InkWell(
  //       onTap: () {
  //         pop(context);
  //         // _viewModel.switchType(title);
  //       },
  //       child: Container(
  //         height: 48,
  //         padding: const EdgeInsets.only(left: 20),
  //         child: Row(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: <Widget>[
  //             Padding(
  //               padding: const EdgeInsets.only(right: 18),
  //               child: Icon(
  //                 Icons.panorama_fish_eye,
  //                 color: Colors.black54,
  //               ),
  //             ),
  //             Text(
  //               title,
  //               style: TextStyle(fontSize: 18, color: Colors.black),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // // 改变天气动画显示状态
  // void changeHideState(bool hide) {
  //   // _viewModel.changeHideState(hide);
  // }
}
