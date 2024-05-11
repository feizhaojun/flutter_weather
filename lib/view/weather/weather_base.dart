import 'package:flutter/material.dart';
import 'package:flutter_weather/utils/system_util.dart';

abstract class WeatherBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    // debugPrint("fullHeight: ${getStatusHeight(context)}");
    debugPrint("WeatherBase:build > ");
    return Container(
      height: fullHeight,
      alignment: Alignment.bottomCenter,
      child: buildView(),
    );
  }

  double get fullHeight =>
      getScreenHeight(context) -
      getStatusHeight(context) -
      getAppBarHeight() -
      160;

  @protected
  Widget buildView() {
    // return null;
    return Text('null');
  }
}
