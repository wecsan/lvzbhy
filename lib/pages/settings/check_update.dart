import 'package:flutter/material.dart';
import 'package:hot_live/utils/version_util.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckUpdate extends StatelessWidget {
  const CheckUpdate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Check Update'),
      subtitle: const Text('v${VersionUtil.version}'),
      leading: const Icon(
        Icons.file_upload_outlined,
        size: 32,
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => VersionUtil.hasNewVersion()
              ? const NewVersionDialog()
              : const NoNewVersionDialog(),
        );
      },
    );
  }
}

class NoNewVersionDialog extends StatelessWidget {
  const NoNewVersionDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}

class NewVersionDialog extends StatelessWidget {
  const NewVersionDialog({Key? key, this.entry}) : super(key: key);

  final OverlayEntry? entry;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Check for updates'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('New version found: v${VersionUtil.latestVersion}'),
          const SizedBox(height: 20),
          Text(
            VersionUtil.latestUpdateLog,
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            if (entry != null) {
              entry!.remove();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        ElevatedButton(
          child: const Text('Update'),
          onPressed: () {
            if (entry != null) {
              entry!.remove();
            } else {
              Navigator.pop(context);
            }
            launchUrl(
              Uri.parse('https://github.com/Jackiu1997/hot_live/releases'),
              mode: LaunchMode.externalApplication,
            );
          },
        ),
      ],
    );
  }
}
