import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
// Data
import 'package:flutter_weather/model/data/page_module_data.dart';
import 'package:flutter_weather/models/page_modules_model.dart';
import 'package:flutter_weather/utils/view_util.dart';
// Widgets
import 'package:flutter_weather/view/weather/weather_view.dart';
// Utils
import 'package:geolocator/geolocator.dart';

class Empty extends StatefulWidget {
  PageType? type = PageType.BLANK;

  Empty({this.type});

  @override
  State createState() {
    return EmptyState();
  }
}

class EmptyState extends State<Empty> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(Empty oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key('empty'),
      backgroundColor: const Color(0xFF51C0F8),
      body: Stack(
        children: [
          AnimatedContainer(
            height: double.infinity,
            padding: EdgeInsets.only(top: 300), // 设置动画高度
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            child: WeatherView(
              type: "晴",
              color: Color(0xFF51C0F8),
              child: Container(),
            ),
          ),
          Container(
            height: double.infinity,
            child: Center(
              child: Stack(
                children: <Widget>[
                  // 无定位权限
                  Offstage(
                    offstage: widget.type != PageType.NO_LOCATION_PERMISSION,
                    child: _buildLocation(),
                  ),
                  // 无定位权限
                  Offstage(
                    offstage: widget.type != PageType.NO_NETWORK_PERMISSION,
                    child: _buildNetwork(),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLocation() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
      ),
      margin: EdgeInsets.all(24.0),
      padding: EdgeInsets.all(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("小鸭天气需要使用定位权限，请到设置中开启定位权限。"),
          TextButton(
            onPressed: () {
              // Geolocator.openAppSettings();
              Geolocator.openLocationSettings();
            },
            child: Text(
              "去设置",
              style: TextStyle(
                color: const Color(0xFF51C0F8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetwork() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
      ),
      margin: EdgeInsets.all(24.0),
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("请开启网络", style: TextStyle(fontSize: 20.0)),
          Container(height: 16),
          Text("小鸭天气需要需要使用网络来获取天气信息，请到设置中为小鸭天气开启网络使用权限，并确认您的网络设置，然后点击重试按钮。",
              style: TextStyle(fontSize: 16.0, height: 2)),
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
                  Geolocator.openLocationSettings();
                },
                child: Text(
                  "去设置",
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
                  _checkNetwork();
                },
                child: Text(
                  "重试",
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
    );
  }

  // 检测网络
  void _checkNetwork() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      final snackBar = SnackBar(content: Text('未连接网络'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
