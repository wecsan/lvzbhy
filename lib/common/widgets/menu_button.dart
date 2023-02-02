import 'package:pure_live/common/index.dart';
import 'package:pure_live/pages/index.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({Key? key}) : super(key: key);

  final menuRoutes = const [
    SettingsPage(),
    AboutPage(),
    AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      tooltip: 'menu',
      color: Theme.of(context).colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      offset: const Offset(12, 0),
      position: PopupMenuPosition.under,
      icon: const Icon(Icons.menu_rounded),
      onSelected: (int index) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => menuRoutes[index]),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: MenuListTile(
            leading: const Icon(Icons.settings_rounded),
            text: S.of(context).settings_title,
          ),
        ),
        PopupMenuItem(
          value: 1,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: MenuListTile(
            leading: const Icon(Icons.info_outline_rounded),
            text: S.of(context).about,
          ),
        ),
        PopupMenuItem(
          value: 2,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: MenuListTile(
            leading: const Icon(Icons.help_outline_rounded),
            text: S.of(context).help,
          ),
        ),
      ],
    );
  }
}

class MenuListTile extends StatelessWidget {
  final Widget? leading;
  final String text;
  final Widget? trailing;

  const MenuListTile({
    Key? key,
    required this.leading,
    required this.text,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 12),
        ],
        Text(
          text,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        if (trailing != null) ...[
          const SizedBox(width: 24),
          trailing!,
        ],
      ],
    );
  }
}
