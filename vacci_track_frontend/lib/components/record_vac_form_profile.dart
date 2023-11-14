import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/ui/badge.dart';

class RecordVaccineEmployeeProfile extends StatelessWidget {
  const RecordVaccineEmployeeProfile(
      {this.department,
      this.designation,
      required this.profileColor,
      required this.gender,
      required this.prNumber,
      required this.uhid,
      super.key});

  final Color profileColor;
  final String gender;
  final String? department;
  final String? designation;
  final String prNumber;
  final String uhid;

  @override
  Widget build(BuildContext context) {
    late final Color gradientColor = Helpers.getGraditentWithGender(gender);

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FaIcon(FontAwesomeIcons.mars, color: profileColor),
              const SizedBox(height: 20),
              FaIcon(FontAwesomeIcons.buildingUser, color: profileColor),
            ],
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Gender",
                  style: TextStyle(
                      color: profileColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text(
                "Desgination",
                style:
                    TextStyle(color: profileColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(
            width: 20,
          ),
          Column(
            children: [
              Text(":",
                  style: TextStyle(
                      color: profileColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text(":",
                  style: TextStyle(
                      color: profileColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomBadge(
                  text: gender, // gender
                  gradientColors: [gradientColor, profileColor]),
              const SizedBox(height: 20),
              CustomBadge(
                  text: designation != null && department != null
                      ? "$designation in $department"
                      : "Not Available", // Designation in Department
                  gradientColors: [gradientColor, profileColor]),
            ],
          ),
          const SizedBox(width: 100),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FaIcon(FontAwesomeIcons.idCardClip, color: profileColor),
              const SizedBox(height: 20),
              FaIcon(FontAwesomeIcons.solidIdBadge, color: profileColor),
            ],
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("PR Number",
                  style: TextStyle(
                      color: profileColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text("UHID",
                  style: TextStyle(
                      color: profileColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 20),
          Column(
            children: [
              Text(":",
                  style: TextStyle(
                      color: profileColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text(":",
                  style: TextStyle(
                      color: profileColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomBadge(
                  text: prNumber, // PR Number
                  gradientColors: [gradientColor, profileColor]),
              const SizedBox(height: 20),
              CustomBadge(
                  text: uhid, gradientColors: [gradientColor, profileColor]),
            ],
          ),
        ],
      ),
    );
  }
}
