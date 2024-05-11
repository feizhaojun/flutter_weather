import 'package:flutter/material.dart';
// Utils
import 'package:flutter_weather/models/shared_depository.dart';
// Screens
import 'package:flutter_weather/views/screens/home_page.dart';
// import 'package:flutter_weather/view/page/splash_page.dart';
// TODO:
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_weather/common/colors.dart';
import 'package:flutter_weather/common/streams.dart';
import 'package:flutter_weather/generated/i18n.dart';
import 'package:flutter_weather/model/holder/event_send_holder.dart';
// import 'package:flutter_weather/model/holder/shared_depository.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  // TODO:
  Stream.value(WidgetsFlutterBinding.ensureInitialized())
      // 显示布局边框
      .doOnData((_) => debugPaintSizeEnabled = false)
      // 设置状态栏字体颜色
      .doOnData((_) => SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.black,
              systemNavigationBarDividerColor: null,
              statusBarColor: Colors.transparent,
              systemNavigationBarIconBrightness: Brightness.light,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark)))
      // 强制竖屏
      .asyncMap((_) => SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]))
      .asyncMap((_) => SharedDepository().initShared())
      .listen((_) => runApp(WeatherApp()));
}

class WeatherApp extends StatefulWidget {
  // 切换语言
  static ValueChanged<Locale>? localChange;
  // app语言信息
  static Locale? locale;

  @override
  State createState() => WeatherAppState();
}

class WeatherAppState extends State<WeatherApp> with StreamSubController {
  ThemeData theme = ThemeData();
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    // TODO:
    WeatherApp.localChange = (locale) {
      debugPrint("localChange: $locale");
      setState(() => _locale = Locale(locale.languageCode, locale.countryCode));
      WeatherApp.locale = _locale;
    };
    // TODO:
    EventSendHolder()
        .event!
        .where((pair) => pair.a == "themeChange")
        .listen((pair) => setState(
            () => theme = ThemeData(primaryColor: pair.b ?? AppColor.niagara)))
        .bindLife(this);
  }

  @override
  void dispose() {
    subDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: SplashPage(),
      home: HomePage(),
      title: "小鸭天气",
      locale: _locale, // TODO:
      theme: theme,

      // 设置地区信息
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        // 声明 Cupertino 风格的本地化代理，从而自动包含 Cupertino 相关的本地化。
        GlobalCupertinoLocalizations.delegate,
      ],

      // 国际化多语言支持
      supportedLocales: S.delegate.supportedLocales,

      // TODO: 设置语言
      localeListResolutionCallback: (locales, supports) {
        print('localeListResolutionCallback');
        // Locale? result = SharedDepository().appLocale ?? null;
        Locale? result;
        if (result == null) {
          //  TODO: 设置默认语言
          result = locales != null && locales.isNotEmpty
              ? Locale(locales[0].languageCode)
              : Locale('zh');

          final supportCodes = supports.map((v) => v.languageCode).toList();

          for (Locale locale in locales!) {
            if (supportCodes.contains(locale.languageCode)) {
              result = Locale(locale.languageCode);
              break;
            }
          }
        }

        WeatherApp.locale = result;

        return result;
      },
    );
  }
}
