import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/forms/designation_add_form.dart';
import 'package:vacci_track_frontend/components/toggle_button_items.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';

class AddDesignation extends StatefulWidget {
  const AddDesignation({super.key});

  @override
  State<AddDesignation> createState() => _AddDesignationState();
}

class _AddDesignationState extends State<AddDesignation> {
  final List<bool> _selectedToggle = <bool>[true, false];
  String heading = "Create a New Designation";

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return ListView(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          color: Theme.of(context).colorScheme.background,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: deviceHeight * .1, bottom: deviceHeight * .04),
                child: Text(
                  heading,
                  style: TextStyle(
                    fontSize: deviceHeight * .03,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ToggleButtons(
                isSelected: _selectedToggle,
                onPressed: (int index) {
                  setState(() {
                    // The button that is tapped is set to true, and the others to false.
                    for (int i = 0; i < _selectedToggle.length; i++) {
                      _selectedToggle[i] = i == index;
                    }
                  });
                },
                children: const [
                  ToggleButtonItems(
                      icon: FaIcon(FontAwesomeIcons.userTag),
                      text: "Add A Designation"),
                  ToggleButtonItems(
                      icon: FaIcon(FontAwesomeIcons.userTag),
                      text: "Edit Old Designation"),
                ],
              ),
              SizedBox(
                height: deviceHeight * 0.02,
              ),
              _selectedToggle[0]
                  ? DesignationAddForm(editPage: false)
                  : DesignationAddForm(editPage: true)
            ],
          ),
        ),
      ],
    );
  }
}
