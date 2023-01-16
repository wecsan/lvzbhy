import 'package:flutter/material.dart';
import 'package:hot_live/generated/l10n.dart';
import 'package:hot_live/provider/settings_provider.dart';
import 'package:provider/provider.dart';

import 'about.dart';
import 'check_update.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingsProvider settings = Provider.of<SettingsProvider>(context);

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
          SwitchListTile(
            title: Text(S.of(context).enable_auto_check_update),
            subtitle: Text(S.of(context).enable_auto_check_update_subtitle),
            value: settings.enbaleAutoCheckUpdate,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (bool value) {
              settings.enbaleAutoCheckUpdate = value;
            },
          ),
          ListTile(
            title: Text(S.of(context).enable_bilibili_search_cookie),
            subtitle:
                Text(S.of(context).enable_bilibili_search_cookie_subtitle),
            onTap: showBilibliCookieSetDialog,
          ),
          SectionTitle(title: S.of(context).about),
          const CheckUpdate(),
          const About(),
        ],
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
        style: Theme.of(context)
            .textTheme
            .headline4
            ?.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}
