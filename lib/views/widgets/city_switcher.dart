import 'dart:async';
import 'package:flutter/material.dart';
// Data
import 'package:flutter_weather/data/city_data.dart';
//
import 'package:flutter_weather/common/streams.dart';
import 'package:flutter_weather/utils/system_util.dart';

class CitySwitcher extends StatefulWidget {
  final List<City>? cityList;
  final double pageValue;

  CitySwitcher({required this.cityList, required this.pageValue});

  @override
  State createState() {
    return CitySwitcherState();
  }
}

class CitySwitcherState extends State<CitySwitcher> {
  final _paddingLeft = StreamController<double>();
  final _titleKeys = <GlobalKey>[];
  final _titleWidth = <double>[];

  Timer? _timer;
  double _currentPadding = 0;

  @override
  void initState() {
    super.initState();

    _calculateWidth();
  }

  @override
  void dispose() {
    _titleWidth.clear();
    _titleKeys.clear();
    _timer?.cancel();
    _paddingLeft.close();

    super.dispose();
  }

  @override
  void didUpdateWidget(CitySwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool isCityChange = widget.cityList?.length != oldWidget.cityList?.length;
    if (!isCityChange) {
      List.generate(widget.cityList?.length ?? 0, (index) {
        isCityChange = widget.cityList?[index] != oldWidget.cityList?[index];
      });
    }

    if (isCityChange) {
      _calculateWidth();
    } else if (_titleWidth.isNotEmpty && _titleWidth.length > 1) {
      // debugPrint(_titleWidth.toString());
      if (widget.pageValue == widget.pageValue.toInt()) {
        _calculateWidth();
      } else {
        // 往右滑动
        if (widget.pageValue > oldWidget.pageValue) {
          int target = 0;
          // debugPrint(widget.pageValue.toString());
          target = widget.pageValue.toInt() + 1;
          final move = _titleWidth[target - 1] +
              (_titleWidth[target] - _titleWidth[target - 1]) / 2;
          _currentPadding -= move * (widget.pageValue - oldWidget.pageValue);
          _paddingLeft.safeAdd(_currentPadding);
        }
        // 往左滑动
        else if (widget.pageValue < oldWidget.pageValue) {
          int target = widget.pageValue.toInt();
          final move = _titleWidth[target] +
              (_titleWidth[target + 1] - _titleWidth[target]) / 2;
          _currentPadding += move * (oldWidget.pageValue - widget.pageValue);
          _paddingLeft.safeAdd(_currentPadding);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cityList = widget.cityList;
    final pageValue = widget.pageValue;

    return Container(
      padding: EdgeInsets.only(top: getStatusHeight(context)),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // 当前城市
          Container(
            height: 28,
            child: Stack(
              children: <Widget>[
                StreamBuilder(
                  stream: _paddingLeft.stream,
                  initialData: _currentPadding,
                  builder: (context, snapshot) {
                    final left = getScreenWidth(context) / 2 + snapshot.data!;

                    return Positioned(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(cityList?.length ?? 0, (index) {
                          final value = 1 - (pageValue - index).abs();

                          return Opacity(
                            opacity: (value >= 0 &&
                                        value <= 1 &&
                                        _titleWidth.length == _titleKeys.length
                                    ? value
                                    : 0)
                                .toDouble(),
                            child: Text(
                              " ${cityList?[index].name} ",
                              key: _titleKeys[index],
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          );
                        }),
                      ),
                      left: left,
                    );
                  },
                ),
              ],
            ),
          ),

          // 指示的小点
          ((cityList?.length ?? 0) > 1)
              ? Stack(
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: cityList?.map((city) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white54),
                              width: 5,
                              height: 5,
                            );
                          }).toList() ??
                          [],
                    ),
                    Positioned(
                      left: 11 * pageValue,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        width: 5,
                        height: 5,
                      ),
                    ),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }

  // 计算每个标题宽度
  void _calculateWidth() {
    _titleKeys.clear();
    _titleKeys.addAll(widget.cityList?.map((_) => GlobalKey()) ?? []);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 100), () {
      _titleWidth.clear();
      _titleWidth.addAll(_titleKeys.map((v) => v.currentContext!.size!.width));
      _initPadding();
    });
  }

  // 计算左边距
  void _initPadding() {
    if (_titleWidth.isEmpty) return;

    double padding = 0;
    int i = 0;

    for (i = 0; i < widget.pageValue; i++) {
      padding -= _titleWidth[i];
    }
    padding -= _titleWidth[widget.pageValue.toInt()] *
        (1 - (widget.pageValue - i).abs()) /
        2;
    _currentPadding = padding;
    _paddingLeft.safeAdd(padding);
  }
}
