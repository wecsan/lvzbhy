import 'package:flutter/cupertino.dart';
import 'package:hot_live/common/index.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets/check_update.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingsProvider settings = Provider.of<SettingsProvider>(context);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: screenWidth > 640 ? 0 : null,
        title: Text(S.of(context).settings_title),
      ),
      body: ListView(
        children: <Widget>[
          SectionTitle(title: S.of(context).general),
          ListTile(
            leading: const Icon(Icons.dark_mode_rounded, size: 32),
            title: Text(S.of(context).change_theme_mode),
            subtitle: Text(S.of(context).change_theme_mode_subtitle),
            onTap: showThemeModeSelectorDialog,
          ),
          ListTile(
            leading: const Icon(Icons.color_lens, size: 32),
            title: Text(S.of(context).change_theme_color),
            subtitle: Text(S.of(context).change_theme_color_subtitle),
            onTap: showThemeColorSelectorDialog,
          ),
          ListTile(
            leading: const Icon(Icons.translate_rounded, size: 32),
            title: Text(S.of(context).change_language),
            subtitle: Text(S.of(context).change_language_subtitle),
            onTap: showLanguageSelecterDialog,
          ),
          SectionTitle(title: S.of(context).video),
          CupertinoSwitchListTile(
            title: Text(S.of(context).enable_background_play),
            subtitle: Text(S.of(context).enable_background_play_subtitle),
            value: settings.enableBackgroundPlay,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (bool value) => settings.enableBackgroundPlay = value,
          ),
          CupertinoSwitchListTile(
            title: Text(S.of(context).enable_screen_keep_on),
            subtitle: Text(S.of(context).enable_screen_keep_on_subtitle),
            value: settings.enableScreenKeepOn,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (bool value) => settings.enableScreenKeepOn = value,
          ),
          CupertinoSwitchListTile(
            title: Text(S.of(context).enable_fullscreen_default),
            subtitle: Text(S.of(context).enable_fullscreen_default_subtitle),
            value: settings.enableFullScreenDefault,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (bool value) => settings.enableFullScreenDefault = value,
          ),
          ListTile(
            title: Text(S.of(context).prefer_resolution),
            subtitle: Text(S.of(context).prefer_resolution_subtitle),
            onTap: showPreferResolutionSelectorDialog,
          ),
          SectionTitle(title: S.of(context).custom),
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
            title: Text(S.of(context).prefer_platform),
            subtitle: Text(S.of(context).prefer_platform_subtitle),
            onTap: showPreferPlatformSelectorDialog,
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
            title: Text(S.of(context).what_is_new),
            leading: const Icon(Icons.fiber_new_rounded, size: 30),
            onTap: showNewFeaturesDialog,
          ),
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

  void showPreferResolutionSelectorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(S.of(context).prefer_resolution),
          children: SettingsProvider.resolutions.map<Widget>((name) {
            return RadioListTile<String>(
              activeColor: Theme.of(context).colorScheme.primary,
              groupValue: settings.preferResolution,
              value: name,
              title: Text(name),
              onChanged: (value) {
                settings.changePreferResolution(value!);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        );
      },
    );
  }

  void showPreferPlatformSelectorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(S.of(context).prefer_resolution),
          children: SettingsProvider.platforms.map<Widget>((name) {
            return RadioListTile<String>(
              activeColor: Theme.of(context).colorScheme.primary,
              groupValue: settings.preferPlatform,
              value: name,
              title: Text(name.toUpperCase()),
              onChanged: (value) {
                settings.changePreferPlatform(value!);
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
          leading: const Icon(CustomIcons.github_circled, size: 30),
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

class CupertinoSwitchListTile extends StatelessWidget {
  const CupertinoSwitchListTile({
    Key? key,
    required this.value,
    required this.onChanged,
    this.leading,
    this.title,
    this.subtitle,
    this.activeColor,
  }) : super(key: key);

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Color? activeColor;
  final bool value;
  final void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
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
