import 'package:flutter/material.dart';

class NavState {
  int? selectedIndex;
  int? otherIndex;
  int? vaccineIndex;
  Color? backgroundColor;
  Color? uiColor;

  NavState({
    this.selectedIndex,
    this.backgroundColor = Colors.white,
    this.uiColor = Colors.blue,
  });

  @override
  String toString() {
    return 'NavState(selectedIndex: $selectedIndex)';
  }
}
