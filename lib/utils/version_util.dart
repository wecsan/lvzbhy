import 'dart:convert';
import 'package:http/http.dart' as http;

class VersionUtil {
  static const String version = '0.9.12';
  static const String projectUrl = 'https://github.com/Jackiu1997/hot_live';
  static const String releaseUrl =
      'https://api.github.com/repos/Jackiu1997/hot_live/releases';

  static String latestVersion = version;
  static String latestUpdateLog = '';

  static Future<void> checkUpdate() async {
    try {
      var response = await http.get(Uri.parse(releaseUrl));
      var latest = (await jsonDecode(response.body))[0];
      latestVersion = latest['tag_name'].replaceAll('v', '');
      latestUpdateLog = latest['body'];
    } catch (e) {
      latestUpdateLog = e.toString();
    }
  }

  static bool hasNewVersion() {
    List latestVersions = latestVersion.split('-')[0].split('.');
    List versions = version.split('-')[0].split('.');
    for (int i = 0; i < latestVersions.length; i++) {
      if (int.parse(latestVersions[i]) > int.parse(versions[i])) {
        return true;
      } else if (int.parse(latestVersions[i]) < int.parse(versions[i])) {
        return false;
      }
    }
    return false;
  }
}
