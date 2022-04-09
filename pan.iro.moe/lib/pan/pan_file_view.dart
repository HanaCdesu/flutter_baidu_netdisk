import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pan_iro_moe/pan/model/PanFileModel.dart';

import '../IroPage/iro.dart';
import '../IroPage/iro_widget.dart';
import '../api/IroApi.dart';
import '../main.dart';

class PanFileListView extends StatelessWidget {
  const PanFileListView(
      {Key? key, required this.bdDiskFile, required this.dirCallBack})
      : super(key: key);
  final PanFile bdDiskFile;
  final Function dirCallBack;

  //指定获取对应的缩略图
  String? _img({
    bool icon = false,
    bool url3 = false,
    bool url2 = false,
    bool url1 = false,
  }) {
    if (bdDiskFile.thumbs != null) {
      String _show = '';
      if (bdDiskFile.thumbs!.icon != null && icon) {
        _show = bdDiskFile.thumbs!.icon!;
      } else if (bdDiskFile.thumbs!.url1 != null && url1) {
        _show = bdDiskFile.thumbs!.url1!;
      } else if (bdDiskFile.thumbs!.url2 != null && url2) {
        _show = bdDiskFile.thumbs!.url2!;
      } else if (bdDiskFile.thumbs!.url3 != null && url3) {
        _show = bdDiskFile.thumbs!.url3!;
      }
      return _show;
    }
    return null;
  }

  //缩略图
  Widget _icon({
    bool icon = false,
    bool url3 = false,
    bool url2 = false,
    bool url1 = false,
  }) {
    Widget result = FileIcon(
      size: 32,
      file: bdDiskFile.file,
      folder: bdDiskFile.isDir == 1,
    );
    if (bdDiskFile.isDir != 1) {
      String ext = bdDiskFile.file.split('.').last;
      List img = ["jpg", "jpeg", "gif", "bmp", "png", "svg", "ico", "webp"];
      List video = ["flv", "avi", "mp4", "mkv", "m4v", "m3u8", "swf"];
      if (img.contains(ext) || video.contains(ext)) {
        String? _show = _img(icon: icon, url1: url1, url2: url2, url3: url3);
        if (_show != null)
          result = IroImg(
            url: _show,
          );
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Row(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
          child: SizedBox(
            width: 50,
            child: AspectRatio(
              aspectRatio: 1,
              child: _icon(url1: true),
            ),
          ),
        ),
        SizedBox(width: 8),
        Container(
          width: MediaQuery.of(context).size.width - 50 - 8 - 48,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IroText(
                data: bdDiskFile.file,
                size: 14,
                minFontSize: 14,
                mline: 3,
                align: TextAlign.left,
                fontWeight: FontWeight.bold,
              ),
              IroText(
                data: iroDate(bdDiskFile.date) +
                    (bdDiskFile.isDir == 1
                        ? ''
                        : "  " + iroByte(bdDiskFile.size)),
                size: 12,
                mline: 1,
                align: TextAlign.left,
              )
            ],
          ),
        ),
      ],
    );

    return InkWell(
      child: _img(url2: true) == null
          ? body
          : IroContainer(
              child: body,
              img: _img(url2: true)!,
              height: 50,
              size: 1.6,
              top: -10,
            ),
      onTap: () async {
        if (bdDiskFile.isDir == 0) {
          String _data = '''
文件大小：${iroByte(bdDiskFile.size)}
fI：${bdDiskFile.fsId}
MD5：${bdDiskFile.md5}
绝对路径：${bdDiskFile.path}
''';
          iroDia(
            context,
            title: bdDiskFile.file,
            body: Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * .5),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(5, 10, 5, 0),
                      child: IroText(
                        mline: null,
                        data: _data,
                        size: 12,
                        color: Colors.black,
                        align: TextAlign.left,
                      ),
                    ),
                    _icon(url3: true),
                  ],
                ),
              ),
            ),
            btText: '下载',
            press: () async {
              Map result = await IroApi().request(
                'https://pan.baidu.com/share/set?channel=chunlei&web=1&app_id=250528&logid=MTU4MTk0MzY0MTQwNzAuNDA0MzQxOTM0MzE2MzM4Ng==&clienttype=0', //此处均为固定参数
                method: Method.form,
                queryParameters: {
                  'schannel': 4,
                  'channel_list': '[]',
                  'period': 1, //分享文件的时间，设置过长没多大意义，因为解析出的链接有效期为8小时
                  'pwd':
                      1129, //提取码，如果服务端指定了允许的提取码，则必须在此设置对应的提取码，如果服务端没有限制，此处看心情设置
                  'fid_list': [
                    bdDiskFile.fsId
                  ].toString(), //分享文件的列表，可以一次性分享复数文件，通过fsId这个参数对应指定文件，如果需要批量分享解析，可以作出对应更改
                },
                options: Options(
                  headers: {
                    'Host': 'pan.baidu.com',
                    'User-Agent':
                        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.120 Safari/537.36',
                    'Cookie':
                        'BDUSS=${Iro.prefs.getString('BDUSS')}; STOKEN=${Iro.prefs.getString('STOKEN')};',
                  },
                ),
              );
              if (result['errno'] == 0) {
                print('成功创建分享链接 ${result['link']}');
                Map rs = await IroApi().request(
                  'XXX?url=${result['link']}&pwd=1129', //XXX请对应服务端接口地址，url后面的参数为分享链接，pwd后面的参数为提取码
                );
                if (rs['code'] == 'success') {
                  print('获取成功');
                  print(rs);
                }
              } else {
                //创建分享失败
                iroDia(
                  context,
                  title: bdDiskFile.file,
                  data: '此文件为违规文件，暂不支持下载',
                  cancelText: '取消',
                  cancelPress: () {},
                );
              }
            },
          );
        } else {
          dirCallBack();
        }
      },
    );
  }
}
