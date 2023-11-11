import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';

List<NavigationRailDestination> getotherSubNavigationList(String gender) {
  final Color iconColor = Helpers.getThemeColor(gender);

  final List<NavigationRailDestination> otherSubNavigationList = [
    NavigationRailDestination(
      icon: FaIcon(
        FontAwesomeIcons.userTag,
        color: iconColor,
      ),
      label: const Text("Designation"),
      padding: const EdgeInsets.symmetric(vertical: 10),
    ),
    NavigationRailDestination(
      icon: FaIcon(
        FontAwesomeIcons.buildingUser,
        color: iconColor,
      ),
      label: const Text("Department", maxLines: 3),
      padding: const EdgeInsets.symmetric(vertical: 10),
    ),
    NavigationRailDestination(
      icon: FaIcon(
        FontAwesomeIcons.buildingCircleArrowRight,
        color: iconColor,
      ),
      label: const Text("Facility", maxLines: 3),
      padding: const EdgeInsets.symmetric(vertical: 10),
    ),
  ];

  return otherSubNavigationList;
}
