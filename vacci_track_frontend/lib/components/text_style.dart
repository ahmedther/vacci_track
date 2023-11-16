import 'package:flutter/material.dart';

class CustomTextStyle extends StatelessWidget {
  final String text;
  final Color? color;
  final bool isBold;

  const CustomTextStyle(
      {required this.text, this.color, this.isBold = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          TextStyle(color: color, fontWeight: isBold ? FontWeight.bold : null),
    );
  }
}
