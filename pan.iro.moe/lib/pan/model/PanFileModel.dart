class PanFile {
  PanFile();

  /// 路径
  String path = '';

  /// 文件名
  String file = '';

  /// 是否为文件夹
  bool isDir = true;

  /// 时间戳
  int? date;

  /// 文件字节
  int? size;
  int? fsId;
  String? md5;
  String? dLink;

  /// 缩略图
  Thumbs? thumbs;

  PanFile.fromJSON(Map<String, dynamic> json) {
    fsId = json['fs_id'];
    isDir = json['isdir'] == 1;
    path = json['path'];
    date = json['server_ctime'];
    file = json['server_filename'] ?? json["filename"];
    size = json['size'];
    md5 = json['md5'];
    dLink = json["dlink"];
    thumbs =
        json['thumbs'] != null ? new Thumbs.fromJson(json['thumbs']) : null;
  }
}

class Thumbs {
  String? icon;
  String? url3;
  String? url2;
  String? url1;

  Thumbs({this.icon, this.url3, this.url2, this.url1});

  Thumbs.fromJson(Map<String, dynamic> json) {
    icon = json['icon'];
    url3 = json['url3'];
    url2 = json['url2'];
    url1 = json['url1'];
  }
}
