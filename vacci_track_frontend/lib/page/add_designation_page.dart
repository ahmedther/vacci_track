import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/forms/designation_add_form.dart';
import 'package:vacci_track_frontend/page/nav_wrapper.dart';
import 'package:vacci_track_frontend/provider/nav_state_provider.dart';
import 'package:vacci_track_frontend/ui/form_ui.dart';

class AddDesignation extends ConsumerStatefulWidget {
  static const String routeName = '/3';

  const AddDesignation({super.key});

  @override
  ConsumerState<AddDesignation> createState() => _AddDesignationState();
}

class _AddDesignationState extends ConsumerState<AddDesignation> {
  final List<bool> _selectedToggle = <bool>[true, false];
  late final Color backgroundColor = ref.watch(navProvider).backgroundColor!;
  late final Color uiColor = ref.watch(navProvider).uiColor!;
  @override
  Widget build(BuildContext context) {
    return NavWrapper(
      child: ListView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        children: [
          FormUI(
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
            heading: "Create a New Designation",
            toggelIcon1: const FaIcon(FontAwesomeIcons.userTag),
            toggelIcon2: const FaIcon(FontAwesomeIcons.userTag),
            toggelText1: "Add A Designation",
            toggelText2: "Edit Old Designation",
            toggelWidget1:
                DesignationAddForm(editPage: false, uiColor: uiColor),
            toggelWidget2: DesignationAddForm(editPage: true, uiColor: uiColor),
          ),
        ],
      ),
    );
  }
}
