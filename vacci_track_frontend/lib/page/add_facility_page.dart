import 'package:flutter/material.dart';
import 'package:vacci_track_frontend/ui/form_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/forms/facility_add_form.dart';

class AddFacilityPage extends StatefulWidget {
  final Color backgroundColor;
  final Color uiColor;

  const AddFacilityPage(
      {required this.uiColor, required this.backgroundColor, super.key});

  @override
  State<AddFacilityPage> createState() => _AddFacilityPageState();
}

class _AddFacilityPageState extends State<AddFacilityPage> {
  final List<bool> _selectedToggle = <bool>[true, false];

  @override
  Widget build(BuildContext context) {
    return FormUI(
      uiColor: widget.uiColor,
      backgroundColor: widget.backgroundColor,
      heading: "Add Facility",
      selectedToggle: _selectedToggle,
      toggleFunction: (int index) {
        setState(() {
          // The button that is tapped is set to true, and the others to false.
          for (int i = 0; i < _selectedToggle.length; i++) {
            _selectedToggle[i] = i == index;
          }
        });
      },
      toggelIcon1: const FaIcon(FontAwesomeIcons.buildingCircleArrowRight),
      toggelIcon2: const FaIcon(FontAwesomeIcons.buildingCircleArrowRight),
      toggelText1: "Add a Facility",
      toggelText2: "Edit Facility",
      toggelWidget1: FacilityAddForm(editPage: false),
      toggelWidget2: FacilityAddForm(editPage: true),
    );
  }
}
