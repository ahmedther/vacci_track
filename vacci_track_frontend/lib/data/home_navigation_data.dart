import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

List<NavigationDestination> getHomNavigationDestination(Color iconColor) {
  return <NavigationDestination>[
    NavigationDestination(
      icon: FaIcon(FontAwesomeIcons.houseMedical, color: iconColor),
      label: 'Pending Doses',
      tooltip: "Click To View Doses That Are Due",
    ),
    NavigationDestination(
      icon: Icon(Icons.star_border),
      label: 'Item 2',
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
