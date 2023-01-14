import 'package:flutter/material.dart';
import 'package:hot_live/pages/about.dart';
import 'package:hot_live/provider/settings_provider.dart';
import 'package:hot_live/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  final String appVersion = '0.9.6';

  @override
  Widget build(BuildContext context) {
    SettingsProvider settings = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          const SectionTitle(title: 'General'),
          ListTile(
            title: const Text('Change Theme Color'),
            subtitle: const Text('Change the theme color of the app'),
            leading: const Icon(Icons.color_lens, size: 32),
            onTap: () {
              Provider.of<AppThemeProvider>(context, listen: false)
                  .showThemeColorSelectorDialog(context);
            },
          ),
          ListTile(
            title: const Text('Change Theme Mode'),
            subtitle: const Text('Change the theme mode of the app'),
            leading: const Icon(Icons.dark_mode_rounded, size: 32),
            onTap: () {
              Provider.of<AppThemeProvider>(context, listen: false)
                  .showThemeModeSelectorDialog(context);
            },
          ),
          ListTile(
            title: const Text('Change Language'),
            subtitle: const Text('Change the language of the app [x]'),
            leading: const Icon(Icons.translate_rounded, size: 32),
            onTap: () {},
          ),
          const SectionTitle(title: 'Custom'),
          ListTile(
            title: const Text('Set custom bilibili cookie for search'),
            subtitle: const Text(
              'Use custom cookie for bilibili search api, because bilibili search need cookie vaildation',
            ),
            onTap: () {
              final cookie = settings.bilibiliCustomCookie;
              final controller = TextEditingController(text: cookie);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Bilibili Cookie'),
                  content: TextField(
                    controller: controller,
                    autofocus: true,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        return Navigator.pop(context);
                      },
                      child: const Text("Cancle"),
                    ),
                    TextButton(
                      onPressed: () {
                        settings.bilibiliCustomCookie = controller.text;
                        return Navigator.pop(context);
                      },
                      child: const Text("Confirm"),
                    ),
                  ],
                ),
              );
            },
          ),
          SwitchListTile(
            title: const Text('Use custom resolution for Huya'),
            subtitle: const Text(
                'Use custom resolution for Huya, if you want to use a custom resolution'),
            value: settings.useCustomResolutionForHuya,
            activeColor: Provider.of<AppThemeProvider>(context).themeColor,
            onChanged: (bool value) {
              settings.useCustomResolutionForHuya = value;
            },
          ),
          const SectionTitle(title: 'About'),
          CheckForUpdate(version: appVersion),
          About(version: appVersion),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    required this.title,
    Key? key,
  }) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.headline2),
    );
  }
}
