import 'package:flutter/material.dart';

class CustomTextStyle extends StatelessWidget {
  final String text;
  final Color? color;
  final bool isBold;
  final double? fontSize;

  const CustomTextStyle(
      {required this.text,
      this.color,
      this.isBold = false,
      this.fontSize,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          color: color,
          fontWeight: isBold ? FontWeight.bold : null,
          fontSize: fontSize),
    );
  }
}

Text getCustomTextStyle(
    {required String text,
    Color? color,
    bool isBold = false,
    double? fontSize}) {
  return Text(
    text,
    style: TextStyle(
        color: color,
        fontWeight: isBold ? FontWeight.bold : null,
        fontSize: fontSize),
  );
}
