import 'package:flutter/material.dart';

class ToggleButtonItems extends StatelessWidget {
  final String text;
  final Widget icon;
  const ToggleButtonItems({required this.text, required this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(text),
          SizedBox(width: 10),
          icon,
        ],
      ),
    );
  }
}
