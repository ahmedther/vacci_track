import 'package:flutter/material.dart';
import 'package:vacci_track_frontend/components/toggle_button_items.dart';

// ignore: must_be_immutable
class FormUI extends StatelessWidget {
  FormUI(
      {this.widgetsToDisplay,
      required this.selectedToggle,
      required this.toggleFunction,
      required this.heading,
      required this.toggelIcon1,
      required this.toggelIcon2,
      required this.toggelText1,
      required this.toggelText2,
      required this.toggelWidget1,
      required this.toggelWidget2,
      super.key});

  List<Widget>? widgetsToDisplay;
  final List<bool> selectedToggle;
  final Function(int) toggleFunction;
  final String heading;
  final Widget toggelIcon1;
  final Widget toggelIcon2;
  final String toggelText1;
  final String toggelText2;
  final Widget toggelWidget1;
  final Widget toggelWidget2;

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
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
              ...?widgetsToDisplay,
              ToggleButtons(
                isSelected: selectedToggle,
                onPressed: toggleFunction,
                children: [
                  ToggleButtonItems(icon: toggelIcon1, text: toggelText1),
                  ToggleButtonItems(icon: toggelIcon2, text: toggelText2),
                ],
              ),
              SizedBox(
                height: deviceHeight * 0.02,
              ),
              selectedToggle[0] ? toggelWidget1 : toggelWidget2
            ],
          ),
        ),
      ],
    );
  }
}
