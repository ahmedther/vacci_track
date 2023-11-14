import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final Color uiColor;
  final Color backgroundColor;
  final void Function()? onPressed;
  final double deviceWidth;

  const CustomSearchBar(
      {required this.onPressed,
      required this.deviceWidth,
      this.uiColor = Colors.blue,
      this.backgroundColor = Colors.white,
      this.controller,
      super.key});

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: controller,
      elevation: const MaterialStatePropertyAll(2),
      hintText: "Search For A Dose",
      hintStyle: MaterialStateProperty.all<TextStyle>(
          const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: MaterialStateProperty.all<Color>(
        backgroundColor,
      ),
      leading: FaIcon(
        FontAwesomeIcons.magnifyingGlass,
        color: uiColor,
      ),
      trailing: Iterable.generate(
        1,
        (index) {
          return OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(width: 2, color: uiColor),
            ),
            onPressed: onPressed,
            child: Text(
              deviceWidth < 900 ? '🔎' : 'Search',
              style: TextStyle(
                color: uiColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
      onChanged: (value) {},
    );
  }
}
