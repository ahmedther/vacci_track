// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/components/text_style.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/helpers/helper_widgets.dart';

class EmployeeDetailCards extends StatelessWidget {
  final Color uiColor;
  final Color? backgroundColor;
  final Color themeColor;
  final double containerWidth;
  final double deviceHeight;
  final double deviceWidth;
  final void Function()? onTap;
  final List<List<String>> column1Texts;
  final List<List<String>> column2Texts;
  final List<String> otherColums;
  final String? circleAvatarText;
  final String titleText;

  const EmployeeDetailCards(
      {this.backgroundColor,
      this.onTap,
      this.circleAvatarText,
      required this.titleText,
      required this.column1Texts,
      required this.column2Texts,
      required this.otherColums,
      required this.themeColor,
      required this.uiColor,
      required this.containerWidth,
      required this.deviceWidth,
      required this.deviceHeight,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: themeColor,
      surfaceTintColor: Colors.white,
      child: ListTile(
        hoverColor: const Color.fromARGB(31, 0, 0, 0),
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Helpers.getRandomColor(),
          child: circleAvatarText != null
              ? CustomTextStyle(
                  text: circleAvatarText!,
                  color: Colors.white,
                  fontSize: 24,
                  isBold: true,
                )
              : const FaIcon(FontAwesomeIcons.userAlt, color: Colors.white),
        ),
        title: CustomTextStyle(
          text: titleText,
          color: uiColor,
          isBold: true,
        ),
        subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (containerWidth > 801) ...{
              SizedBox(
                width: containerWidth > 1234 ? containerWidth * 0.5 : null,
                child: Row(
                  children: [
                    buildCustomTextColumn(
                        columnTexts: column1Texts, width: deviceWidth * .2),
                    HelpersWidget.buildVerticalDivider(
                        deviceHeight: deviceHeight,
                        deviceWidth: deviceWidth,
                        uiColor: uiColor),
                    if (containerWidth > 1234) ...{
                      buildCustomTextColumn(
                          columnTexts: column2Texts,
                          width: deviceWidth * .2,
                          labelWidth: 97),
                      HelpersWidget.buildVerticalDivider(
                          deviceHeight: deviceHeight,
                          deviceWidth: deviceWidth,
                          uiColor: uiColor),
                    }
                  ],
                ),
              )
            } else if (containerWidth > 592) ...{
              buildCustomTextColumn(
                  columnTexts: column1Texts.map((list) => [list.last]).toList(),
                  width: deviceWidth * .2),
              HelpersWidget.buildVerticalDivider(
                  deviceHeight: deviceHeight,
                  deviceWidth: deviceWidth,
                  uiColor: uiColor),
            },
            ...HelpersWidget.buildColumnBox(
                text: otherColums,
                width: containerWidth * .1,
                deviceHeight: deviceHeight,
                deviceWidth: deviceWidth,
                uiColor: uiColor),
          ],
        ),
      ),
    );
  }

  Widget buildCustomTextColumn(
      {required List<List<String>> columnTexts,
      required double width,
      double labelWidth = 80,
      double fontSize = 14}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columnTexts
          .map((items) => Row(
                children: items
                    .asMap() // Convert to iterable map
                    .entries
                    .map(
                      (entry) => SizedBox(
                        width: entry.key == 0
                            ? Helpers.minAndMax(width, 0, labelWidth)
                            : entry.key == 1
                                ? Helpers.minAndMax(width, 0, 50)
                                : Helpers.minAndMax(
                                    width, 0, 120), // Check if iteration is 2
                        child: CustomTextStyle(
                            text: entry.value,
                            fontSize: entry.value.length > 16 ? 10 : fontSize,
                            isBold: true,
                            color: Colors.black,
                            textAlign:
                                entry.key == 1 ? TextAlign.center : null),
                      ),
                    )
                    .toList(),
              ))
          .toList(),
    );
  }
}
