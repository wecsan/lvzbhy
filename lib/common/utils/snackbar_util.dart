import 'package:pure_live/common/index.dart';

class SnackBarUtil {
  static void success(BuildContext context, String text) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
      duration: const Duration(seconds: 2),
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      content: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ));
  }

  static void error(BuildContext context, String text) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
      duration: const Duration(seconds: 2),
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      content: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
    ));
  }
}
