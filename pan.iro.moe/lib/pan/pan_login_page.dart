import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../IroPage/iro_widget.dart';
import '../main.dart';

class PanAuth extends StatefulWidget {
  final LoginUrl;

  PanAuth({Key? key, this.LoginUrl}) : super(key: key);

  @override
  _PanAuthState createState() => _PanAuthState();
}

class _PanAuthState extends State<PanAuth> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  WebViewController? controller;
  //因为BDUSS、STOKEN为http-only，不能通过js获取
  //使用此CookieManager获取百度网盘网页上的BDUSS、STOKEN
  //BDUSS是最主要的账号数据
  final cookieManager = WebviewCookieManager();

  @override
  void initState() {
    WebView.platform = AndroidWebView();
    super.initState();
  }

  @override
  void dispose() {
    cookieManager.clearCookies(); //清除Cookie
    super.dispose();
  }

  _auth(String url) async {
    final List<Cookie> gotCookies = await cookieManager.getCookies(url);
    int _i = 0;
    for (Cookie cookie in gotCookies) {
      if (cookie.name == 'BDUSS') {
        print('BDUSS——————${cookie.value}');
        Iro.prefs.setString('BDUSS', cookie.value);
        _i++;
      } else if (cookie.name == 'STOKEN') {
        print('STOKEN——————${cookie.value}');
        Iro.prefs.setString('STOKEN', cookie.value);
        _i++;
      }
    }
    if (_i == 2) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8, bottom: 16),
            child: Center(
              child: Row(children: [
                Container(
                  decoration: iroDecoration(circle: true),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(4, 5, 6, 5),
                    child: Center(
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Iro.moe,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: IroText(
                    data: '百度网盘账号登录',
                    align: TextAlign.left,
                  ),
                ),
              ]),
            ),
          ),
          Expanded(
            child: new SafeArea(
              top: false,
              child: WebView(
                initialUrl:
                    'https://pan.baidu.com/disk/main', //手机上在https://pan.baidu.com/登录会少一个数据
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller.complete(webViewController);
                  controller = webViewController;
                  if (Iro.prefs.getString('BDUSS') == '') {
                    Iro.prefs.setString('STOKEN', '');
                  }
                },
                onPageFinished: (String url) async {
                  _auth(url);
                },
                gestureNavigationEnabled: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
