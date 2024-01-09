import 'package:flutter/material.dart';
import 'package:vacci_track_frontend/components/text_style.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/ui/error_snackbar.dart';

class HelpersWidget {
  static void showSnackBar(BuildContext context, String? errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ErrorSnackBar(
          errorMessage: errorMessage,
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 10,
      ),
    );
  }

  static Future showDialogOnScreen(
      {final Color? uiColor,
      final Color? backgroundColor,
      final double? titleFontSize = 24,
      final Widget? content,
      final String? contentMessage,
      required final BuildContext context,
      required final String title,
      required final String btnMessage,
      final Function? onPressed,
      List<Widget>? actions}) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          scrollable: true,
          title: CustomTextStyle(
              text: title,
              color: uiColor,
              fontSize: titleFontSize,
              isBold: true,
              textAlign: TextAlign.center),
          content: content ??
              CustomTextStyle(
                  text: contentMessage ?? "",
                  color: Colors.black,
                  fontSize: 16,
                  isBold: true,
                  textAlign: TextAlign.center),
          actions: actions ??
              [
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: CustomTextStyle(
                      text: btnMessage,
                      color: uiColor,
                      fontSize: 14,
                      isBold: true,
                      textAlign: TextAlign.right),
                  onPressed: () {
                    if (onPressed != null) {
                      onPressed();
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
        );
      },
    );
  }

  static Widget buildVerticalDivider(
      {required double deviceWidth,
      required double deviceHeight,
      required Color uiColor}) {
    return SizedBox(
      height: Helpers.minAndMax(deviceHeight * .05, 0, 50),
      width: Helpers.minAndMax(deviceWidth * .1, 0, 50),
      child: VerticalDivider(
        color: uiColor,
        thickness: 1,
      ),
    );
  }

  static List<Widget> buildColumnBox({
    required List<String> text,
    required double width,
    required double deviceHeight,
    required double deviceWidth,
    required Color uiColor,
    bool useTextwithUiColor = false,
  }) {
    return text
        .asMap()
        .entries
        .map((entry) {
          int idx = entry.key;
          String e = entry.value;
          return [
            SizedBox(
              width: width,
              child: CustomTextStyle(
                text: e,
                fontSize: 14,
                isBold: true,
                color: useTextwithUiColor ? uiColor : Colors.black,
                textAlign: TextAlign.center,
              ),
            ),
            if (idx != text.length - 1)
              buildVerticalDivider(
                deviceHeight: deviceHeight,
                deviceWidth: deviceWidth,
                uiColor: uiColor,
              ),
          ];
        })
        .expand((x) => x)
        .toList();
  }

  static Future<DateTime?> openDatePicker(
      {required BuildContext context, String? helpText}) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2008),
      lastDate: DateTime.now(),
      helpText: helpText,
    );
    if (selectedDate != null) return selectedDate;
    return null;
  }
}
