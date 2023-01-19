// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(name) => "${name} is offline.";

  static String m1(version) => "New version found: v${version}";

  static String m2(roomid, platform, nickname, title, livestatus) =>
      "RoomId: ${roomid}\nPlatform: ${platform}\nName: ${nickname}\nTitle: ${title}\nLiveStatus: ${livestatus}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("About"),
        "app_name": MessageLookupByLibrary.simpleMessage("HotLive"),
        "areas_title": MessageLookupByLibrary.simpleMessage("Areas"),
        "bilibili_cookie":
            MessageLookupByLibrary.simpleMessage("Bilibili Cookie"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "change_language": MessageLookupByLibrary.simpleMessage("Language"),
        "change_language_subtitle": MessageLookupByLibrary.simpleMessage(
            "Change the display language of the app"),
        "change_theme_color":
            MessageLookupByLibrary.simpleMessage("Theme Color"),
        "change_theme_color_subtitle": MessageLookupByLibrary.simpleMessage(
            "Change the primay color of the app"),
        "change_theme_mode": MessageLookupByLibrary.simpleMessage("Theme Mode"),
        "change_theme_mode_subtitle": MessageLookupByLibrary.simpleMessage(
            "Change form light / dark / system modes"),
        "check_update": MessageLookupByLibrary.simpleMessage("Check Update"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "custom": MessageLookupByLibrary.simpleMessage("Custom"),
        "dlan_button_info":
            MessageLookupByLibrary.simpleMessage("DLNA Broadcast"),
        "dlan_device_not_found":
            MessageLookupByLibrary.simpleMessage("DLNA device not found"),
        "dlan_title": MessageLookupByLibrary.simpleMessage("DLNA"),
        "empty_areas_room_subtitle":
            MessageLookupByLibrary.simpleMessage("Pull down to refresh data"),
        "empty_areas_room_title":
            MessageLookupByLibrary.simpleMessage("No Live Found"),
        "empty_areas_subtitle": MessageLookupByLibrary.simpleMessage(
            "Click the button below\nto switch platform"),
        "empty_areas_title":
            MessageLookupByLibrary.simpleMessage("No Area Found"),
        "empty_favorite_subtitle": MessageLookupByLibrary.simpleMessage(
            "Please follow live rooms first"),
        "empty_favorite_title":
            MessageLookupByLibrary.simpleMessage("No Favorites"),
        "empty_live_subtitle": MessageLookupByLibrary.simpleMessage(
            "Click the button below\nto switch platform"),
        "empty_live_title":
            MessageLookupByLibrary.simpleMessage("No Live Found"),
        "empty_search_subtitle":
            MessageLookupByLibrary.simpleMessage("You can input other keyword"),
        "empty_search_title":
            MessageLookupByLibrary.simpleMessage("No Live Found"),
        "enable_auto_check_update":
            MessageLookupByLibrary.simpleMessage("Auto Check Update"),
        "enable_auto_check_update_subtitle":
            MessageLookupByLibrary.simpleMessage(
                "When enter into app, auto check update"),
        "enable_background_play":
            MessageLookupByLibrary.simpleMessage("Play Background"),
        "enable_background_play_subtitle": MessageLookupByLibrary.simpleMessage(
            "When leave app, allow video play background"),
        "enable_bilibili_search_cookie": MessageLookupByLibrary.simpleMessage(
            "Enable bilibili search cookie"),
        "enable_bilibili_search_cookie_subtitle":
            MessageLookupByLibrary.simpleMessage(
                "Set custom bilibili search needed cookie"),
        "enable_dense_favorites_mode":
            MessageLookupByLibrary.simpleMessage("Dense Mode"),
        "enable_dense_favorites_mode_subtitle":
            MessageLookupByLibrary.simpleMessage(
                "Display more favorite rooms at once"),
        "enable_screen_keep_on":
            MessageLookupByLibrary.simpleMessage("Keep Screen On"),
        "enable_screen_keep_on_subtitle": MessageLookupByLibrary.simpleMessage(
            "When in live play, keep screen on"),
        "experiment": MessageLookupByLibrary.simpleMessage("Experiment"),
        "favorites_title": MessageLookupByLibrary.simpleMessage("Favorites"),
        "float_overlay_ratio":
            MessageLookupByLibrary.simpleMessage("float overlay ratio"),
        "float_overlay_ratio_subtitle": MessageLookupByLibrary.simpleMessage(
            "When using float window, ratio control the size"),
        "follow": MessageLookupByLibrary.simpleMessage("Follow"),
        "followed": MessageLookupByLibrary.simpleMessage("Followed"),
        "general": MessageLookupByLibrary.simpleMessage("General"),
        "hide_offline_rooms":
            MessageLookupByLibrary.simpleMessage("Hide Offline Rooms"),
        "info_is_offline": m0,
        "loading_canload":
            MessageLookupByLibrary.simpleMessage("release to load"),
        "loading_failed":
            MessageLookupByLibrary.simpleMessage("Load Failed! Drag Retry!"),
        "loading_idle": MessageLookupByLibrary.simpleMessage("pull up to load"),
        "loading_nomore": MessageLookupByLibrary.simpleMessage("No more Data"),
        "move_to_top": MessageLookupByLibrary.simpleMessage("Move To Top"),
        "new_version_info": m1,
        "no_new_version_info": MessageLookupByLibrary.simpleMessage(
            "You are using the latest version."),
        "offline": MessageLookupByLibrary.simpleMessage("Offline"),
        "only_living": MessageLookupByLibrary.simpleMessage("Only Living"),
        "popular_title": MessageLookupByLibrary.simpleMessage("Popular"),
        "remove": MessageLookupByLibrary.simpleMessage("Remove"),
        "room_info_content": m2,
        "search_input_hint":
            MessageLookupByLibrary.simpleMessage("Input live room keyword"),
        "settings_danmaku_area":
            MessageLookupByLibrary.simpleMessage("Danmaku area"),
        "settings_danmaku_fontBorder":
            MessageLookupByLibrary.simpleMessage("Border width"),
        "settings_danmaku_fontsize":
            MessageLookupByLibrary.simpleMessage("Danmaku fontsize"),
        "settings_danmaku_opacity":
            MessageLookupByLibrary.simpleMessage("Danmaku opacity"),
        "settings_danmaku_speed":
            MessageLookupByLibrary.simpleMessage("Danmaku speed"),
        "settings_title": MessageLookupByLibrary.simpleMessage("Settings"),
        "show_offline_rooms":
            MessageLookupByLibrary.simpleMessage("Show Offline Rooms"),
        "switch_platform":
            MessageLookupByLibrary.simpleMessage("Switch platform"),
        "unfollow": MessageLookupByLibrary.simpleMessage("Unfollow"),
        "update": MessageLookupByLibrary.simpleMessage("Update"),
        "what_is_new": MessageLookupByLibrary.simpleMessage("New Features")
      };
}
