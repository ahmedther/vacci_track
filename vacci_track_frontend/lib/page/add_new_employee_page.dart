import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:vacci_track_frontend/forms/employee_add_form.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/page/nav_wrapper.dart';
import 'package:vacci_track_frontend/provider/nav_state_provider.dart';
import 'package:vacci_track_frontend/ui/form_ui.dart';
import 'package:vacci_track_frontend/forms/record_vaccine_form.dart';

class AddNewEmployee extends ConsumerStatefulWidget {
  static const String routeName = '/1';
  static const String routeName2 = '/2';
  const AddNewEmployee({super.key});

  @override
  ConsumerState<AddNewEmployee> createState() => _AddNewEmployeeState();
}

class _AddNewEmployeeState extends ConsumerState<AddNewEmployee> {
  late final bool employeeAddFrom =
      GoRouter.of(context).routeInformationProvider.value.uri.toString() ==
          "/2";

  late final Color backgroundColor = ref.watch(navProvider).backgroundColor!;
  late final Color uiColor = ref.watch(navProvider).uiColor!;

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
    final genderWiseColor = Helpers.getUIandBackgroundColor(gender)[0];

    final themeColor =
        Helpers.getThemeColorWithUIColor(context: context, uiColor: uiColor);
    return NavWrapper(
      child: FormUI(
        uiColor: employeeAddFrom
            ? uiColor
            : gender.isNotEmpty
                ? genderWiseColor
                : uiColor,
        backgroundColor: backgroundColor,
        selectedToggle: _selectedToggle,
        toggleFunction: (int index) {
          setState(() {
            // The button that is tapped is set to true, and the others to false.
            for (int i = 0; i < _selectedToggle.length; i++) {
              _selectedToggle[i] = i == index;
            }
          });
        },
        heading:
            employeeAddFrom ? "Add/Edit Employee" : "Record a Vaccine Dose",
        toggelIcon1: employeeAddFrom
            ? const FaIcon(FontAwesomeIcons.userPlus)
            : const FaIcon(FontAwesomeIcons.bookMedical),
        toggelIcon2: employeeAddFrom
            ? const FaIcon(FontAwesomeIcons.userEdit)
            : const FaIcon(FontAwesomeIcons.bookMedical),
        toggelText1: employeeAddFrom ? "Add A New" : "Record a Dose",
        toggelText2: employeeAddFrom ? "Edit Old" : "❌ Edit A Dose",
        toggelWidget1: employeeAddFrom
            ? EmployeeAddForm(
                assignAvatar: assignAvatar,
                editPage: false,
                uiColor: uiColor,
              )
            : RecordVaccineForm(
                assignAvatar: assignAvatar,
                editPage: false,
                resetAvatar: resetAvatar,
                uiColor: uiColor,
              ),
        toggelWidget2: employeeAddFrom
            ? EmployeeAddForm(
                assignAvatar: assignAvatar,
                editPage: true,
                uiColor: uiColor,
              )
            : RecordVaccineForm(
                assignAvatar: assignAvatar,
                editPage: true,
                resetAvatar: resetAvatar,
                uiColor: uiColor,
              ),
        widgetsToDisplay: [
          CircleAvatar(
            backgroundColor: gender == "" ? uiColor : genderWiseColor,
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
      ),
    );
  }
}
