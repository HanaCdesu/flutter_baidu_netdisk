import 'package:dio/dio.dart';
import 'package:pan_iro_moe/api/IroApi.dart';
import 'package:pan_iro_moe/pan/model/PanFileModel.dart';

import '../../main.dart';

class PanRequest {
  Future<List<PanFile>> fetchFileList(
    String dir, {
    String order = 'name',
    int start = 0,
    int limit = 100,
    int page = 1,
  }) async {
    print('requesting path: ${dir}');
    Map result = await IroApi().request(
      'https://pan.baidu.com/api/list?clienttype=0&order=${order}&dir=${Uri.parse(dir)}&num=${limit}&page=${page}&web=1&app_id=250528&logid=MTU4MTk0MzY0MTQwNzAuNDA0MzQxOTM0MzE2MzM4Ng==',
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
    if (result['errno'] != 0) {
      throw Exception(result);
    }
    List list = result["list"];
    List<PanFile> _tmp =
        List.generate(list.length, (int i) => PanFile.fromJSON(list[i]));
    return _tmp;
  }
}
