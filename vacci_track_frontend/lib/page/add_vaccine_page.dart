import 'package:flutter/material.dart';
import 'package:vacci_track_frontend/ui/form_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/forms/vaccine_add_form.dart';

class AddVaccinePage extends StatefulWidget {
  const AddVaccinePage({super.key});

  @override
  State<AddVaccinePage> createState() => _AddVaccinePageState();
}

class _AddVaccinePageState extends State<AddVaccinePage> {
  final List<bool> _selectedToggle = <bool>[true, false];

  @override
  Widget build(BuildContext context) {
    return FormUI(
      heading: "Add A New Vaccine",
      selectedToggle: _selectedToggle,
      toggleFunction: (int index) {
        setState(() {
          // The button that is tapped is set to true, and the others to false.
          for (int i = 0; i < _selectedToggle.length; i++) {
            _selectedToggle[i] = i == index;
          }
        });
      },
      toggelIcon1: const FaIcon(FontAwesomeIcons.vialCircleCheck),
      toggelIcon2: const FaIcon(FontAwesomeIcons.vialCircleCheck),
      toggelText1: "Add New Vaccine",
      toggelText2: "Edit Vaccine",
      toggelWidget1: VaccineAddForm(editPage: false),
      toggelWidget2: VaccineAddForm(editPage: true),
    );
  }
}
