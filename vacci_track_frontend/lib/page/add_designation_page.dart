import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/forms/designation_add_form.dart';
import 'package:vacci_track_frontend/ui/form_ui.dart';

class AddDesignation extends StatefulWidget {
  const AddDesignation({super.key});

  @override
  State<AddDesignation> createState() => _AddDesignationState();
}

class _AddDesignationState extends State<AddDesignation> {
  final List<bool> _selectedToggle = <bool>[true, false];

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      children: [
        FormUI(
          selectedToggle: _selectedToggle,
          toggleFunction: (int index) {
            setState(() {
              // The button that is tapped is set to true, and the others to false.
              for (int i = 0; i < _selectedToggle.length; i++) {
                _selectedToggle[i] = i == index;
              }
            });
          },
          heading: "Create a New Designation",
          toggelIcon1: const FaIcon(FontAwesomeIcons.userTag),
          toggelIcon2: const FaIcon(FontAwesomeIcons.userTag),
          toggelText1: "Add A Designation",
          toggelText2: "Edit Old Designation",
          toggelWidget1: DesignationAddForm(editPage: false),
          toggelWidget2: DesignationAddForm(editPage: true),
        ),
      ],
    );
  }
}
