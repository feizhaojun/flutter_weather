// import 'package:dragable_flutter_list/dragable_flutter_list.dart';
// import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_weather/common/colors.dart';
import 'package:flutter_weather/generated/i18n.dart';
import 'package:flutter_weather/model/data/weather_data.dart';
import 'package:flutter_weather/utils/system_util.dart';
import 'package:flutter_weather/view/page/city_choose_page.dart';
import 'package:flutter_weather/view/page/page_state.dart';
import 'package:flutter_weather/view/widget/custom_app_bar.dart';
import 'package:flutter_weather/viewmodel/city_control_viewModel.dart';

class CityControlPage extends StatefulWidget {
  @override
  State createState() => CityControlState();
}

class CityControlState extends PageState<CityControlPage> {
  final _viewModel = CityControlViewModel();

  @override
  void dispose() {
    _viewModel.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scafKey,
      appBar: CustomAppBar(
        title: Text(
          S.of(context)?.cityControl ?? '',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        color: Theme.of(context).primaryColor,
        leftBtn: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => pop(context),
        ),
        rightBtns: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () async {
              final location = await push(context, page: CityChoosePage());
              if (location == null) return;

              final result = await _viewModel.addCity(location);
              if (!result) {
                showSnack(text: S.of(context)?.repeatCity ?? '');
              }
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _viewModel.cities.stream,
        builder: (context, snapshot) {
          final List<String?> cities = snapshot.data ?? [];

          return StreamBuilder(
            stream: _viewModel.weathers.stream,
            builder: (context, snapshot) {
              final List<Weather> weathers = snapshot.data ?? [];
              return ReorderableListView.builder(
                // items: cities,
                itemCount: cities.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return _buildCityItem(
                      key: ValueKey(index),
                      city: cities[index] ?? '',
                      data: weathers[index],
                      isFirst: index == 0,
                    );
                  } else {
                    return Dismissible(
                      key: Key("Dismissible${cities[index]}"),
                      child: _buildCityItem(
                        key: ValueKey(index),
                        city: cities[index] ?? '',
                        data: weathers[index],
                        isFirst: index == 0,
                      ),
                      onDismissed: (_) => _viewModel.removeCity(index),
                    );
                  }
                },
                onReorder: (int oldIndex, int newIndex) {
                  _viewModel.cityIndexChange(
                      oldIndex, oldIndex < newIndex ? newIndex - 1 : newIndex);
                  // setState(() {
                  //   final String? item = cities.removeAt(oldIndex);
                  //   cities.insert(oldIndex < newIndex ? newIndex - 1 : newIndex, item);
                  // });
                },
              );
            },
          );
        },
      ),
    );
  }

  // 城市列表Item
  Widget _buildCityItem(
      {required String city,
      required Weather data,
      required bool isFirst,
      required Key key}) {
    final now = data.now;

    return Card(
      key: key,
      shape: Border(  
        bottom: BorderSide(color: Colors.grey.shade300, width: 1.0, style: BorderStyle.solid),
      ),
      margin: const EdgeInsets.all(0),
      color: Colors.white,
      elevation: 0.0,
      child: Container(
        height: 60,
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: Row(
          children: <Widget>[
            Text(
              city,
              style: TextStyle(fontSize: 18, color: AppColor.text1),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: isFirst
                  ? Icon(
                      Icons.location_on,
                      color: Theme.of(context).primaryColor,
                    )
                  : Container(),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        now?.condTxt ?? S.of(context)?.unknown ?? '',
                        style: TextStyle(fontSize: 12, color: AppColor.text1),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          now?.tmp != null
                              ? "${now!.tmp}℃"
                              : S.of(context)?.unknown ?? '',
                          style: TextStyle(fontSize: 12, color: AppColor.text1),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Image.asset(
                      "images/${now?.condCode ?? 999}.png",
                      height: 32,
                      width: 32,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
