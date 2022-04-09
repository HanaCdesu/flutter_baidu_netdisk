import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../main.dart';
import 'iro_widget.dart';
import 'models/IroListCard.dart';

//此处为页面绘制
//因为个人写的IroPage过于复杂，大致将一些PanPage用不到的参数删掉了，但此处也多余了非常多的参数懒得删
//如果对此处页面绘制不满意，请另行写

reverse(List<AnimationController> animationControllers) async {
  Future _reverse(AnimationController animationController) async {
    animationController.duration = Duration(milliseconds: 200);
    await animationController.reverse();
  }

  List<Future> animations = <Future>[];
  animationControllers.forEach((AnimationController animationController) {
    animations.add(_reverse(animationController));
  });
  await Future.wait(animations);
}

forward(List<AnimationController> animationControllers) {
  animationControllers.forEach((AnimationController animationController) {
    animationController.duration = Duration(milliseconds: 1000);
    animationController.forward();
  });
}

class IroPage extends StatelessWidget {
  IroPage({
    Key? key,
    this.bg = true,
    required this.animationControllers,
    required this.irobox,
    required this.core,
    required this.refresh,
    this.count = 1,
    required this.onload,
    required this.title,
    this.tool,
    this.top,
    this.bottom,
    this.padding,
    this.back = true,
    this.showload = false,
    required this.scrollController,
    this.reversed = false,
    this.showFloatTool = true,
    this.onWillPop,
    required this.refreshController,
  }) : super(key: key);

  final bool bg;
  final List<AnimationController> animationControllers;
  final Widget Function(BuildContext, int) irobox;
  final List core;
  final dynamic Function() refresh;
  final Function onload;
  final int count;
  final String title;
  final Widget? tool;
  final Widget? top;
  final Widget? bottom;
  final bool reversed;
  final EdgeInsetsGeometry? padding;
  final bool back;
  final bool showload;
  final ScrollController scrollController;
  final bool showFloatTool;
  final Future<bool> Function()? onWillPop;
  final EasyRefreshController refreshController;

  Future<bool> _onWillPop() async {
    if (onWillPop != null) {
      if (await onWillPop!()) {
        await reverse(animationControllers);
        return true;
      } else {
        return false;
      }
    } else {
      await reverse(animationControllers);
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            image: new DecorationImage(
              fit: BoxFit.cover,
              image: new NetworkImage('https://iro.moe/src/bgWebp/'), //是涩涩！
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: _IroView(
              refreshController: refreshController,
              animationControllers: animationControllers,
              core: core,
              irobox: irobox,
              onload: onload,
              refresh: refresh,
              scrollController: scrollController,
              title: title,
              count: count,
              tool: tool,
              img: null,
              top: top,
              bottom: bottom,
              padding: padding,
              back: back,
              showload: showload,
              reversed: reversed,
            ),
          ),
        ),
        onWillPop: _onWillPop);
  }
}

class _CoreController extends GetxController {
  RxList core = [].obs;
}

class _IroView extends StatefulWidget {
  _IroView({
    Key? key,
    required this.irobox,
    required this.core,
    required this.refresh,
    this.count = 1,
    required this.onload,
    required this.title,
    this.tool,
    this.top,
    this.img,
    this.bottom,
    this.padding,
    this.back = true,
    this.showload = false,
    required this.scrollController,
    this.reversed = false,
    required this.animationControllers,
    required this.refreshController,
  }) : super(key: key);
  final Widget Function(BuildContext, int) irobox;
  final List core;
  final dynamic Function() refresh;
  final Function onload;
  final int count;
  final String title;
  final Widget? tool;
  final Widget? top;
  final String? img;
  final Widget? bottom;
  final bool reversed;
  final EdgeInsetsGeometry? padding;
  final bool back;
  final bool showload;
  final ScrollController scrollController;
  final List<AnimationController> animationControllers;
  final EasyRefreshController refreshController;

  @override
  _IroViewState createState() =>
      _IroViewState(scrollController, refreshController);
}

class _IroViewState extends State<_IroView> with TickerProviderStateMixin {
  bool backToTopVisible = false;
  _IroViewState(this.scrollController, this.refreshController);
  final ScrollController scrollController;
  late Animation<double> animation;
  final EasyRefreshController refreshController;
  final _CoreController _coreController = new _CoreController();

  dynamic Function() get refresh => widget.refresh;
  String get title => widget.title;
  bool get back => widget.back;
  Widget? get tool => widget.tool;
  String? get img => widget.img;
  EdgeInsetsGeometry? get padding => widget.padding;
  Widget? get top => widget.top;
  int get count => widget.count;
  bool get showload => widget.showload;
  List get core => widget.core;
  bool get reversed => widget.reversed;
  Function get onload => widget.onload;
  Widget? get bottom => widget.bottom;
  List<AnimationController> get animationControllers =>
      widget.animationControllers;

  init() async {
    await refresh();
    _coreController.core.value = core;
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    animationControllers.forEach((AnimationController animationController) {
      animationController.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget sticky = ExtendedSliverAppbar(
      toolBarColor: Colors.transparent,
      isOpacityFadeWithToolbar: false,
      title: SizedBox(
        width: MediaQuery.of(context).size.width - 160,
        child: IroText(
          data: title,
          size: 20.0,
          mline: 3,
          color: Iro.moe,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: SizedBox(
        height: 36,
        width: 36 * 2 + 8.0,
        child: InkWell(
          highlightColor: Colors.transparent,
          borderRadius: const BorderRadius.all(Radius.circular(32.0)),
          onTap: () async {
            await reverse(animationControllers);
            Navigator.pop(context);
          },
          child: Center(
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black,
            ),
          ),
        ),
      ),
      actions: Row(
        children: [
          tool == null
              ? SizedBox(height: 36, width: 36)
              : Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(32.0)),
                  ),
                  child: tool),
          SizedBox(
            height: 36,
            width: 36,
            child: InkWell(
              highlightColor: Colors.transparent,
              borderRadius: const BorderRadius.all(Radius.circular(32.0)),
              onTap: () {},
              child: Center(
                child: Icon(
                  Icons.help_rounded,
                  color: Iro.moe,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 8,
          )
        ],
      ),
      background: Container(
        decoration: BoxDecoration(
          color: img == null ? Colors.transparent : Colors.white,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32.0),
          ),
        ),
        child: Stack(
          children: <Widget>[
            img == null
                ? SizedBox()
                : Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32.0),
                      ),
                      child: IroImg(
                        url: '${widget.img}',
                        cover: true,
                        showload: false,
                      ),
                    ),
                  ),
            Padding(
              padding: padding == null
                  ? EdgeInsets.only(
                      top: kToolbarHeight + MediaQuery.of(context).padding.top,
                      bottom: 20,
                    )
                  : padding!,
              child: Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 18 * (img == null ? 1 : 1.6) * 1.2,
                      child: IroText(
                        data: title,
                        size: 18 * (img == null ? 1 : 1.6),
                        fontWeight:
                            img == null ? FontWeight.normal : FontWeight.bold,
                        mline: 2,
                      ),
                    ),
                    top == null ? Container() : top!,
                    SizedBox(height: 8)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Widget irobox = Obx(
      (() => SliverWaterfallFlow(
            gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                crossAxisCount: count),
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                animationControllers.add(AnimationController(
                    duration: Duration(milliseconds: 1000), vsync: this));
                if (mounted) animationControllers.last.forward();
                return IroListCard(
                  child: widget.irobox(context, i),
                  animationController: animationControllers[i],
                  indexcont: i / _coreController.core.length,
                );
              },
              childCount: _coreController.core.length,
            ),
          )),
    );

    return Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      child: Stack(
        children: [
          Column(
            children: <Widget>[
              Expanded(
                child: EasyRefresh.custom(
                  scrollController: scrollController,
                  enableControlFinishLoad: true,
                  enableControlFinishRefresh: true,
                  reverse: reversed,
                  header: ClassicalHeader(
                    alignment: Alignment.center,
                    float: true,
                    completeDuration: Duration(milliseconds: 600),
                    refreshText: 'refreshText'.tr,
                    refreshFailedText: 'refreshFailedText'.tr,
                    refreshReadyText: 'refreshReadyText'.tr,
                    refreshedText: 'refreshedText'.tr,
                    refreshingText: 'refreshingText'.tr,
                    noMoreText: 'noMore'.tr,
                    showInfo: false,
                    infoColor: Colors.deepOrange,
                    textColor: Iro.moe,
                  ),
                  footer: ClassicalFooter(
                    alignment: Alignment.center,
                    float: true,
                    completeDuration: Duration(milliseconds: 600),
                    loadText: 'loadText'.tr,
                    loadFailedText: 'loadFailedText'.tr,
                    loadReadyText: 'loadReadyText'.tr,
                    loadedText: 'loadedText'.tr,
                    loadingText: 'loadingText'.tr,
                    noMoreText: 'noMoreTextLoad'.tr,
                    showInfo: false,
                    infoColor: Colors.deepOrange,
                    textColor: Iro.moe,
                  ),
                  onRefresh: () async {
                    await refresh();
                  },
                  onLoad: () async {
                    await onload();
                  },
                  shrinkWrap: true,
                  controller: refreshController,
                  slivers: reversed ? [irobox] : [sticky, irobox],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
