import 'package:pure_live/common/index.dart';
import 'package:pure_live/pages/index.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchPage()),
            );
          },
          icon: const Icon(CustomIcons.search),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
