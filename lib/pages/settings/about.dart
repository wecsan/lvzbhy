import 'package:flutter/material.dart';
import 'package:hot_live/utils/version_util.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({Key? key}) : super(key: key);

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
          applicationVersion: VersionUtil.version,
          applicationIcon: SizedBox(
            width: 60,
            child: Center(child: Image.asset('assets/icon.png')),
          ),
          children: [
            ListTile(
              title: const Text('Github'),
              leading: const Icon(
                Icons.open_in_new_rounded,
                size: 32,
              ),
              onTap: () {
                launchUrl(
                  Uri.parse(VersionUtil.projectUrl),
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
