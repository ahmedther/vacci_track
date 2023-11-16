import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/components/text_style.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final Color uiColor;
  final Color backgroundColor;
  final void Function()? onPressed;
  final void Function(String)? onChanged;
  final double deviceWidth;
  final String? hintText;
  final String buttonText;
  final void Function()? onTap;

  const CustomSearchBar(
      {required this.onPressed,
      required this.deviceWidth,
      this.uiColor = Colors.blue,
      this.backgroundColor = Colors.white,
      this.buttonText = 'Search',
      this.controller,
      this.onChanged,
      this.hintText,
      this.onTap,
      super.key});

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: controller,
      elevation: const MaterialStatePropertyAll(2),
      hintText: hintText,
      textStyle: MaterialStateProperty.all(
          const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
            child: CustomTextStyle(
                text: deviceWidth < 900 ? '🔎' : buttonText,
                color: uiColor,
                isBold: true),
          );
        },
      ),
      onChanged: onChanged,
      onTap: onTap,
    );
  }
}
