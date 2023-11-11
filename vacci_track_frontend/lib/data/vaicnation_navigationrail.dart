import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';

List<NavigationRailDestination> getvaccinationNavigationList(String gender) {
  final Color iconColor = Helpers.getThemeColor(gender);

  final List<NavigationRailDestination> vaccinationNavigationList = [
    NavigationRailDestination(
      icon: FaIcon(
        FontAwesomeIcons.vialCircleCheck,
        color: iconColor,
      ),
      label: const Text("Vaccine"),
      padding: const EdgeInsets.symmetric(vertical: 10),
    ),
    NavigationRailDestination(
      icon: FaIcon(
        FontAwesomeIcons.syringe,
        color: iconColor,
      ),
      label: const Text("Dose"),
      padding: const EdgeInsets.symmetric(vertical: 10),
    ),
  ];
  return vaccinationNavigationList;
}
