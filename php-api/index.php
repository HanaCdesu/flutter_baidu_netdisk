<?php
define('init', true);
require("config.php");

function rs($result)
{
    header('Content-Type:application/json; charset=utf-8');
    exit(json_encode($result));
}

function ini_curl(&$ch, $header, $full)
{
    if ($full) {
        curl_setopt($ch, CURLOPT_HEADER, true);
        curl_setopt($ch, CURLOPT_NOBODY, true);
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, false);
    }
    return (curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false) &&
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0) &&
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true) &&
        curl_setopt($ch, CURLOPT_HTTPHEADER, $header)
    );
}

function get_header($url, $header)
{
    $ch = curl_init($url);
    ini_curl($ch, $header, false);
    $result = substr(curl_exec($ch), 0, curl_getinfo($ch, CURLINFO_HEADER_SIZE));
    curl_close($ch);
    return $result;
}

function bdclnd($surl, $Pwd)
{
    $header = array('User-Agent: netdisk');
    $url = 'https://pan.baidu.com/share/wxlist?clienttype=25&shorturl=' . $surl . '&pwd=' . $Pwd;
    $ch = curl_init($url);
    ini_curl($ch, $header, true);
    $result = substr(curl_exec($ch), 0, curl_getinfo($ch, CURLINFO_HEADER_SIZE));
    curl_close($ch);
    if (strstr($result, "BDCLND") == false) {
        $ch = curl_init('https://pan.baidu.com/s/' . $surl);
        ini_curl($ch, [], true);
        $header = substr(curl_exec($ch), 0, curl_getinfo($ch, CURLINFO_HEADER_SIZE));
        curl_close($ch);
        $bdclnd = preg_match('/BDCLND=(.+?);/', $header, $matches);
        if ($bdclnd) {
            return $matches[1];
        } else {
            return '';
        }
    } else {
        return substr($result, strpos($result, 'BDCLND=') + 7, strpos($result, 'BDCLND=') - 7);
    }
}

function getFileInfos($surl, $randsk)
{
    if ($randsk === 1) return 1;
    $url = 'https://pan.baidu.com/s/1' . $surl;
    $header = array(
        "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.120 Safari/537.36",
        "Cookie: BDUSS=" . BDUSS . ";STOKEN=" . STOKEN . ";BDCLND=" . $randsk . ";"
    );
    $ch = curl_init($url);
    ini_curl($ch, $header, false);
    $result = curl_exec($ch);
    curl_close($ch);
    if (preg_match('/locals.mset\((\{.*?\})\);/', $result, $matches)) {
        return json_decode($matches[1], true, 512, JSON_BIGINT_AS_STRING);
    } else {
        if (strstr($result, "Redirecting to") != false) {
            rs(array(
                'code' => 'error',
                'help' => '服务器数据错误', //被重定向了，系账号数据错误，如BDUSS失效
            ));
        } else {
            rs(array(
                'code' => 'error',
                'help' => '服务器解析错误', //不知原因，解析不能
            ));
        }
    }
}
//发起请求连接例子：.../?url=XXX&pwd=YYYY
//XXX为分享链接，YYYY为提取码
if (!isset($_GET['url'])) {
    rs(array(
        'code' => 'error',
        'help' => '参数错误 未设定分享链接',
    ));
}
if (!isset($_GET['pwd'])) {
    if (strlen(unipwd) != 4) {
        rs(array(
            'code' => 'error',
            'help' => '参数错误 未设定提取码', //当然，也存在古久分享链接不需要提取码，由于此类情况过少，未考虑
        ));
    }
} else {
    if (strlen(unipwd) == 4 && $GET['pwd'] != unipwd) {
        rs(array(
            'code' => 'error',
            'help' => '参数错误 只允许提取码为' . unipwd,
        ));
    }
    if (strlen($_GET['pwd']) != 4 && strlen(unipwd) != 4) {
        rs(array(
            'code' => 'error',
            'help' => '参数错误 提取码错误',
        ));
    }
}

if (!preg_match("/pan.baidu.com/", $_GET['url'])) {
    rs(array(
        'code' => 'error',
        'help' => '参数错误 分享链接错误',
    ));
}
if (preg_match("/1[A-Za-z0-9-_]+/", $_GET['url'], $matches))
    $surl = $matches[0];
else if (preg_match("/surl=([A-Za-z0-9-_]+)/", $_GET['url'], $matches))
    $surl = $matches[1];
else
    rs(array(
        'code' => 'error',
        'help' => '参数错误 分享链接错误',
    ));

$pwd = strlen(unipwd) == 4 ? unipwd : $_GET['pwd'];

$randsk = bdclnd($surl, $pwd);
$root = getFileInfos(substr($surl, 1), $randsk);
$file = $root['file_list'][0];
if ($file == null) $file = $root['file_list']['list'][0];
$fs_id = number_format($file["fs_id"], 0, '', '');
$shareid = $root["shareid"];
$bdstoken = $root["bdstoken"];
$uk = $root["share_uk"];
$url = "https://pan.baidu.com/share/tplconfig?shareid=$shareid&uk=$uk&fields=sign,timestamp&channel=chunlei&web=1&app_id=250528&clienttype=0";
$header = array(
    "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.120 Safari/537.36",
    "Cookie: BDUSS=" . BDUSS . ";STOKEN=" . STOKEN . ";BDCLND=" . $randsk . ";"
);
$ch = curl_init($url);
ini_curl($ch, $header, false);
$result = json_decode(curl_exec($ch), true, 512, JSON_BIGINT_AS_STRING);
curl_close($ch);
$sign = $result["data"]["sign"];
$timestamp = $result["data"]["timestamp"];
$filesize = $file['size'];
if ((int)$filesize <= 52428800) {
    rs(array(
        'code' => 'error',
        'help' => '小文件不支持解析', //咲
    ));
}
$url = 'https://pan.baidu.com/api/sharedownload?channel=chunlei&clienttype=12&web=1&app_id=250528&sign=' . $sign . '&timestamp=' . $timestamp;
$data = "encrypt=0" . "&extra=" . urlencode('{"sekey":"' . urldecode($randsk) . '"}') . "&fid_list=[$fs_id]" . "&primaryid=$shareid" . "&uk=$uk" . "&product=share&type=nolimit";
$header = array(
    "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.120 Safari/537.36",
    "Cookie: BDUSS=" . BDUSS . ";STOKEN=" . STOKEN . ";BDCLND=" . $randsk . ";",
    "Referer: https://pan.baidu.com/disk/home"
);
$ch = curl_init($url);
ini_curl($ch, $header, false);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
$infos = json_decode(curl_exec($ch), true);
curl_close($ch);
if ($infos["errno"] == 0) {
    $url = $infos["list"][0]["dlink"];
    $md5 = $infos["list"][0]["md5"];
    $filename = $infos["list"][0]["server_filename"];
    $size = $infos["list"][0]["size"];
    $path = $infos["list"][0]["path"];
    $SVIP_BDUSS = SVIP_BDUSS;
    $header = array('User-Agent: ' . userAgent, 'Cookie: BDUSS=' . $SVIP_BDUSS . ';');
    $ch = curl_init($url);
    ini_curl($ch, $header, true);
    $realLink = substr(strstr(substr(curl_exec($ch), 0, curl_getinfo($ch, CURLINFO_HEADER_SIZE)), "Location"), 10);
    curl_close($ch);
} else {
    rs(array('code' => 'error', 'help' => '解析错误 ' . $infos['errno']));
}
if ($realLink == '') {
    rs(array('code' => 'error', 'help' => '解析错误'));
} else {
    rs(array(
        'code' => 'success',
        'info' => '解析成功',
        'filename' => $filename,
        'size' => $size,
        'md5' => $md5,
        'down' => $realLink,
    ));
}
