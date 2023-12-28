import 'package:flutter/material.dart';
import 'package:vacci_track_frontend/components/toggle_button_items.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';

// ignore: must_be_immutable

class FormUI extends StatelessWidget {
  const FormUI(
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
      required this.backgroundColor,
      required this.uiColor,
      super.key});

  final List<Widget>? widgetsToDisplay;
  final List<bool> selectedToggle;
  final Function(int) toggleFunction;
  final String heading;
  final Widget toggelIcon1;
  final Widget toggelIcon2;
  final String toggelText1;
  final String toggelText2;
  final Widget toggelWidget1;
  final Widget toggelWidget2;
  final Color backgroundColor;
  final Color uiColor;

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    late final Color themeColor =
        Helpers.getThemeColorWithUIColor(context: context, uiColor: uiColor);

    return ListView(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: deviceHeight),
          child: Container(
            color: backgroundColor,
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
                  borderRadius: BorderRadius.circular(5),
                  borderWidth: 2,
                  borderColor: const Color.fromARGB(24, 0, 0, 0),
                  selectedBorderColor: uiColor,
                  selectedColor: uiColor,
                  fillColor: themeColor,
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
        ),
      ],
    );
  }
}
