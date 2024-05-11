import 'package:flutter/material.dart';
// Common
import 'package:flutter_weather/common/colors.dart';
// Data
import 'package:flutter_weather/data/weather_data.dart';
import 'package:flutter_weather/data/sentence_data.dart';
import 'package:flutter_weather/models/shared_depository.dart';
// Models
import 'package:flutter_weather/models/city_model.dart';
import 'package:flutter_weather/models/weather_model.dart';
// import 'package:flutter_weather/models/shici_model.dart';
// Services
import 'package:flutter_weather/services/shici_service.dart';
//
// import 'package:flutter_weather/utils/aqi_util.dart';
import 'package:flutter_weather/generated/i18n.dart';
import 'package:flutter_weather/utils/system_util.dart';
import 'package:flutter_weather/view/page/page_state.dart';
import 'package:flutter_weather/view/weather/weather_base.dart';
// import 'package:flutter_weather/view/widget/circle_air_view.dart';
// import 'package:flutter_weather/view/widget/loading_view.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../weather/weather_base.dart';

class WeatherCityPage extends StatefulWidget {
  final int index;
  final ValueChanged<double> onScroll;

  WeatherCityPage({Key? key, required this.index, required this.onScroll})
      : super(key: key);

  @override
  State createState() => WeatherCityState();
}

class WeatherCityState extends PageState<WeatherCityPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  Weather? weather;
  Sentence? sentence;

  late double fullHeight;
  late double positionedHeight;
  double sentenceOpacity = 1;
  // 高度动画
  late AnimationController _animationController;
  Animation<double>? _animation;

  final _shiciService = ShiciService();

  final _scrollController = ScrollController();
  // final _airKey = GlobalKey<CircleAirState>();

  // WeatherCityViewModel? _viewModel;

  // TODO:
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    debugPrint("WeatherCityPage:initState: >");
    super.initState();

    final currentCity = SharedDepository().cityList?[widget.index];
    // final weatherListening = false;

    fullHeight = getScreenHeight(this.context) -
        getStatusHeight(context) -
        getAppBarHeight();
    positionedHeight = fullHeight * 0.4;

    // 获取天气
    WeatherModel().weather?.listen((data) {
      // weatherListening = t
      debugPrint("WeatherCityPage:WeatherModel:weather:listen: > ${data}");
      if (currentCity?.key == data.locationKey) {
        setState(() => weather = data);
      }
      if (weather != null) {
        _animationController.forward(); // 开始动画
      }
    });
    // 初次还没建立 stream 监听，先从缓存取本页（key 为城市代码）天气
    if (currentCity != null) {
      // 这里按说不会是 null
      Weather? _weather = SharedDepository().getWeather(currentCity.key ?? '');
      if (_weather != null) {
        setState(() {
          weather = _weather;
        });
      }
    }

    // Future.delayed(Duration(seconds: 10),
    //     () => WeatherModel().refreshWeather(widget.index, context: context));
    // Future.delayed(Duration(seconds: 20),
    //     () => WeatherModel().refreshWeather(widget.index, context: context));

    if (widget.index == 0) {
      // ShiciModel().sentence?.listen((data) {
      //   debugPrint(
      //       "weather_city_page:ShiciModel:sentence:listen: ${data.toJson()}");
      //   setState(() => sentence = data);
      // });
      // TODO: Service 应该放在 Model，其实是把 Model 同时当作 Action，如果只有一个页面使用此 service，就没有必要。
      // TODO: 获取诗词 getSentence 改造重复代码
      // 取 token
      String? shiciToken = SharedDepository().getString('shiciToken');
      if (shiciToken == null) {
        _shiciService.getToken().then((token) {
          SharedDepository().setString('shiciToken', token);
          _shiciService
              .getSentence(token)
              .then((res) => setState(() => sentence = res));
        });
      } else {
        _shiciService
            .getSentence(shiciToken)
            .then((res) => setState(() => sentence = res));
      }
    }

    // 高度动画
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animation = Tween<double>(
        begin: fullHeight, // 初始高度
        end: fullHeight - 178, // 目标高度
      ).animate(_animationController);
    });

    // 页面滚动
    _scrollController.addListener(() {
      debugPrint(
          "weather_city_page:_scrollController:addListener: ${_scrollController.offset}");
      setState(() => positionedHeight =
          fullHeight * (0.4 - _scrollController.offset / 4000));
      double _sentenceOpacity = 1 - (_scrollController.offset - 276) / 100;
      setState(() => sentenceOpacity = _sentenceOpacity < 0
          ? 0
          : (_sentenceOpacity > 1 ? 1 : _sentenceOpacity));
      // TODO:
      // widget.onScroll(_scrollController.offset);
      // if (_scrollController.offset >= 320) {
      //   _airKey.currentState!.startAnim();
      // }
    });

    // _viewModel = WeatherCityViewModel(index: widget.index)
    //   // ..perStatus
    //   //     .stream
    //   //     .where((status) => status == PermissionStatus.denied)
    //   //     .listen((_) => showSnack(
    //   //         text: S.of(context)?.locationError ?? '',
    //   //         duration: const Duration(days: 1),
    //   //         action: SnackBarAction(
    //   //           label: S.of(context)?.setting ?? '',
    //   //           // TODO:
    //   //           onPressed: () => {},
    //   //           // onPressed: PermissionHandler().openAppSettings,
    //   //         )))
    //   //     .bindLife(this)
    //   ..error
    //       .stream
    //       .where((b) => b)
    //       .listen((_) => networkError(
    //           errorText: S.of(context)?.weatherFail, retry: _viewModel!.reload))
    //       .bindLife(this);
  }

  @override
  void dispose() {
    // _viewModel!.dispose();
    _animationController.dispose();
    _shiciService.dispose();
    _scrollController.dispose();
    // subDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    debugPrint("weather_city_page:build: >");
    // 整体最高温度
    int maxTemp = -60;
    // 整体最低温度
    int minTemp = 60;
    if (weather?.dailyForecast != null) {
      weather?.dailyForecast?.forEach((daily) {
        final max = int.parse("${daily.tmpMax ?? -100}");
        final min = int.parse("${daily.tmpMin ?? 100}");
        if (max > maxTemp) {
          maxTemp = max;
        }
        if (min < minTemp) {
          minTemp = min;
        }
      });
    }
    return Scaffold(
      key: Key("weatherCityPageScaf${widget.index}"),
      backgroundColor: Colors.transparent,
      // TODO:
      // body: LoadingView(
      //   loadingStream: _viewModel!.isLoading.stream,
      body: RefreshIndicator(
        // TODO:
        onRefresh: () =>
            WeatherModel().refreshWeather(widget.index, context: context),
        child: Stack(
          children: [
            // 上半部分天气详情
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: positionedHeight,
              child: Container(
                color: Colors.transparent,
                alignment: Alignment.center,
                // TODO: 修改一下 _buildContent 这个名字
                child: _buildContent(
                  now: weather?.now,
                  daily: weather?.dailyForecast?[1] ?? WeatherDailyForecast(),
                  data: weather,
                ),
              ),
            ),

            // 逐小时天气和未来几天天气
            weather != null
                ? ListView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.only(),
                    controller: _scrollController,
                    children: <Widget>[
                      // AnimatedContainer(
                      //   duration: const Duration(seconds: 2),
                      //   curve: Curves.easeInOut,
                      //   height: _animation?.value, // 设置动画高度
                      // ),
                      // 背景透明实现列表顶部 Padding
                      Container(
                        height: getScreenHeight(context) -
                            getStatusHeight(context) -
                            getAppBarHeight() -
                            172,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16))),
                        child: Column(
                          children: <Widget>[
                            // 降水预报
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(
                                  left: 20, top: 16, bottom: 16),
                              child: Text(
                                weather?.precipitation ?? '',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 14, color: AppColor.text2),
                              ),
                            ),
                            // 横向滚动显示每小时天气
                            Container(
                              height: 110,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: weather?.hourly?.length ?? 0,
                                padding: const EdgeInsets.only(),
                                itemBuilder: (context, index) {
                                  return _buildHourItem(
                                      hourly: weather?.hourly?[index]);
                                },
                              ),
                            ),

                            Divider(color: AppColor.line),

                            // 空气质量
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(
                                  left: 20, top: 16, bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "空气质量 ${getAqiStr(weather?.aqi?.aqi)} - AQI ${weather?.aqi?.aqi}",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: 16, color: AppColor.text2),
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 8)),
                                  Text(
                                    "${weather?.aqi?.suggest}",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: 14, color: AppColor.text3),
                                  ),
                                ],
                              ),
                            ),

                            Divider(color: AppColor.line),

                            // 一周天气预测
                            Container(
                              margin: EdgeInsets.only(top: 8),
                              height: 240,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: weather?.dailyForecast?.length ?? 0,
                                padding: const EdgeInsets.only(),
                                itemBuilder: (context, index) {
                                  return weather?.dailyForecast?[index] != null
                                      ? _buildDailyItem(
                                          daily: weather!.dailyForecast![index],
                                          maxTemp: maxTemp,
                                          minTemp: minTemp)
                                      : null;
                                },
                              ),
                            ),

                            // Divider(color: AppColor.line),

                            // // 中间显示pm2.5等情况的区域
                            // Container(
                            //   height: 166,
                            //   child: Row(
                            //     children: <Widget>[
                            //       Expanded(
                            //         child: Padding(
                            //           padding: const EdgeInsets.only(
                            //               left: 16, right: 16),
                            //           child: CircleAirView(
                            //             key: _airKey,
                            //             aqi: double.parse(
                            //                 air?.airNowCity?.aqi ?? "0"),
                            //             qlty: air?.airNowCity?.qlty ?? "",
                            //           ),
                            //         ),
                            //       ),
                            //       Expanded(
                            //         child: Column(
                            //           mainAxisAlignment:
                            //               MainAxisAlignment.center,
                            //           children: <Widget>[
                            //             _buildPm25Item(
                            //               eName: "PM2.5",
                            //               name: S.of(context)?.pm25,
                            //               num: air?.airNowCity?.pm25 ?? "0",
                            //             ),
                            //             Padding(
                            //                 padding:
                            //                     const EdgeInsets.only(top: 18)),
                            //             _buildPm25Item(
                            //               eName: "SO2",
                            //               name: S.of(context)?.so2,
                            //               num: air?.airNowCity?.so2 ?? "0",
                            //             ),
                            //             Padding(
                            //                 padding:
                            //                     const EdgeInsets.only(top: 18)),
                            //             _buildPm25Item(
                            //               eName: "CO",
                            //               name: S.of(context)?.co,
                            //               num: air?.airNowCity?.co ?? "0",
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //       Expanded(
                            //         child: Column(
                            //           mainAxisAlignment:
                            //               MainAxisAlignment.center,
                            //           children: <Widget>[
                            //             _buildPm25Item(
                            //               eName: "PM10",
                            //               name: S.of(context)?.pm10,
                            //               num: air?.airNowCity?.pm10 ?? "0",
                            //             ),
                            //             Padding(
                            //                 padding:
                            //                     const EdgeInsets.only(top: 18)),
                            //             _buildPm25Item(
                            //               eName: "NO2",
                            //               name: S.of(context)?.no2,
                            //               num: air?.airNowCity?.no2 ?? "0",
                            //             ),
                            //             Padding(
                            //                 padding:
                            //                     const EdgeInsets.only(top: 18)),
                            //             _buildPm25Item(
                            //               eName: "O3",
                            //               name: S.of(context)?.o3,
                            //               num: air?.airNowCity?.o3 ?? "0",
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),

                            // Divider(color: AppColor.line),

                            // // 最下面两排空气舒适度
                            // // 第一排
                            // Container(
                            //   height: 100,
                            //   alignment: Alignment.center,
                            //   child: Row(
                            //     children: <Widget>[
                            //       _buildSoftItem(
                            //         url: "images/air_soft_1.png",
                            //         lifestyle: data?.lifestyle != null
                            //             ? data?.lifestyle![7]
                            //             : null,
                            //       ),
                            //       _buildSoftItem(
                            //         url: "images/air_soft_2.png",
                            //         lifestyle: data?.lifestyle != null
                            //             ? data?.lifestyle![0]
                            //             : null,
                            //       ),
                            //       _buildSoftItem(
                            //         url: "images/air_soft_3.png",
                            //         lifestyle: data?.lifestyle != null
                            //             ? data?.lifestyle![6]
                            //             : null,
                            //       ),
                            //       _buildSoftItem(
                            //         url: "images/air_soft_4.png",
                            //         lifestyle: data?.lifestyle != null
                            //             ? data?.lifestyle![1]
                            //             : null,
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            // // 第二排
                            // Container(
                            //   margin: const EdgeInsets.only(bottom: 6),
                            //   height: 100,
                            //   alignment: Alignment.center,
                            //   child: Row(
                            //     children: <Widget>[
                            //       _buildSoftItem(
                            //         url: "images/air_soft_5.png",
                            //         lifestyle: data?.lifestyle != null
                            //             ? data?.lifestyle![2]
                            //             : null,
                            //       ),
                            //       _buildSoftItem(
                            //         url: "images/air_soft_6.png",
                            //         lifestyle: data?.lifestyle != null
                            //             ? data?.lifestyle![3]
                            //             : null,
                            //       ),
                            //       _buildSoftItem(
                            //         url: "images/air_soft_7.png",
                            //         lifestyle: data?.lifestyle != null
                            //             ? data?.lifestyle![4]
                            //             : null,
                            //       ),
                            //       _buildSoftItem(
                            //         url: "images/air_soft_8.png",
                            //         lifestyle: data?.lifestyle != null
                            //             ? data?.lifestyle![5]
                            //             : null,
                            //       ),
                            //     ],
                            //   ),
                            // ),

                            // // 最下面"数据来源说明"
                            // Container(
                            //   color: AppColor.shadow,
                            //   alignment: Alignment.center,
                            //   padding: const EdgeInsets.only(top: 6, bottom: 6),
                            //   child: Text(
                            //     S.of(context)?.dataSource ?? '',
                            //     style: TextStyle(
                            //       fontSize: 12,
                            //       color: AppColor.text2,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.green[50],
                        child: SafeArea(
                          child: Container(
                            height: 0,
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  // 最上面的天气详情
  Widget _buildContent(
      {WeatherNow? now, WeatherDailyForecast? daily, Weather? data}) {
    String content = sentence?.content ?? '';
    String newSentence =
        content.replaceAllMapped(RegExp(r'([。？！])'), (Match m) => '${m[1]}\n');
    List<String> sentenceList = newSentence.split(RegExp(r'\n'));
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // 当前温度、天气类型、最高温、最低温
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  "${now?.tmp ?? 0}°",
                  style: TextStyle(fontSize: 70, color: Colors.white),
                ),
              ],
            ),
            Padding(padding: const EdgeInsets.only(left: 10)),
            Column(
              children: <Widget>[
                Text(
                  now?.condTxt ?? "",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontFamily: 'JLQJJT',
                  ),
                ),
                Text(
                  "↑${daily?.tmpMax ?? 0}℃",
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
                Text(
                  "↓${daily?.tmpMin ?? 0}℃",
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
        Padding(padding: const EdgeInsets.only(top: 6)),
        // 湿度、风速、气压
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  getAqiStr(weather?.aqi?.aqi),
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  // TODO:
                  // S.of(context)?.hum ?? '',
                  '空气质量',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16),
              width: 1,
              height: 25,
              color: Colors.white,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "${now?.hum ?? 0}％",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  // TODO:
                  // S.of(context)?.hum ?? '',
                  '湿度',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16),
              width: 1,
              height: 25,
              color: Colors.white,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  // S.of(context)?.windScValue("${now?.windSc ?? 0}") ?? '',
                  "${now?.windSc ?? 0} km/h",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  now?.windDir ?? "风速",
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16),
              width: 1,
              height: 25,
              color: Colors.white,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "${now?.pres ?? 0} hPa",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  // S.of(context)?.pres ?? '',
                  '气压',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
        Opacity(
          opacity: sentenceOpacity,
          child: Container(
            margin: EdgeInsets.only(top: 40, left: 16, right: 16),
            // height: 200,
            // width:'80%',
            child: Wrap(
              children: sentenceList.map((item) {
                String newItem = item.replaceAllMapped(
                    RegExp(r'([，、])'), (Match m) => '${m[1]}\n');
                List<String> itemList = newItem.split(RegExp(r'\n'));
                return Wrap(
                  children: itemList.map((item2) {
                    return Text(
                      item2,
                      style: TextStyle(
                          fontFamily: 'JLQJJT',
                          color: Colors.white,
                          fontSize: 28.0),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );

    // Container(
    //   margin: EdgeInsets.only(top: 40, left: 16, right: 16),
    //   height: 200,
    //   child: data != null ? _buildWeekWeather(data: data) : Text('没有数据'),
    // ),
  }

  // 一周天气预测
  // Widget _buildWeekWeather({required Weather data}) {
  //   // final style = TextStyle(color: Colors.black, fontSize: 10);
  //   // return Row(
  //   // mainAxisAlignment: MainAxisAlignment.spaceAround,
  //   // children: data.dailyForecast != null
  //   //     ? data.dailyForecast!.map((daily) {
  //   //             return Container(
  //   // decoration: BoxDecoration(
  //   //                 color: Colors.white.withOpacity(0.4),
  //   //                 borderRadius: BorderRadius.circular(16),
  //   //               ),
  //   //               margin: EdgeInsets.only(left: 8, right: 8),
  //   //               padding: EdgeInsets.all(16),
  //   //               height: 200,
  //   //               child: Column(
  //   //                 crossAxisAlignment: CrossAxisAlignment.center,
  //   //                 children: <Widget>[
  //   //                   // 星期
  //   //                   Text(
  //   //                     _getWeekday(date: daily.date ?? ""),
  //   //                     style: style,
  //   //                   ),
  //   //                   // 天气图片
  //   //                   Padding(
  //   //                     padding: const EdgeInsets.only(top: 8, bottom: 8),
  //   //                     child: Image.asset(
  //   //                       "images/${daily.condCodeD ?? 0}.png",
  //   //                       height: 30,
  //   //                       width: 30,
  //   //                     ),
  //   //                   ),
  //   //                   // 天气文字
  //   //                   Text(
  //   //                     daily.condTxtD ?? "",
  //   //                     style: style,
  //   //                   ),
  //   //                   // 温度
  //   //                   Expanded(
  //   //                     child: daily.tmpMin != null && daily.tmpMax != null
  //   //                         ? Column(
  //   //                             crossAxisAlignment: CrossAxisAlignment.center,
  //   //                             children: <Widget>[
  //   //                               Expanded(
  //   //                                 child: Container(),
  //   //                                 flex: (maxTemp - int.parse(daily.tmpMax!))
  //   //                                     .abs(),
  //   //                               ),
  //   //                               Padding(
  //   //                                 padding:
  //   //                                     const EdgeInsets.only(top: 8, bottom: 2),
  //   //                                 child: Text(
  //   //                                   "${daily.tmpMax}℃",
  //   //                                   style: TextStyle(
  //   //                                       color: Colors.black87, fontSize: 10),
  //   //                                 ),
  //   //                               ),
  //   //                               Expanded(
  //   //                                 child: Container(
  //   //                                   width: 8,
  //   //                                   decoration: BoxDecoration(
  //   //                                       color: const Color(0xffdde1e2),
  //   //                                       borderRadius: BorderRadius.circular(3)),
  //   //                                 ),
  //   //                                 flex: int.parse(daily.tmpMax!) -
  //   //                                     int.parse(daily.tmpMin!),
  //   //                               ),
  //   //                               Padding(
  //   //                                 padding:
  //   //                                     const EdgeInsets.only(top: 2, bottom: 8),
  //   //                                 child: Text(
  //   //                                   "${daily.tmpMin}℃",
  //   //                                   style: TextStyle(
  //   //                                       color: Colors.black87, fontSize: 10),
  //   //                                 ),
  //   //                               ),
  //   //                               Expanded(
  //   //                                 child: Container(),
  //   //                                 flex: (minTemp - int.parse(daily.tmpMin!))
  //   //                                     .abs(),
  //   //                               ),
  //   //                             ],
  //   //                           )
  //   //                         : Container(),
  //   //                   ),
  //   //                 ],
  //   //               ),
  //   //             );
  //   // }).toList()
  //   // : const [],
  //   // );
  // }

  Widget _buildDailyItem(
      {required WeatherDailyForecast daily, int maxTemp = 0, int minTemp = 0}) {
    final style = TextStyle(color: Colors.black, fontSize: 10);
    return Container(
      // decoration: BoxDecoration(
      //   color: Colors.white.withOpacity(0.4),
      //   borderRadius: BorderRadius.circular(16),
      // ),
      margin: EdgeInsets.only(left: 4, right: 4),
      padding: EdgeInsets.only(top: 16, left: 16, right: 16),
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // 星期
          Text(
            _getWeekday(date: daily.date ?? ""),
            style: style,
          ),
          // 天气图片
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Image.asset(
              "images/${daily.condCodeD ?? 999}.png",
              height: 30,
              width: 30,
            ),
          ),
          // 天气文字
          Text(
            daily.condTxtD ?? "",
            style: style,
          ),
          // 温度
          Expanded(
            child: daily.tmpMin != null && daily.tmpMax != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Container(),
                        flex: (maxTemp - int.parse(daily.tmpMax!)).abs(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 2),
                        child: Text(
                          "${daily.tmpMax}℃",
                          style: TextStyle(color: Colors.black87, fontSize: 10),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: 8,
                          decoration: BoxDecoration(
                              color: const Color(0xffdde1e2),
                              borderRadius: BorderRadius.circular(3)),
                        ),
                        flex:
                            int.parse(daily.tmpMax!) - int.parse(daily.tmpMin!),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 2, bottom: 8),
                        child: Text(
                          "${daily.tmpMin}℃",
                          style: TextStyle(color: Colors.black87, fontSize: 10),
                        ),
                      ),
                      Expanded(
                        child: Container(),
                        flex: (minTemp - int.parse(daily.tmpMin!)).abs(),
                      ),
                    ],
                  )
                : Container(),
          ),
          // 夜间天气图片
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Image.asset(
              "images/${daily.condCodeN ?? 999}${int.parse(daily.condCodeN ?? '999') < 2 ? "_night" : ""}.png",
              height: 30,
              width: 30,
            ),
          ),
        ],
      ),
    );
  }

  // 每小时天气的Item
  Widget _buildHourItem({WeatherHourly? hourly}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "${hourly?.tmp ?? 0}°",
          style: TextStyle(
              fontSize: 14, color: AppColor.text2, fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Image.asset(
            "images/${hourly?.condCode ?? 999}.png",
            height: 30,
            width: 30,
          ),
        ),
        Text(
          (hourly?.time ?? "-") + "时",
          style: TextStyle(
            color: AppColor.text2,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // TODO: 根据日期返回星期几
  String _getWeekday({required String date}) {
    final weekDate = DateTime.parse(date);
    if (weekDate.day == DateTime.now().day) {
      return S.of(context)?.today ?? '';
    }
    if (weekDate.day == DateTime.now().add(new Duration(days: -1)).day) {
      return '昨天';
    }
    if (weekDate.day == DateTime.now().add(new Duration(days: 1)).day) {
      return '明天';
    }
    switch (weekDate.weekday) {
      case DateTime.monday:
        return S.of(context)?.monday ?? '';
      case DateTime.tuesday:
        return S.of(context)?.tuesday ?? '';
      case DateTime.wednesday:
        return S.of(context)?.wednesday ?? '';
      case DateTime.thursday:
        return S.of(context)?.thursday ?? '';
      case DateTime.friday:
        return S.of(context)?.friday ?? '';
      case DateTime.saturday:
        return S.of(context)?.saturday ?? '';
      case DateTime.sunday:
        return S.of(context)?.sunday ?? '';
    }
    return "";
  }

  // // 最下面空气舒适度Item
  // // [url] 图片的位置
  // Widget _buildSoftItem({String? url, WeatherLifestyle? lifestyle}) {
  //   return Expanded(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: <Widget>[
  //         Image.asset(
  //           url!,
  //           height: 40,
  //           width: 40,
  //         ),
  //         Padding(
  //           padding: const EdgeInsets.only(top: 5, bottom: 1),
  //           child: Text(
  //             lifestyle?.brf ?? "",
  //             style: TextStyle(fontSize: 12, color: Colors.black),
  //           ),
  //         ),
  //         Text(
  //           _getSoftName(type: lifestyle?.type ?? ""),
  //           style: TextStyle(
  //             fontSize: 10,
  //             color: AppColor.text2,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  // // 根据[type] 返回舒适度的名称
  // String _getSoftName({required String type}) {
  //   switch (type) {
  //     case "air":
  //       return S.of(context)?.air ?? '';
  //     case "cw":
  //       return S.of(context)?.cw ?? '';
  //     case "uv":
  //       return S.of(context)?.uv ?? '';
  //     case "trav":
  //       return S.of(context)?.trav ?? '';
  //     case "sport":
  //       return S.of(context)?.sport ?? '';
  //     case "drsg":
  //       return S.of(context)?.drsg ?? '';
  //     case "comf":
  //       return S.of(context)?.comf ?? '';
  //     case "flu":
  //       return S.of(context)?.flu ?? '';
  //   }
  //   return "";
  // }

  // // 中间显示pm2.5的item
  // // [eName] 英文简称
  // // [name] 中文名
  // // [num] 数值
  // Widget _buildPm25Item(
  //     {required String eName, required name, required String num}) {
  //   final style = TextStyle(fontSize: 10, color: AppColor.text2);
  //   final numValue = double.parse(num);
  //   return Container(
  //     margin: const EdgeInsets.only(right: 12),
  //     child: Stack(
  //       children: <Widget>[
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: <Widget>[
  //             Text(
  //               eName,
  //               style: style,
  //             ),
  //             Text(
  //               name ?? '',
  //               style: style,
  //             ),
  //             Container(
  //               margin: const EdgeInsets.only(top: 3),
  //               height: 2,
  //               color: AqiUtil.getAqiColor(numValue),
  //             )
  //           ],
  //         ),
  //         Container(
  //           margin: const EdgeInsets.only(top: 8),
  //           alignment: Alignment.bottomRight,
  //           child: Text(
  //             num,
  //             style: TextStyle(
  //               fontSize: 16,
  //               color: AppColor.text2,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  String getAqiStr(String? aqi) {
    if (aqi == null) {
      return '';
    }
    final num = double.parse(aqi);
    if (num > 0 && num <= 50) {
      return '优';
    } else if (num > 50 && num <= 100) {
      return '良';
    } else if (num > 100 && num <= 150) {
      return '轻度污染';
    } else if (num > 150 && num <= 200) {
      return '中度污染';
    } else if (num > 200 && num <= 300) {
      return '重度污染';
    } else if (num > 300) {
      return '严重污染';
    }
    return '';
  }
}
