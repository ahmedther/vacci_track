import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const List<NavigationRailDestination> nagivationList = [
  NavigationRailDestination(
    icon: FaIcon(
      FontAwesomeIcons.houseMedical,
      color: Color(0xFF01579b),
    ),
    label: Text("Home"),
  ),
  NavigationRailDestination(
    icon: FaIcon(
      FontAwesomeIcons.bookMedical,
      color: Color(0xFF01579b),
    ),
    label:
        Text("Record \nVaccine Dose", maxLines: 3, textAlign: TextAlign.center),
  ),
  NavigationRailDestination(
    icon: FaIcon(
      FontAwesomeIcons.userGear,
      color: Color(0xFF01579b),
    ),
    label: Text("Add/Edit\nEmployee", maxLines: 3, textAlign: TextAlign.center),
  ),
  // NavigationRailDestination(
  //   icon: FaIcon(
  //     FontAwesomeIcons.circlePlus,
  //     color: Color(0xFF01579b),
  //   ),
  //   label: Text("Add Others", maxLines: 3),
  // ),
];
