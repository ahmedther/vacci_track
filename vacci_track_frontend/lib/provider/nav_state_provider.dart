import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vacci_track_frontend/model/nav_state.dart';

class NavStateNotifier extends StateNotifier<NavState> {
  NavStateNotifier() : super(NavState());

  void setNavState(NavState newData) {
    state = newData;
  }

  void updateColors({Color? backgroundColor, Color? uiColor}) {
    state.backgroundColor = backgroundColor;
    state.uiColor = uiColor;
  }

  void updatIndex({int? selectedIndex, int? otherIndex, int? vaccineIndex}) {
    state.selectedIndex = selectedIndex;
    state.otherIndex = otherIndex;
    state.vaccineIndex = vaccineIndex;
  }
}

final navProvider = StateNotifierProvider<NavStateNotifier, NavState>(
    (ref) => NavStateNotifier());
