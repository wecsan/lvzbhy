# Hot Live

<img width="100" alt="image" src="https://github.com/Jackiu1997/pure_live/blob/master/assets/icon.png?raw=true">

![](https://img.shields.io/badge/language-dart-blue.svg?style=for-the-badge&color=00ACC1)
![](https://img.shields.io/badge/flutter-00B0FF?style=for-the-badge&logo=flutter)
[![](https://img.shields.io/github/downloads/Jackiu1997/pure_live/total?style=for-the-badge&color=FF2196)](https://github.com/Jackiu1997/pure_live/releases)
![](https://img.shields.io/github/license/Jackiu1997/pure_live?style=for-the-badge)
![](https://img.shields.io/github/stars/Jackiu1997/pure_live?style=for-the-badge)
![](https://img.shields.io/github/issues/Jackiu1997/pure_live?style=for-the-badge&color=9C27B0)

A Flutter application for android and ios, which can make you watch lives with ease.

一个为Android和IOS开发的Flutter直播应用程序，轻松看直播。

## Screenshots

<div style="text-align: center">
  <table>
    <tr>
    <td style="text-align: center">
      <img src="./screenshots/favorite_page.jpg" width="200"/>
    </td>
    <td style="text-align: center">
      <img src="./screenshots/popular_page.jpg" width="200"/>
    </td>
    <td style="text-align: center">
      <img src="./screenshots/areas_page.jpg" width="200"/>
    </td>
    <td style="text-align: center">
      <img src="./screenshots/search_page.jpg" width="200"/>
    </td>
    <td style="text-align: center">
      <img src="./screenshots/live_play_page.jpg" width="200"/>
    </td>
    </tr>
  </table>
</div>

## Platforms

- [x] [哔哩哔哩](https://app.bilibili.com/)

- [x] [虎牙APP](https://www.huya.com/download/)

- [x] [斗鱼APP](https://www.douyu.com/client)

- [ ] 没有其他平台的计划

## Donate

如果你觉得该项目对您有所帮助，可以打赏一杯咖啡给我，支持我继续开发维护PureLive。
感谢您的支持~

<div style="text-align: center">
  <table>
    <tr>
    <td style="text-align: center">
      <img src="./assets/images/alipay.jpg" width="200"/>
    </td>
    <td style="text-align: center">
      <img src="./assets/images/wechat.png" width="228"/>
    </td>
    </tr>
  </table>
</div>

## Problems

### 解决中的问题

- [x] 大量弹幕时会有水平弹幕遮挡
- [x] 支持DLNA投屏
- [x] 支持视频填充/拉伸
- [x] 后台小窗播放
- [ ] 斗鱼某些直播间无法播放
- [ ] 虎牙某些弹幕无法获取

### 部分链接无法播放

- 对于部分IP，哔哩哔哩的`.flv`格式的直播流无法播放，尝试使用`.m3u8`格式的直播流

### 搜索哔哩哔哩直播间不工作

- 哔哩哔哩官方搜索接口需要使用cookie，请在设置中自行设置自己的cookie

如果各种问题，请发布[issue](https://github.com/Jackiu1997/pure_live/issues/new/choose)

### 不定时更新（随缘开发）
如果你想要更好的用户体验，更人性化的交互设计，更稳定的使用，可以使用[哔哩哔哩APP](https://app.bilibili.com/)，[斗鱼APP](https://www.douyu.com/client)，[虎牙APP](https://www.huya.com/download/)

## Statement
This project is only for learning and communication. Please do not use it for commercial purposes. The copyright of related resources is owned by the original company.

这个项目仅作为个人兴趣业余开发，不用于商业用途。相关资源的版权归原公司所有。

No user privacy is ever collected, the app directly requests the official interface except for detection updates, and the data generated by all operations is kept locally by the user.

本项目是一个纯本地直播转码应用，不会收集任何用户隐私，应用程序直接请求直播官方接口，所有操作生成的数据由用户本地保留。

## Thanks
 - [ice_live_viewer](https://github.com/iiijam/ice_live_viewer)
 - [JustLive-Api](https://github.com/guyijie1211/JustLive-Api)
 - [real-url](https://github.com/wbt5/real-url)
 - [dart_tars_protocol](https://github.com/xiaoyaocz/dart_tars_protocol)
 - [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
 - [alltv_flutter](https://github.com/Ha2ryZhang/alltv_flutter)