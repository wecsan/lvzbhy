import 'package:flutter/services.dart';
import 'package:hot_live/common/index.dart';
import 'package:hot_live/pages/about/donate.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets/version_dialog.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late SettingsProvider settings = Provider.of<SettingsProvider>(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: <Widget>[
          SectionTitle(title: S.of(context).about),
          ListTile(
            title: Text(S.of(context).what_is_new),
            onTap: showNewFeaturesDialog,
          ),
          ListTile(
            title: Text(S.of(context).check_update),
            onTap: () => showCheckUpdateDialog(context),
          ),
          ListTile(
            title: Text(S.of(context).version),
            subtitle: const Text(VersionUtil.version),
          ),
          ListTile(
            title: Text(S.of(context).license),
            onTap: showLicenseDialog,
          ),
          SectionTitle(title: S.of(context).project),
          ListTile(
            title: Text(S.of(context).support_donate),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DonatePage()),
            ),
          ),
          ListTile(
            title: Text(S.of(context).issue_feedback),
            onTap: () {
              launchUrl(
                Uri.parse(VersionUtil.issuesUrl),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          ListTile(
            title: Text(S.of(context).develop_progress),
            onTap: () {
              launchUrl(
                Uri.parse(VersionUtil.kanbanUrl),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          ListTile(
            title: Text(S.of(context).project_page),
            subtitle: const Text(VersionUtil.projectUrl),
            onTap: () {
              launchUrl(
                Uri.parse(VersionUtil.projectUrl),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          ListTile(
            title: Text(S.of(context).project_alert),
            subtitle: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(S.of(context).app_legalese),
            ),
          ),
          SectionTitle(title: S.of(context).contact),
          ListTile(
            leading: const Icon(CustomIcons.telegram, size: 32),
            title: Text(S.of(context).telegram),
            subtitle: const Text(VersionUtil.telegramGroup),
            onLongPress: () => Clipboard.setData(
                const ClipboardData(text: VersionUtil.telegramGroup)),
            onTap: () {
              launchUrl(
                Uri.parse(VersionUtil.telegramGroupUrl),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          ListTile(
            leading: const Icon(CustomIcons.mail_squared, size: 34),
            title: Text(S.of(context).email),
            subtitle: const Text(VersionUtil.email),
            onLongPress: () =>
                Clipboard.setData(const ClipboardData(text: VersionUtil.email)),
            onTap: () {
              launchUrl(
                Uri.parse(VersionUtil.emailUrl),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          ListTile(
            leading: const Icon(CustomIcons.github_circled, size: 32),
            title: Text(S.of(context).github),
            subtitle: const Text(VersionUtil.githubUrl),
            onTap: () {
              launchUrl(
                Uri.parse(VersionUtil.githubUrl),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
        ],
      ),
    );
  }

  void showCheckUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => VersionUtil.hasNewVersion()
          ? const NewVersionDialog()
          : const NoNewVersionDialog(),
    );
  }

  void showLicenseDialog() {
    showLicensePage(
      context: context,
      applicationName: 'HotLive',
      applicationVersion: VersionUtil.version,
      applicationIcon: SizedBox(
        width: 60,
        child: Center(child: Image.asset('assets/icons/icon.png')),
      ),
    );
  }

  void showNewFeaturesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).what_is_new),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Version ${VersionUtil.latestVersion}'),
            const SizedBox(height: 20),
            Text(
              VersionUtil.latestUpdateLog,
              style: Theme.of(context).textTheme.caption,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
