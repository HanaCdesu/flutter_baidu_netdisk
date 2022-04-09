<img src="https://github.com/HanaCdesu/flutter_baidu_netdisk/blob/main/pan.iro.moe/screenshots/fileList.png?raw=true" alt="Banner" style="zoom: 33%;" />

# 百度网盘解析

使用Flutter开发的APP，以及用于服务端解析的php接口

~~使用Ctrl+C/Ctrl+V开发的APP及接口~~

如果您仅为使用此APP，请到https://iro.moe/moe/r/project-ero/
此仓库仅供参考！
只有大致的简陋的界面和最基础的功能，还有部分无意义的代码

主页：https://iro.moe/
截图均来自極彩计划，并非此仓库的APP实际效果
如果有任何意见、建议，请勿反馈，因为此仓库应该不会更新
就算遇到bug，请自行解决，实现功能的方式大差不差，Flutter部分的注释也够详细了

# Flutter部分
绝大部分需要的参数都有对应说明

通过记录登录百度网盘账号时的BDUSS、STOKEN，获取网盘文件列表/文件详情
记录的BDUSS/STOKEN均不会上传到服务端，仅用作本地获取文件信息

下载文件时，创建文件分享链接
将分享链接&提取码提供给服务端解析
服务端返回下载直链
如果要添加下载功能，比如使用Dio，在option里设置header内容{'User-Agent': '服务端要求的UA'}即可

# PHP部分

需要更改的参数位于config.php
请参考config.php的说明

需要SVIP账号的BDUSS

如果需要防止滥用，添加认证手段，请自行解决

# 截图

<img src="https://github.com/HanaCdesu/flutter_baidu_netdisk/blob/main/pan.iro.moe/screenshots/fileList.png?raw=true" alt="Banner" style="zoom: 45%;" /><img src="https://github.com/HanaCdesu/flutter_baidu_netdisk/blob/main/pan.iro.moe/screenshots/preview.png?raw=true" alt="Banner" style="zoom: 80%;" />

<img src="https://github.com/HanaCdesu/flutter_baidu_netdisk/blob/main/pan.iro.moe/screenshots/download.png?raw=true" alt="Banner"  />

高贵校园网只能有这点下载速度
~~希望所有带学的这种高贵咲园网，能早点*~~

# 支持

没有支持

# 反馈

不准反馈