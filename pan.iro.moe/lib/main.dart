import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pan/pan_page.dart';

void main() async {
  _initprefs() {
    //初始化持久化数据
    Iro.prefs.getString('BDUSS') ?? Iro.prefs.setString('BDUSS', '');
    Iro.prefs.getString('STOKEN') ?? Iro.prefs.setString('STOKEN', '');
  }

  HttpOverrides.global = IroHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Iro.prefs = prefs;
  path.ini();
  _initprefs();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then(
    (_) => runZonedGuarded(
      () => runApp(MyApp()),
      (Object obj, StackTrace stack) {
        //输出错误
        debugPrint('error!$obj');
        debugPrint(stack.toString());
      },
    ),
  );
}

class path {
  static String? data;

  static Future ini() async {
    getExternalStorageDirectory().then((v) {
      path.data = v!.path;
      //保存文件路径
    });
  }
}

//忽略证书
class IroHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

//全局变量
class Iro {
  static late SharedPreferences prefs;
  static Color moe = Color(0xfffa7298);
  static Map<String, String> header = {
    'User-Agent': "", //将此值设定为接口所指定的UA，仅下载时需要
  };
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.grey,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return GetMaterialApp(
      title: '喵喵喵',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        // fontFamily: 'NotoSansSC',//字体
      ),
      home: new PanPage(),
    );
  }
}
