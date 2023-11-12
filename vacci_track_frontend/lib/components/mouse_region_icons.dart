import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CustomMouseRegionOnNavigationRail extends StatelessWidget {
  const CustomMouseRegionOnNavigationRail(
      {required this.isHovered,
      required this.icon,
      required this.label,
      this.onEnter,
      super.key});

  final void Function(PointerEnterEvent)? onEnter;
  final bool isHovered;
  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      hitTestBehavior: HitTestBehavior.translucent,
      onEnter: onEnter,
      child: Column(
        children: [
          Container(
            height: 33,
            width: 50,
            decoration: BoxDecoration(
                color: isHovered ? const Color.fromARGB(13, 0, 0, 0) : null,
                borderRadius: BorderRadius.circular(20)),
            child: Center(
              child: icon,
            ),
          ),
          const SizedBox(height: 5),
          Text(label,
              maxLines: 3,
              style: const TextStyle(
                fontSize: 12,
              )),
        ],
      ),
    );
  }
}
