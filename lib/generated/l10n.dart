// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `HotLive`
  String get app_name {
    return Intl.message(
      'HotLive',
      name: 'app_name',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message(
      'Update',
      name: 'update',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get remove {
    return Intl.message(
      'Remove',
      name: 'remove',
      desc: '',
      args: [],
    );
  }

  /// `Move To Top`
  String get move_to_top {
    return Intl.message(
      'Move To Top',
      name: 'move_to_top',
      desc: '',
      args: [],
    );
  }

  /// `pull up to load`
  String get loading_idle {
    return Intl.message(
      'pull up to load',
      name: 'loading_idle',
      desc: '',
      args: [],
    );
  }

  /// `Load Failed! Drag Retry!`
  String get loading_failed {
    return Intl.message(
      'Load Failed! Drag Retry!',
      name: 'loading_failed',
      desc: '',
      args: [],
    );
  }

  /// `No more Data`
  String get loading_nomore {
    return Intl.message(
      'No more Data',
      name: 'loading_nomore',
      desc: '',
      args: [],
    );
  }

  /// `release to load`
  String get loading_canload {
    return Intl.message(
      'release to load',
      name: 'loading_canload',
      desc: '',
      args: [],
    );
  }

  /// `Favorites`
  String get favorites_title {
    return Intl.message(
      'Favorites',
      name: 'favorites_title',
      desc: '',
      args: [],
    );
  }

  /// `No Favorites`
  String get empty_favorite_title {
    return Intl.message(
      'No Favorites',
      name: 'empty_favorite_title',
      desc: '',
      args: [],
    );
  }

  /// `Please follow live rooms first`
  String get empty_favorite_subtitle {
    return Intl.message(
      'Please follow live rooms first',
      name: 'empty_favorite_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Show Offline Rooms`
  String get show_offline_rooms {
    return Intl.message(
      'Show Offline Rooms',
      name: 'show_offline_rooms',
      desc: '',
      args: [],
    );
  }

  /// `Hide Offline Rooms`
  String get hide_offline_rooms {
    return Intl.message(
      'Hide Offline Rooms',
      name: 'hide_offline_rooms',
      desc: '',
      args: [],
    );
  }

  /// `RoomId: {roomid}\nPlatform: {platform}\nName: {nickname}\nTitle: {title}\nLiveStatus: {livestatus}`
  String room_info_content(Object roomid, Object platform, Object nickname,
      Object title, Object livestatus) {
    return Intl.message(
      'RoomId: $roomid\nPlatform: $platform\nName: $nickname\nTitle: $title\nLiveStatus: $livestatus',
      name: 'room_info_content',
      desc: '',
      args: [roomid, platform, nickname, title, livestatus],
    );
  }

  /// `Popular`
  String get popular_title {
    return Intl.message(
      'Popular',
      name: 'popular_title',
      desc: '',
      args: [],
    );
  }

  /// `No Live Found`
  String get empty_live_title {
    return Intl.message(
      'No Live Found',
      name: 'empty_live_title',
      desc: '',
      args: [],
    );
  }

  /// `Click the button below\nto switch platform`
  String get empty_live_subtitle {
    return Intl.message(
      'Click the button below\nto switch platform',
      name: 'empty_live_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Areas`
  String get areas_title {
    return Intl.message(
      'Areas',
      name: 'areas_title',
      desc: '',
      args: [],
    );
  }

  /// `No Area Found`
  String get empty_areas_title {
    return Intl.message(
      'No Area Found',
      name: 'empty_areas_title',
      desc: '',
      args: [],
    );
  }

  /// `Click the button below\nto switch platform`
  String get empty_areas_subtitle {
    return Intl.message(
      'Click the button below\nto switch platform',
      name: 'empty_areas_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `No Live Found`
  String get empty_areas_room_title {
    return Intl.message(
      'No Live Found',
      name: 'empty_areas_room_title',
      desc: '',
      args: [],
    );
  }

  /// `Pull down to refresh data`
  String get empty_areas_room_subtitle {
    return Intl.message(
      'Pull down to refresh data',
      name: 'empty_areas_room_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Switch platform`
  String get switch_platform {
    return Intl.message(
      'Switch platform',
      name: 'switch_platform',
      desc: '',
      args: [],
    );
  }

  /// `Input live room keyword`
  String get search_input_hint {
    return Intl.message(
      'Input live room keyword',
      name: 'search_input_hint',
      desc: '',
      args: [],
    );
  }

  /// `Only Living`
  String get only_living {
    return Intl.message(
      'Only Living',
      name: 'only_living',
      desc: '',
      args: [],
    );
  }

  /// `No Live Found`
  String get empty_search_title {
    return Intl.message(
      'No Live Found',
      name: 'empty_search_title',
      desc: '',
      args: [],
    );
  }

  /// `You can input other keyword`
  String get empty_search_subtitle {
    return Intl.message(
      'You can input other keyword',
      name: 'empty_search_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings_title {
    return Intl.message(
      'Settings',
      name: 'settings_title',
      desc: '',
      args: [],
    );
  }

  /// `General`
  String get general {
    return Intl.message(
      'General',
      name: 'general',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `Custom`
  String get custom {
    return Intl.message(
      'Custom',
      name: 'custom',
      desc: '',
      args: [],
    );
  }

  /// `Experiment`
  String get experiment {
    return Intl.message(
      'Experiment',
      name: 'experiment',
      desc: '',
      args: [],
    );
  }

  /// `Theme Color`
  String get change_theme_color {
    return Intl.message(
      'Theme Color',
      name: 'change_theme_color',
      desc: '',
      args: [],
    );
  }

  /// `Change the primay color of the app`
  String get change_theme_color_subtitle {
    return Intl.message(
      'Change the primay color of the app',
      name: 'change_theme_color_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Theme Mode`
  String get change_theme_mode {
    return Intl.message(
      'Theme Mode',
      name: 'change_theme_mode',
      desc: '',
      args: [],
    );
  }

  /// `Change form light / dark / system modes`
  String get change_theme_mode_subtitle {
    return Intl.message(
      'Change form light / dark / system modes',
      name: 'change_theme_mode_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get change_language {
    return Intl.message(
      'Language',
      name: 'change_language',
      desc: '',
      args: [],
    );
  }

  /// `Change the display language of the app`
  String get change_language_subtitle {
    return Intl.message(
      'Change the display language of the app',
      name: 'change_language_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Dense Mode`
  String get enable_dense_favorites_mode {
    return Intl.message(
      'Dense Mode',
      name: 'enable_dense_favorites_mode',
      desc: '',
      args: [],
    );
  }

  /// `Display more favorite rooms at once`
  String get enable_dense_favorites_mode_subtitle {
    return Intl.message(
      'Display more favorite rooms at once',
      name: 'enable_dense_favorites_mode_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Play Background`
  String get enable_background_play {
    return Intl.message(
      'Play Background',
      name: 'enable_background_play',
      desc: '',
      args: [],
    );
  }

  /// `When leave app, allow video play background`
  String get enable_background_play_subtitle {
    return Intl.message(
      'When leave app, allow video play background',
      name: 'enable_background_play_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Keep Screen On`
  String get enable_screen_keep_on {
    return Intl.message(
      'Keep Screen On',
      name: 'enable_screen_keep_on',
      desc: '',
      args: [],
    );
  }

  /// `When in live play, keep screen on`
  String get enable_screen_keep_on_subtitle {
    return Intl.message(
      'When in live play, keep screen on',
      name: 'enable_screen_keep_on_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Auto Full Screen`
  String get enable_fullscreen_default {
    return Intl.message(
      'Auto Full Screen',
      name: 'enable_fullscreen_default',
      desc: '',
      args: [],
    );
  }

  /// `When in live play, auto into full screen`
  String get enable_fullscreen_default_subtitle {
    return Intl.message(
      'When in live play, auto into full screen',
      name: 'enable_fullscreen_default_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Auto Check Update`
  String get enable_auto_check_update {
    return Intl.message(
      'Auto Check Update',
      name: 'enable_auto_check_update',
      desc: '',
      args: [],
    );
  }

  /// `When enter into app, auto check update`
  String get enable_auto_check_update_subtitle {
    return Intl.message(
      'When enter into app, auto check update',
      name: 'enable_auto_check_update_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `float overlay ratio`
  String get float_overlay_ratio {
    return Intl.message(
      'float overlay ratio',
      name: 'float_overlay_ratio',
      desc: '',
      args: [],
    );
  }

  /// `When using float window, ratio control the size`
  String get float_overlay_ratio_subtitle {
    return Intl.message(
      'When using float window, ratio control the size',
      name: 'float_overlay_ratio_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Bilibili Cookie`
  String get bilibili_cookie {
    return Intl.message(
      'Bilibili Cookie',
      name: 'bilibili_cookie',
      desc: '',
      args: [],
    );
  }

  /// `Enable bilibili search cookie`
  String get enable_bilibili_search_cookie {
    return Intl.message(
      'Enable bilibili search cookie',
      name: 'enable_bilibili_search_cookie',
      desc: '',
      args: [],
    );
  }

  /// `Set custom bilibili search needed cookie`
  String get enable_bilibili_search_cookie_subtitle {
    return Intl.message(
      'Set custom bilibili search needed cookie',
      name: 'enable_bilibili_search_cookie_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Check Update`
  String get check_update {
    return Intl.message(
      'Check Update',
      name: 'check_update',
      desc: '',
      args: [],
    );
  }

  /// `New version found: v{version}`
  String new_version_info(Object version) {
    return Intl.message(
      'New version found: v$version',
      name: 'new_version_info',
      desc: '',
      args: [version],
    );
  }

  /// `You are using the latest version.`
  String get no_new_version_info {
    return Intl.message(
      'You are using the latest version.',
      name: 'no_new_version_info',
      desc: '',
      args: [],
    );
  }

  /// `New Features`
  String get what_is_new {
    return Intl.message(
      'New Features',
      name: 'what_is_new',
      desc: '',
      args: [],
    );
  }

  /// `Danmaku area`
  String get settings_danmaku_area {
    return Intl.message(
      'Danmaku area',
      name: 'settings_danmaku_area',
      desc: '',
      args: [],
    );
  }

  /// `Danmaku opacity`
  String get settings_danmaku_opacity {
    return Intl.message(
      'Danmaku opacity',
      name: 'settings_danmaku_opacity',
      desc: '',
      args: [],
    );
  }

  /// `Danmaku speed`
  String get settings_danmaku_speed {
    return Intl.message(
      'Danmaku speed',
      name: 'settings_danmaku_speed',
      desc: '',
      args: [],
    );
  }

  /// `Danmaku fontsize`
  String get settings_danmaku_fontsize {
    return Intl.message(
      'Danmaku fontsize',
      name: 'settings_danmaku_fontsize',
      desc: '',
      args: [],
    );
  }

  /// `Border width`
  String get settings_danmaku_fontBorder {
    return Intl.message(
      'Border width',
      name: 'settings_danmaku_fontBorder',
      desc: '',
      args: [],
    );
  }

  /// `Follow`
  String get follow {
    return Intl.message(
      'Follow',
      name: 'follow',
      desc: '',
      args: [],
    );
  }

  /// `Unfollow`
  String get unfollow {
    return Intl.message(
      'Unfollow',
      name: 'unfollow',
      desc: '',
      args: [],
    );
  }

  /// `Followed`
  String get followed {
    return Intl.message(
      'Followed',
      name: 'followed',
      desc: '',
      args: [],
    );
  }

  /// `Offline`
  String get offline {
    return Intl.message(
      'Offline',
      name: 'offline',
      desc: '',
      args: [],
    );
  }

  /// `{name} is offline.`
  String info_is_offline(Object name) {
    return Intl.message(
      '$name is offline.',
      name: 'info_is_offline',
      desc: '',
      args: [name],
    );
  }

  /// `DLNA Broadcast`
  String get dlan_button_info {
    return Intl.message(
      'DLNA Broadcast',
      name: 'dlan_button_info',
      desc: '',
      args: [],
    );
  }

  /// `DLNA`
  String get dlan_title {
    return Intl.message(
      'DLNA',
      name: 'dlan_title',
      desc: '',
      args: [],
    );
  }

  /// `DLNA device not found`
  String get dlan_device_not_found {
    return Intl.message(
      'DLNA device not found',
      name: 'dlan_device_not_found',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
