import 'package:flutter/material.dart';

class CustomBadge extends StatelessWidget {
  String text;
  TextStyle? style;
  List<Color> gradientColors;
  CustomBadge(
      {required this.text,
      this.gradientColors = const [
        Color.fromARGB(255, 57, 57, 57),
        Color.fromARGB(255, 0, 0, 0),
      ],
      this.style = const TextStyle(color: Colors.white),
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: style,
      ),
    );
  }
}
