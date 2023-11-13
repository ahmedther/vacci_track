import 'package:flutter/material.dart';
import 'package:vacci_track_frontend/page/add_new_employee_page.dart';
import 'package:vacci_track_frontend/page/add_designation_page.dart';
import 'package:vacci_track_frontend/page/add_department_page.dart';
import 'package:vacci_track_frontend/page/add_facility_page.dart';
import 'package:vacci_track_frontend/page/add_vaccine_page.dart';
import 'package:vacci_track_frontend/page/add_dose_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

List<Widget> getNaviPages(Color backgroundColor, Color uiColor) {
  late List<Widget> pages = [
    const Text("Home"),
    AddNewEmployee(
      heading: "Record a Vaccine Dose",
      employeeAddFrom: false,
      toggleIcon1: const FaIcon(FontAwesomeIcons.bookMedical),
      toggleIcon2: const FaIcon(FontAwesomeIcons.bookMedical),
      toggelText1: "Record a Dose",
      toggelText2: "Edit A Dose",
      backgroundColor: backgroundColor,
      uiColor: uiColor,
    ),
    AddNewEmployee(
      heading: "Add/Edit Employee",
      toggleIcon1: const FaIcon(FontAwesomeIcons.userPlus),
      toggleIcon2: const FaIcon(FontAwesomeIcons.userEdit),
      toggelText1: "Add A New",
      toggelText2: "Edit Old",
      employeeAddFrom: true,
      backgroundColor: backgroundColor,
      uiColor: uiColor,
    ),
    AddDesignation(backgroundColor: backgroundColor, uiColor: uiColor),
    AddDepartment(backgroundColor: backgroundColor, uiColor: uiColor),
    AddFacilityPage(backgroundColor: backgroundColor, uiColor: uiColor),
    AddVaccinePage(backgroundColor: backgroundColor, uiColor: uiColor),
    AddDosePage(backgroundColor: backgroundColor, uiColor: uiColor),
  ];
  return pages;
}
