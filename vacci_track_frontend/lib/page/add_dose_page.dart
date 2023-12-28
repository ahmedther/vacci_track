import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/page/nav_wrapper.dart';
import 'package:vacci_track_frontend/provider/nav_state_provider.dart';
import 'package:vacci_track_frontend/ui/form_ui.dart';
import 'package:vacci_track_frontend/forms/dose_add_form.dart';

class AddDosePage extends ConsumerStatefulWidget {
  static const String routeName = '/add_dose';
  const AddDosePage({super.key});

  @override
  ConsumerState<AddDosePage> createState() => _AddDosePageState();
}

class _AddDosePageState extends ConsumerState<AddDosePage> {
  final List<bool> _selectedToggle = <bool>[true, false];
  late final Color backgroundColor = ref.watch(navProvider).backgroundColor!;
  late final Color uiColor = ref.watch(navProvider).uiColor!;
  @override
  Widget build(BuildContext context) {
    return NavWrapper(
      child: FormUI(
        uiColor: uiColor,
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
        heading: "Assign a Dose to a Vaccine",
        toggelIcon1: const FaIcon(FontAwesomeIcons.syringe),
        toggelIcon2: const FaIcon(FontAwesomeIcons.syringe),
        toggelText1: "Add New Dose",
        toggelText2: "Edit Dose",
        toggelWidget1: DoseAddForm(editPage: false, uiColor: uiColor),
        toggelWidget2: DoseAddForm(editPage: true, uiColor: uiColor),
      ),
    );
  }
}
