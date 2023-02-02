import 'package:pure_live/common/index.dart';

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
        physics: const BouncingScrollPhysics(),
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
            title: Text(S.of(context).enable_dynamic_color),
            subtitle: Text(S.of(context).enable_dynamic_color_subtitle),
            value: settings.enableDynamicTheme,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (bool value) => settings.enableDynamicTheme = value,
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
          ListTile(
            title: Text(S.of(context).auto_refresh_time),
            subtitle: Text(S.of(context).auto_refresh_time_subtitle),
            trailing: Text('${settings.autoRefreshTime}s'),
            onTap: showAutoRefreshTimeSetDialog,
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

  void showAutoRefreshTimeSetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // title: Text(S.of(context).auto_refresh_time),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              min: 10,
              max: 120,
              label: S.of(context).auto_refresh_time,
              value: settings.autoRefreshTime.toDouble(),
              onChanged: (value) => settings.autoRefreshTime = value.toInt(),
            ),
            Text('${S.of(context).auto_refresh_time}:'
                ' ${settings.autoRefreshTime}s'),
          ],
        ),
      ),
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
}
