import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hot_live/generated/l10n.dart';
import 'package:hot_live/provider/settings_provider.dart';
import 'package:hot_live/utils/version_util.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'check_update.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingsProvider settings = Provider.of<SettingsProvider>(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settings_title),
      ),
      body: ListView(
        children: <Widget>[
          SectionTitle(title: S.of(context).general),
          ListTile(
            title: Text(S.of(context).change_theme_mode),
            subtitle: Text(S.of(context).change_theme_mode_subtitle),
            leading: const Icon(Icons.dark_mode_rounded, size: 32),
            onTap: showThemeModeSelectorDialog,
          ),
          ListTile(
            title: Text(S.of(context).change_theme_color),
            subtitle: Text(S.of(context).change_theme_color_subtitle),
            leading: const Icon(Icons.color_lens, size: 32),
            onTap: showThemeColorSelectorDialog,
          ),
          ListTile(
            title: Text(S.of(context).change_language),
            subtitle: Text(S.of(context).change_language_subtitle),
            leading: const Icon(Icons.translate_rounded, size: 32),
            onTap: showLanguageSelecterDialog,
          ),
          CupertinoSwitchListTile(
            title: Text(S.of(context).enable_dense_favorites_mode),
            subtitle: Text(S.of(context).enable_dense_favorites_mode_subtitle),
            value: settings.enableDenseFavorites,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (bool value) => settings.enableDenseFavorites = value,
          ),
          CupertinoSwitchListTile(
            title: Text(S.of(context).enable_auto_check_update),
            subtitle: Text(S.of(context).enable_auto_check_update_subtitle),
            value: settings.enableAutoCheckUpdate,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (bool value) => settings.enableAutoCheckUpdate = value,
          ),
          ListTile(
            title: Text(S.of(context).enable_bilibili_search_cookie),
            subtitle:
                Text(S.of(context).enable_bilibili_search_cookie_subtitle),
            onTap: showBilibliCookieSetDialog,
          ),
          SectionTitle(title: S.of(context).about),
          const CheckUpdateListTile(),
          ListTile(
            title: Text(S.of(context).about),
            leading: const Icon(Icons.info_outline_rounded, size: 32),
            onTap: showAboutInfoDialog,
          ),
        ],
      ),
    );
  }

  void showThemeModeSelectorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(S.of(context).change_theme_mode),
          children: SettingsProvider.themeModes.keys.map<Widget>((name) {
            return RadioListTile<String>(
              activeColor: Theme.of(context).colorScheme.primary,
              groupValue: settings.themeModeName,
              value: name,
              title: Text(name),
              onChanged: (value) {
                settings.changeThemeMode(value!);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        );
      },
    );
  }

  void showThemeColorSelectorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(S.of(context).change_theme_color),
          children: SettingsProvider.themeColors.keys.map<Widget>((name) {
            final color = SettingsProvider.themeColors[name];
            return RadioListTile<String>(
              activeColor: Theme.of(context).colorScheme.primary,
              groupValue: settings.themeColorName,
              value: name,
              title: Text(name, style: TextStyle(color: color)),
              onChanged: (value) {
                settings.changeThemeColor(value!);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        );
      },
    );
  }

  void showLanguageSelecterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(S.of(context).change_language),
          children: SettingsProvider.languages.keys.map<Widget>((name) {
            return RadioListTile<String>(
              activeColor: Theme.of(context).colorScheme.primary,
              groupValue: settings.languageName,
              value: name,
              title: Text(name),
              onChanged: (value) {
                settings.changeLanguage(value!);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        );
      },
    );
  }

  void showBilibliCookieSetDialog() {
    final cookie = settings.bilibiliCustomCookie;
    final controller = TextEditingController(text: cookie);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).bilibili_cookie),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              settings.bilibiliCustomCookie = controller.text;
              Navigator.of(context).pop();
            },
            child: Text(S.of(context).confirm),
          ),
        ],
      ),
    );
  }

  void showAboutInfoDialog() {
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
  }
}

class CupertinoSwitchListTile extends StatelessWidget {
  const CupertinoSwitchListTile({
    Key? key,
    required this.value,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.activeColor,
  }) : super(key: key);

  final Widget? title;
  final Widget? subtitle;
  final Color? activeColor;
  final bool value;
  final void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      subtitle: subtitle,
      trailing: CupertinoSwitch(
        value: value,
        activeColor: activeColor,
        onChanged: onChanged,
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    required this.title,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
