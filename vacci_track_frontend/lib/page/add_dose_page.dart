import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/ui/form_ui.dart';
import 'package:vacci_track_frontend/forms/dose_add_form.dart';

class AddDosePage extends StatefulWidget {
  final Color backgroundColor;
  final Color uiColor;

  const AddDosePage(
      {required this.uiColor, required this.backgroundColor, super.key});

  @override
  State<AddDosePage> createState() => _AddDosePageState();
}

class _AddDosePageState extends State<AddDosePage> {
  final List<bool> _selectedToggle = <bool>[true, false];

  @override
  Widget build(BuildContext context) {
    return FormUI(
      uiColor: widget.uiColor,
      backgroundColor: widget.backgroundColor,
      selectedToggle: _selectedToggle,
      toggleFunction: (int index) {
        setState(() {
          // The button that is tapped is set to true, and the others to false.
          for (int i = 0; i < _selectedToggle.length; i++) {
            _selectedToggle[i] = i == index;
          }
        });
      },
      heading: "Assign a Dose to a Vaccine",
      toggelIcon1: const FaIcon(FontAwesomeIcons.syringe),
      toggelIcon2: const FaIcon(FontAwesomeIcons.syringe),
      toggelText1: "Add New Dose",
      toggelText2: "Edit Dose",
      toggelWidget1: DoseAddForm(editPage: false, uiColor: widget.uiColor),
      toggelWidget2: DoseAddForm(editPage: true, uiColor: widget.uiColor),
    );
  }
}
