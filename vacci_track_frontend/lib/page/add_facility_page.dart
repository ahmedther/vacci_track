import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vacci_track_frontend/page/nav_wrapper.dart';
import 'package:vacci_track_frontend/provider/nav_state_provider.dart';
import 'package:vacci_track_frontend/ui/form_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/forms/facility_add_form.dart';

class AddFacilityPage extends ConsumerStatefulWidget {
  static const String routeName = '/5';

  const AddFacilityPage({super.key});

  @override
  ConsumerState<AddFacilityPage> createState() => _AddFacilityPageState();
}

class _AddFacilityPageState extends ConsumerState<AddFacilityPage> {
  final List<bool> _selectedToggle = <bool>[true, false];
  late final Color backgroundColor = ref.watch(navProvider).backgroundColor!;
  late final Color uiColor = ref.watch(navProvider).uiColor!;

  @override
  Widget build(BuildContext context) {
    return NavWrapper(
      child: FormUI(
        uiColor: uiColor,
        backgroundColor: backgroundColor,
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
        toggelWidget1: FacilityAddForm(editPage: false, uiColor: uiColor),
        toggelWidget2: FacilityAddForm(editPage: true, uiColor: uiColor),
      ),
    );
  }
}
