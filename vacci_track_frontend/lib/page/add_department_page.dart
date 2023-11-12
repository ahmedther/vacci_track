import 'package:flutter/material.dart';
import 'package:vacci_track_frontend/ui/form_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/forms/department_add_form.dart';

class AddDepartment extends StatefulWidget {
  final Color backgroundColor;
  const AddDepartment({required this.backgroundColor, super.key});

  @override
  State<AddDepartment> createState() => _AddDepartmentState();
}

class _AddDepartmentState extends State<AddDepartment> {
  final List<bool> _selectedToggle = <bool>[true, false];

  @override
  Widget build(BuildContext context) {
    return FormUI(
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
      heading: "Create a New Department",
      toggelIcon1: const FaIcon(FontAwesomeIcons.buildingUser),
      toggelIcon2: const FaIcon(FontAwesomeIcons.buildingUser),
      toggelText1: "Add A Department",
      toggelText2: "Edit A Department",
      toggelWidget1: DepartmentAddForm(editPage: false),
      toggelWidget2: DepartmentAddForm(editPage: true),
    );
  }
}
