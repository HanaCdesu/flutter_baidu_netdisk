import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:pan_iro_moe/IroPage/iro_widget.dart';
import 'package:pan_iro_moe/pan/model/PanFileModel.dart';
import 'package:path/path.dart';

import '../../main.dart';
import '../IroPage/iro.dart';
import '../IroPage/iro_page.dart';
import 'model/PanRequest.dart';
import 'pan_file_view.dart';
import 'pan_login_page.dart';

//使用get设置变量，不用setState也可以直接更新界面
class _PanState extends GetxController {
  //加载状态，0为加载中，1为加载成功，2为加载失败，3为未登录
  RxInt loadState;
  //文件列表数据
  RxList<PanFile> files;
  //当前目录
  RxString path;
  _PanState()
      : loadState = 0.obs,
        files = <PanFile>[].obs,
        path = '/'.obs;
}

class PanPage extends StatefulWidget {
  PanPage({Key? key}) : super(key: key);

  @override
  State<PanPage> createState() => _PanPageState();
}

class _PanPageState extends State<PanPage> {
  List<AnimationController> animationControllers = [];
  EasyRefreshController refreshController = new EasyRefreshController();
  ScrollController scrollController = new ScrollController();
  late IroPage iroPage;

  final _PanState panState = new _PanState();
  final PanRequest panRequest = new PanRequest();

  //根目录，可以在init()中设置为其它目录，如：/我的资源
  late String rootPath;
  late bool _islogin;

  init() {
    rootPath = '/';
    _islogin = Iro.prefs.getString('BDUSS') != '' &&
        Iro.prefs.getString('STOKEN') != '';
    _initRootPath(rootPath);
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void didUpdateWidget(PanPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initRootPath(rootPath);
  }

  _initRootPath(String path) {
    rootPath = path;
    panState.path.value = path;
    print('初始化 RootPath');
    _requestFiles();
  }

  _requestFiles() async {
    panState.loadState.value = 0;
    print('加载目录 ${panState.path.value}');

    if (_islogin) {
      try {
        panState.files.value = await panRequest.fetchFileList(
          panState.path.value,
          order: 'name', //排序
          start: 0, //起始
          limit: 100, //条目限制
          page: 1, //如果条目数过多，或者单次获取条目较少，可以在panState中添加分页，获取时设置page
        );
        panState.loadState.value = 1;
      } catch (e) {
        print(e);
        panState.loadState.value = 2;
      }
    } else {
      print('未登录');
      panState.files.value = [PanFile()];
      panState.loadState.value = 3;
    }
  }

  refresh() async {
    await reverse(animationControllers);
    forward(animationControllers);
    if (panState.loadState.value == 1) await _requestFiles();
    refreshController.finishRefresh();
  }

  onload() {
    refreshController.finishLoad(noMore: true); //如果有多页文件，在此处为panState.files添加数据
  }

  Future<bool> _pop({String? to}) async {
    if (rootPath.compareTo(panState.path.value) == 0 && to == null) {
      return true;
    } else {
      if (to == null)
        panState.path.value = dirname(panState.path.value); //上级文件夹
      else
        panState.path.value = to; //目标文件夹
      await reverse(animationControllers);
      _requestFiles();
      forward(animationControllers);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    iroPage = IroPage(
      animationControllers: animationControllers,
      scrollController: scrollController,
      showload: true,
      title: '百度网盘解析',
      refreshController: refreshController,
      count: 1,
      core: panState.files,
      irobox: (context, i) {
        return Obx(
          (() {
            Widget _show = SizedBox();
            if (i == 0 && panState.loadState.value == 0) {
              //加载中
              _show = Container(
                decoration: iroDecoration(),
                child: IroText(data: '少女祈祷中'),
              );
            } else if (panState.loadState.value == 1) {
              //加载成功
              _show = PanFileListView(
                bdDiskFile: panState.files[i],
                dirCallBack: () async {
                  await reverse(animationControllers);
                  panState.path.value = panState.files[i].path;
                  _requestFiles();
                  forward(animationControllers);
                },
              );
            } else if (panState.loadState.value == 2) {
              //加载失败
              _show = Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        Icons.error_outline_rounded,
                        color: Iro.moe,
                        size: 32,
                      ),
                    ),
                    IroText(data: '加载失败'),
                  ],
                ),
              );
            } else if (panState.loadState.value == 3) {
              //未登录
              _show = Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        Icons.error_outline_rounded,
                        color: Iro.moe,
                        size: 32,
                      ),
                    ),
                    IroText(data: '未登录百度账号！\n请点击右上角按钮记录百度账号~'),
                  ],
                ),
              );
            }
            return Container(
              margin: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              decoration: iroDecoration(),
              child: _show,
            );
          }),
        );
      },
      tool: SizedBox(
        height: 38,
        width: 38,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(32.0)),
          onTap: () {
            iroDia(
              context,
              title: _islogin ? '清除凭证' : '记录账号',
              data: _islogin ? '是否要清除百度账号凭证？' : '登录将记录百度账号数据——如果担心隐私，请勿用私人账号',
              btText: _islogin ? '销毁' : '登录账号',
              press: () {
                if (_islogin) {
                  //此处清除百度账号数据
                  Iro.prefs.setString('BDUSS', '');
                  Iro.prefs.setString('STOKEN', '');
                } else {
                  //跳转到登录界面
                  if (mounted) Navigator.pop(context);
                  Navigator.of(context).push(
                    new MaterialPageRoute(
                      builder: (context) {
                        return new PanAuth();
                      },
                    ),
                  );
                }
              },
              cancelText: '取消',
              cancelPress: () {},
            );
          },
          child: Center(
            child: Icon(
              Icons.fingerprint_rounded,
              color: Iro.moe,
            ),
          ),
        ),
      ),
      top: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: iroDecoration(white: true),
          padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Obx(
            (() {
              String path = '根目录${panState.path.value}';
              List<String> paths = path.split('/');
              paths.remove('');
              return Wrap(
                children: List.generate(
                  paths.length,
                  (index) => InkWell(
                    onTap: () {
                      _pop(to: '/${paths.sublist(1, index + 1).join('/')}');
                    },
                    child: IroText(
                      data: '${paths[index]}/',
                      size: 16,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
      onWillPop: _pop,
      showFloatTool: false,
      refresh: refresh,
      onload: onload,
    );
    return iroPage;
  }
}
