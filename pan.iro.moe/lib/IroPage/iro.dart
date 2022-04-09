import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import 'iro_widget.dart';

//获取文件大小字符串
String iroByte(_size) {
  if (_size == null) return '';
  int _sirank = 0;
  _size = _size is String ? (int.parse(_size) * 10) : _size * 10;
  while (_size > 9999) {
    _size = _size ~/ 1024;
    _sirank++;
  }
  _size = _size / 10;
  if (_sirank == 0) {
    return '$_size B';
  } else if (_sirank == 1) {
    return '$_size K';
  } else if (_sirank == 2) {
    return '$_size M';
  } else if (_sirank == 3) {
    return '$_size G';
  } else {
    return 'Unknown';
  }
}

//格式化时间戳
String iroDate(_date) {
  var date = new DateTime.fromMillisecondsSinceEpoch(_date * 1000);
  var formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  return formatter.format(date);
}

//弹窗，此处留有有较多无用的参数
iroDia(BuildContext context,
    {String title = '',
    String data = '',
    String? btText,
    dynamic Function()? press,
    Widget? body,
    bool force = false,
    double? width,
    String? cancelText,
    dynamic Function()? cancelPress}) {
  if (press == null && btText != null) press = () {};
  if (cancelText == null) cancelPress = null;
  AwesomeDialog(
    dialogBackgroundColor: Colors.white,
    useRootNavigator: force,
    width: width == null ? MediaQuery.of(context).size.width : width,
    context: context,
    headerAnimationLoop: false,
    dialogType: DialogType.NO_HEADER,
    dialogBorderRadius: BorderRadius.all(
      Radius.circular(16),
    ),
    btnOkColor: Iro.moe,
    showCloseIcon: false,
    closeIcon: Icon(
      Icons.close_rounded,
      color: Iro.moe,
    ),
    borderSide: BorderSide(
        style: BorderStyle.none, color: Colors.transparent, width: 0),
    animType: AnimType.BOTTOMSLIDE,
    dismissOnBackKeyPress: !force,
    btnOkText: btText,
    btnOkOnPress: press,
    btnCancelText: cancelText,
    btnCancelColor: Colors.grey,
    btnCancelOnPress: cancelPress,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(5),
            child: IroText(
              data: title,
              size: 20,
              mline: 1,
            ),
          ),
          body == null
              ? Padding(
                  padding:
                      EdgeInsets.fromLTRB(5, 10, 5, btText == null ? 10 : 0),
                  child: IroText(
                    mline: null,
                    data: data,
                    size: 15,
                    color: Colors.black,
                    align: TextAlign.left,
                  ),
                )
              : body
        ],
      ),
    ),
  )..show();
}
