import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({
    required this.version,
    Key? key,
  }) : super(key: key);

  final String version;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('About HotLive'),
      leading: const Icon(
        Icons.info_outline_rounded,
        size: 32,
      ),
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: 'HotLive',
          applicationVersion: version,
          applicationIcon: SizedBox(
            width: 60,
            child: Center(
              child: Image.asset('assets/icon.png'),
            ),
          ),
          children: [
            ListTile(
              title: const Text('Github'),
              leading: const Icon(
                Icons.open_in_new_rounded,
                size: 32,
              ),
              onTap: () {
                _launchUrl('https://github.com/Jackiu1997/hot_live');
              },
            ),
          ],
        );
      },
    );
  }
}

class CheckForUpdate extends StatelessWidget {
  const CheckForUpdate({
    Key? key,
    required this.version,
  }) : super(key: key);

  final String version;

  Future<String> judgeVersion(String version) async {
    var resp = await http.get(
        Uri.parse('https://api.github.com/repos/Jackiu1997/hot_live/releases'));
    var body = await jsonDecode(resp.body);
    String networkVersion = body[0]['tag_name'].replaceAll('v', '');
    List networkVersions = networkVersion.split('-')[0].split('.');
    List versions = version.split('-')[0].split('.');
    for (int i = 0; i < networkVersions.length; i++) {
      if (int.parse(networkVersions[i]) > int.parse(versions[i])) {
        return '1-$networkVersion';
      } else if (int.parse(networkVersions[i]) < int.parse(versions[i])) {
        return '0-$networkVersion';
      }
    }
    if (version == networkVersion) {
      return '0-$networkVersion';
    } else {
      throw Exception('版本号不正确:$version$networkVersion');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Check Update'),
      subtitle: Text('v$version'),
      leading: const Icon(
        Icons.file_upload_outlined,
        size: 32,
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => FutureBuilder(
            future: judgeVersion(version),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List result = (snapshot.data as String).split('-');
                if (result[0] == '1') {
                  return AlertDialog(
                    title: const Text('Check for updates'),
                    content: Text(
                        'There is a new version: ${result[1]} available, do you want to update?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      ElevatedButton(
                        child: const Text('Update'),
                        onPressed: () {
                          Navigator.pop(context);
                          _launchUrl(
                              'https://github.com/Jackiu1997/hot_live/releases');
                        },
                      ),
                    ],
                  );
                } else {
                  return AlertDialog(
                    title: const Text('Check for updates'),
                    content: const Text('You are using the latest version.'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                }
              } else if (snapshot.hasError) {
                return AlertDialog(
                  title: const Text('Check for updates'),
                  content: const Text(
                      'Failed to check for updates, please try again later.'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              } else {
                return const AlertDialog(
                  title: Text('Loading'),
                  content: LinearProgressIndicator(
                    minHeight: 10,
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}

Future<void> _launchUrl(_url) async {
  //print('launching $_url');
  if (!await launchUrl(
    Uri.parse(_url),
    mode: LaunchMode.externalApplication,
  )) {
    throw 'Could not launch $_url';
  }
}
