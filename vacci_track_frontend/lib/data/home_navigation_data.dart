import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

List<NavigationDestination> getHomNavigationDestination(final Color iconColor) {
  return <NavigationDestination>[
    NavigationDestination(
      icon: FaIcon(FontAwesomeIcons.houseMedical, color: iconColor),
      label: 'Pending Doses',
      tooltip: "Click To View Doses That Are Due",
    ),
    NavigationDestination(
      icon: FaIcon(FontAwesomeIcons.clipboardCheck, color: iconColor),
      label: 'Doses Administered',
      tooltip: "See the doses that have been administered recently.",
    ),
    NavigationDestination(
      icon: Icon(Icons.bookmark_border),
      label: 'Item 3',
    ),
    NavigationDestination(
      icon: Icon(Icons.alarm),
      label: 'Item 4',
    ),
  ];
}
