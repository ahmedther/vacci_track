import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

List<Widget> toggleButtonItems = [
  const Padding(
    padding: EdgeInsets.all(8.0),
    child: Row(
      children: [
        Text("Designation"),
        SizedBox(width: 10),
        FaIcon(FontAwesomeIcons.userTag, size: 40)
      ],
    ),
  ),
  const Padding(
    padding: EdgeInsets.all(8.0),
    child: Row(
      children: [
        Text("Department"),
        SizedBox(width: 10),
        FaIcon(FontAwesomeIcons.buildingUser, size: 40)
      ],
    ),
  ),
  const Padding(
    padding: EdgeInsets.all(8.0),
    child: Row(
      children: [
        Text("Facility"),
        SizedBox(width: 10),
        FaIcon(FontAwesomeIcons.buildingCircleArrowRight, size: 40)
      ],
    ),
  ),
];
