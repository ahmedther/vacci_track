import 'package:flutter/material.dart';
import 'package:vacci_track_frontend/forms/employee_add_form.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/ui/form_ui.dart';
import 'package:vacci_track_frontend/forms/record_vaccine_form.dart';

class AddNewEmployee extends StatefulWidget {
  const AddNewEmployee(
      {required this.heading,
      required this.toggleIcon1,
      required this.toggleIcon2,
      required this.toggelText1,
      required this.toggelText2,
      required this.employeeAddFrom,
      required this.backgroundColor,
      required this.uiColor,
      super.key});

  final String heading;
  final Widget toggleIcon1;
  final Widget toggleIcon2;
  final String toggelText1;
  final String toggelText2;
  final bool employeeAddFrom;
  final Color backgroundColor;
  final Color uiColor;

  @override
  State<AddNewEmployee> createState() => _AddNewEmployeeState();
}

class _AddNewEmployeeState extends State<AddNewEmployee> {
  String gender = "";
  String prefix = "";
  String firstName = "";
  String middleName = "";
  String lastName = "";

  final List<bool> _selectedToggle = <bool>[true, false];

  Future assignAvatar({
    String? newgender,
    String? newprefix,
    String? newfirstName,
    String? newmiddleName,
    String? newlastName,
  }) async {
    setState(() {
      if (newgender != null) gender = newgender;
      if (newprefix != null) {
        prefix = newprefix;
        if (prefix == "Mrs." || prefix == "Ms" || prefix == "Ms.") {
          gender = "female";
        }

        if (prefix == "Mr." || prefix == "Mr") gender = "male";
      }
      if (newfirstName != null) firstName = newfirstName;
      if (newmiddleName != null) middleName = newmiddleName;
      if (newlastName != null) lastName = newlastName;
    });
  }

  void resetAvatar() {
    setState(() {
      gender = "";
      prefix = "";
      firstName = "";
      middleName = "";
      lastName = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    final themeColor = Helpers.getThemeColorWithUIColor(
        context: context, uiColor: widget.uiColor);
    final genderWiseColor = Helpers.getUIandBackgroundColor(gender)[0];

    return FormUI(
      uiColor: gender == "" && widget.employeeAddFrom == false
          ? widget.uiColor
          : genderWiseColor,
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
      heading: widget.heading,
      toggelIcon1: widget.toggleIcon1,
      toggelIcon2: widget.toggleIcon2,
      toggelText1: widget.toggelText1,
      toggelText2: widget.toggelText2,
      toggelWidget1: widget.employeeAddFrom
          ? EmployeeAddForm(
              assignAvatar: assignAvatar,
              editPage: false,
              uiColor: widget.uiColor,
            )
          : RecordVaccineForm(
              assignAvatar: assignAvatar,
              editPage: false,
              resetAvatar: resetAvatar,
              uiColor: widget.uiColor,
            ),
      toggelWidget2: widget.employeeAddFrom
          ? EmployeeAddForm(
              assignAvatar: assignAvatar,
              editPage: true,
              uiColor: widget.uiColor,
            )
          : RecordVaccineForm(
              assignAvatar: assignAvatar,
              editPage: true,
              resetAvatar: resetAvatar,
              uiColor: widget.uiColor,
            ),
      widgetsToDisplay: [
        CircleAvatar(
          backgroundColor: gender == "" ? widget.uiColor : genderWiseColor,
          maxRadius: deviceHeight * 0.09,
          child: CircleAvatar(
            backgroundColor: themeColor,
            maxRadius: deviceHeight * 0.08,
            child: Image.asset(
              'assets/img/${gender.isNotEmpty ? gender : "both"}.png',
            ),
          ),
        ),
        SizedBox(
          height: deviceHeight * 0.01,
        ),
        Text(
          "$prefix $firstName $middleName $lastName",
          style: TextStyle(
            fontSize: deviceHeight * 0.02,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            color: genderWiseColor,
          ),
        ),
        SizedBox(
          height: deviceHeight * 0.02,
        ),
      ],
    );
  }
}
