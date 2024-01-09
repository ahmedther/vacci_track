import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

List<NavigationRailDestination> getNavigationRailDestinations(Color iconColor) {
  return <NavigationRailDestination>[
    NavigationRailDestination(
      icon: FaIcon(
        FontAwesomeIcons.houseMedical,
        color: iconColor,
      ),
      label: const Text("Home"),
    ),
    NavigationRailDestination(
      icon: FaIcon(
        FontAwesomeIcons.bookMedical,
        color: iconColor,
      ),
      label: const Text("Record \nVaccine Dose",
          maxLines: 3, textAlign: TextAlign.center),
    ),
    NavigationRailDestination(
      icon: FaIcon(
        FontAwesomeIcons.userGear,
        color: iconColor,
      ),
      label: const Text("Add/Edit\nEmployee",
          maxLines: 3, textAlign: TextAlign.center),
    ),
    // NavigationRailDestination(
    //   icon: FaIcon(
    //     FontAwesomeIcons.circlePlus,
    //     color: Color(0xFF01579b),
    //   ),
    //   label: Text("Add Others", maxLines: 3),
    // ),
  ];
}
