import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/ui/designation_add_form.dart';
import 'package:vacci_track_frontend/data/other_form_data.dart';

class AddOtherPage extends StatefulWidget {
  const AddOtherPage({super.key});

  @override
  State<AddOtherPage> createState() => _AddOtherPageState();
}

class _AddOtherPageState extends State<AddOtherPage> {
  final List<bool> _selectedToggle = <bool>[true, false, false];
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
                padding: EdgeInsets.all(deviceHeight * .02),
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
                children: toggleButtonItems,
              ),
              SizedBox(
                height: deviceHeight * 0.02,
              ),
              _selectedToggle[0]
                  ? const DesignationAddForm()
                  : Text("Secod Display")
            ],
          ),
        ),
      ],
    );
  }
}
