import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vacci_track_frontend/page/nav_wrapper.dart';
import 'package:vacci_track_frontend/provider/nav_state_provider.dart';
import 'package:vacci_track_frontend/ui/form_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/forms/department_add_form.dart';

class AddDepartment extends ConsumerStatefulWidget {
  static const String routeName = '/add_department';

  const AddDepartment({super.key});

  @override
  ConsumerState<AddDepartment> createState() => _AddDepartmentState();
}

class _AddDepartmentState extends ConsumerState<AddDepartment> {
  final List<bool> _selectedToggle = <bool>[true, false];
  late final Color backgroundColor = ref.watch(navProvider).backgroundColor!;
  late final Color uiColor = ref.watch(navProvider).uiColor!;

  @override
  Widget build(BuildContext context) {
    return NavWrapper(
      child: FormUI(
        backgroundColor: backgroundColor,
        uiColor: uiColor,
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
        toggelWidget2: DepartmentAddForm(editPage: true, uiColor: uiColor),
        toggelWidget1: DepartmentAddForm(editPage: false, uiColor: uiColor),
      ),
    );
  }
}
