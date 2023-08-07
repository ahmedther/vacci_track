import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const List<NavigationRailDestination> otherSubNavigationList = [
  NavigationRailDestination(
    icon: FaIcon(
      FontAwesomeIcons.userTag,
      color: Color(0xFF01579b),
    ),
    label: Text("Designation"),
    padding: EdgeInsets.symmetric(vertical: 10),
  ),
  NavigationRailDestination(
    icon: FaIcon(
      FontAwesomeIcons.buildingUser,
      color: Color(0xFF01579b),
    ),
    label: Text("Department", maxLines: 3),
    padding: EdgeInsets.symmetric(vertical: 10),
  ),
  NavigationRailDestination(
    icon: FaIcon(
      FontAwesomeIcons.buildingCircleArrowRight,
      color: Color(0xFF01579b),
    ),
    label: Text("Facility", maxLines: 3),
    padding: EdgeInsets.symmetric(vertical: 10),
  ),
];
