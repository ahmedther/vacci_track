import 'package:flutter/material.dart';
import 'package:vacci_track_frontend/components/text_style.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/helpers/helper_widget.dart';

class HomeCardHeading extends StatelessWidget {
  final Color uiColor;
  final Color themeColor;
  final double containerWidth;
  final double deviceHeight;
  final double deviceWidth;
  final List<String> headings;

  const HomeCardHeading(
      {required this.headings,
      required this.themeColor,
      required this.uiColor,
      required this.containerWidth,
      required this.deviceWidth,
      required this.deviceHeight,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 20),
      width: containerWidth,
      child: Card(
        color: themeColor,
        surfaceTintColor: Colors.white,
        child: ListTile(
          hoverColor: const Color.fromARGB(31, 0, 0, 0),
          subtitle: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (containerWidth > 592) ...{
                SizedBox(
                  width: containerWidth > 1238 ? containerWidth * 0.54 : null,
                  child: Row(
                    children: [
                      SizedBox(
                        width: containerWidth > 1234
                            ? 618.5
                            : containerWidth > 801
                                ? 302
                                : Helpers.minAndMax(
                                    containerWidth * .2, 130, 160),
                        child: CustomTextStyle(
                            text: headings.first,
                            fontSize: 14,
                            isBold: true,
                            color: uiColor,
                            textAlign: TextAlign.center),
                      ),
                      HelpersWidget.buildVerticalDivider(
                          deviceHeight: deviceHeight,
                          deviceWidth: deviceWidth,
                          uiColor: uiColor),
                    ],
                  ),
                ),
              } else ...{
                const SizedBox(width: 45),
              },
              ...HelpersWidget.buildColumnBox(
                  text: headings.sublist(1),
                  width: containerWidth * .1,
                  deviceHeight: deviceHeight,
                  deviceWidth: deviceWidth,
                  uiColor: uiColor,
                  useTextwithUiColor: true),
            ],
          ),
        ),
      ),
    );
  }
}
