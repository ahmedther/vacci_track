import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const List<NavigationRailDestination> vaccinationNavigationList = [
  NavigationRailDestination(
    icon: FaIcon(
      FontAwesomeIcons.vialCircleCheck,
      color: Color(0xFF01579b),
    ),
    label: Text("Vaccine"),
    padding: EdgeInsets.symmetric(vertical: 10),
  ),
  NavigationRailDestination(
    icon: FaIcon(
      FontAwesomeIcons.syringe,
      color: Color(0xFF01579b),
    ),
    label: Text("Dose"),
    padding: EdgeInsets.symmetric(vertical: 10),
  ),
];
