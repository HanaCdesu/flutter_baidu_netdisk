import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pan_iro_moe/main.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

//此处为一些UI
//由于大部分是复制粘贴，所以有许多意义不明/用不到的参数，并且花里胡哨
//如果对此处UI不满意请另行写

//文本
class IroText extends StatelessWidget {
  final String data;
  final double size;
  final color;
  final TextAlign align;
  final FontWeight fontWeight;
  final double? boxheight;
  final double? boxwidth;
  final int? mline;
  final double minFontSize;
  final double maxFontSize;
  const IroText({
    Key? key,
    required this.data,
    this.size = 18.0,
    this.color,
    this.align = TextAlign.center,
    this.fontWeight = FontWeight.normal,
    this.boxheight,
    this.boxwidth,
    this.mline = 5,
    this.minFontSize = 8,
    this.maxFontSize = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      data,
      maxFontSize: maxFontSize,
      minFontSize: minFontSize,
      textAlign: align,
      style: TextStyle(
        height: 1.2,
        fontSize: size,
        fontFamily: 'NotoSansSC',
        fontWeight: fontWeight,
        color: Color(0xfffa7298),
      ),
      maxLines: mline,
    );
  }
}

//图片
class IroImg extends StatelessWidget {
  final url;
  final bool cover;
  final double height;
  final bool showload;
  final bool radius;
  final double errorwidth;
  final double errorheight;
  final Map<String, String>? header;
  const IroImg(
      {Key? key,
      required this.url,
      this.cover = false,
      this.height = 50,
      this.showload = true,
      this.radius = false,
      this.errorwidth = 50,
      this.errorheight = 50,
      this.header})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      httpHeaders: header ?? Iro.header,
      imageUrl: url,
      fit: cover ? BoxFit.cover : BoxFit.contain,
      filterQuality: FilterQuality.high,
      fadeInDuration: Duration(milliseconds: 200),
      progressIndicatorBuilder: (context, url, downloadProgress) => Container(
        height: showload ? height : MediaQuery.of(context).size.height,
        child: showload || url.contains('gif')
            ? Container(
                child: Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: Iro.moe,
                      value: downloadProgress.progress),
                ),
                decoration: iroDecoration(
                  white: false,
                  color: Colors.white.withOpacity(
                    1 -
                        (downloadProgress.progress == null
                            ? 0
                            : downloadProgress.progress!),
                  ),
                ),
              )
            : Container(
                decoration: iroDecoration(
                  white: false,
                  color: Colors.white.withOpacity(
                    1 -
                        (downloadProgress.progress == null
                            ? 0
                            : downloadProgress.progress!),
                  ),
                ),
              ),
      ),
      errorWidget: (context, url, e) {
        File cache = new File(url);
        if (cache.existsSync()) DefaultCacheManager().removeFile(url);
        return SizedBox(
          width: errorwidth,
          height: errorheight,
          child: Icon(Icons.error_rounded),
        );
      },
    );
  }
}

//逆天
iroDecoration(
    {Color? color,
    bool white = true,
    bool circle = false,
    BorderRadius? radius,
    bool shadow = true}) {
  return BoxDecoration(
    shape: circle ? BoxShape.circle : BoxShape.rectangle,
    gradient: LinearGradient(
        colors: white
            ? [
                Colors.white.withOpacity(.99),
                Colors.white.withOpacity(.99),
                Colors.white.withOpacity(.95),
                Colors.white.withOpacity(.90),
                Colors.white.withOpacity(.85),
                Colors.white.withOpacity(.80),
              ]
            : [
                Iro.moe.withOpacity(.45),
                Iro.moe.withOpacity(.60),
                Iro.moe.withOpacity(.70),
                Iro.moe.withOpacity(.75),
                Iro.moe.withOpacity(.80),
                Iro.moe.withOpacity(.85),
                Iro.moe.withOpacity(.90)
              ],
        begin: Alignment.topCenter,
        end: Alignment.bottomRight),
    boxShadow: <BoxShadow>[
      if (shadow)
        BoxShadow(
          color: Iro.moe.withOpacity(white ? 0.9 : .5),
          offset: const Offset(2, 4),
          blurRadius: 8.0,
        ),
    ],
    color: color == null ? Colors.white.withOpacity(.99) : color,
    borderRadius: circle
        ? null
        : (radius ??
            BorderRadius.all(
              Radius.circular(16),
            )),
  );
}

//文件图标
class FileIcon extends StatelessWidget {
  const FileIcon(
      {Key? key,
      required this.file,
      this.folder = false,
      this.size,
      this.color})
      : super(key: key);
  final String file;
  final bool folder;
  final double? size;
  final Color? color;

  IconData _getExt() {
    if (folder) return Icons.folder_open_rounded;
    String ext = file.split('.').last;
    List img = ["jpg", "jpeg", "gif", "bmp", "png", "svg", "ico", "webp"];
    List video = ["flv", "avi", "mp4", "mkv", "m4v", "m3u8", "swf"];
    List audio = ["wav", "mp3", "aac", "ogg", "m4a", "flac"];
    List archive = ["rar", "zip", "7z", '001'];
    List windows = ["exe"];
    List android = ["apk"];
    List alt = ["txt"];
    if (img.contains(ext)) {
      return Icons.image_rounded;
    } else if (video.contains(ext)) {
      return Icons.video_collection_rounded;
    } else if (audio.contains(ext)) {
      return Icons.audio_file_rounded;
    } else if (archive.contains(ext)) {
      return Icons.folder_zip_rounded;
    } else if (windows.contains(ext)) {
      return Icons.desktop_windows_rounded;
    } else if (android.contains(ext)) {
      return Icons.android_rounded;
    } else if (alt.contains(ext)) {
      return Icons.text_fields_rounded;
    } else {
      return Icons.file_open_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      _getExt(),
      size: size ?? 16,
      color: color ?? Iro.moe,
    );
  }
}

//逆天
class IroContainer extends StatelessWidget {
  const IroContainer({
    Key? key,
    required this.img,
    required this.height,
    required this.child,
    this.top,
    this.right,
    this.aspectRatio = 1,
    this.size = 1,
    this.borderRadius,
    this.opacity = .5,
    this.bottom,
  }) : super(key: key);
  final Widget child;
  final String img;
  final double height;
  final double? top;
  final double? right;
  final double? bottom;
  final double aspectRatio;
  final double size;
  final BorderRadius? borderRadius;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    double _top = (top ?? -height * .1) / aspectRatio;
    double? _bottom = bottom;
    double _right = right ?? -height * .1;
    double _width = height * 1.4 * aspectRatio;
    double _height = height * 1.4;
    return Container(
      child: ClipRRect(
        borderRadius: borderRadius ??
            BorderRadius.all(
              Radius.circular(16),
            ),
        child: Stack(
          children: [
            Positioned(
              right: _right,
              top: _bottom == null ? _top * size : null,
              bottom: _bottom,
              width: _width * size,
              height: _height,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    colors: [
                      Colors.white.withOpacity(.04 * opacity),
                      Colors.white.withOpacity(.08 * opacity),
                      Colors.white.withOpacity(.12 * opacity),
                      Colors.white.withOpacity(.20 * opacity),
                      Colors.white.withOpacity(.34 * opacity),
                      Colors.white.withOpacity(.38 * opacity),
                      Colors.white.withOpacity(.44 * opacity),
                      Colors.white.withOpacity(.48 * opacity),
                      Colors.white.withOpacity(.44 * opacity),
                      Colors.white.withOpacity(.48 * opacity),
                      Colors.white.withOpacity(.54 * opacity),
                      Colors.white.withOpacity(.58 * opacity),
                      Colors.white.withOpacity(.64 * opacity),
                      Colors.white.withOpacity(.88 * opacity),
                      Colors.white,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.bottomRight,
                  ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                },
                blendMode: BlendMode.dstIn,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      width: _width * size,
                      height: _height * size,
                      child: IroImg(
                        url: img,
                        showload: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
