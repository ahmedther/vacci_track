import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vacci_track_frontend/page/nav_wrapper.dart';
import 'package:vacci_track_frontend/provider/nav_state_provider.dart';
import 'package:vacci_track_frontend/ui/form_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/forms/vaccine_add_form.dart';

class AddVaccinePage extends ConsumerStatefulWidget {
  static const String routeName = '/add_vaccine';

  const AddVaccinePage({super.key});

  @override
  ConsumerState<AddVaccinePage> createState() => _AddVaccinePageState();
}

class _AddVaccinePageState extends ConsumerState<AddVaccinePage> {
  final List<bool> _selectedToggle = <bool>[true, false];
  late final Color backgroundColor = ref.watch(navProvider).backgroundColor!;
  late final Color uiColor = ref.watch(navProvider).uiColor!;
  @override
  Widget build(BuildContext context) {
    return NavWrapper(
      child: FormUI(
        uiColor: uiColor,
        backgroundColor: backgroundColor,
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
        toggelWidget1: VaccineAddForm(editPage: false, uiColor: uiColor),
        toggelWidget2: VaccineAddForm(editPage: true, uiColor: uiColor),
      ),
    );
  }
}
