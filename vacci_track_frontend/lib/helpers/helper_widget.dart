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

  static Future showDialogOnScreen({
    required BuildContext context,
    required String title,
    required String message,
    required String btnMessage,
    required Function onPressed,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(btnMessage),
              onPressed: () {
                onPressed();
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
}
