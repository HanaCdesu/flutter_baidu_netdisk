<?php
if (!defined('init')) {
    http_response_code(403);
    header('Content-Type: text/plain; charset=utf-8');
    header('Refresh: 5;url=https://baidu.com/');
    die("不准访问这里哦~");
}

//百度账号数据部分
const BDUSS = '';//用于获取文件信息的百度网盘账号的BDUSS
const STOKEN = '';//用于获取文件信息的百度网盘账号的STOKEN
const SVIP_BDUSS = '';//百度网盘SVIP账号的BDUSS
//自定义数据部分
const unipwd = ''; //指定提取码
const userAgent = 'iro.moe';//指定UA，只有使用此UA才能正常下载
